"""VICE monitor integration: real ROM, keyboard buffer, frames, PAL/NTSC."""
from pathlib import Path
import argparse
import re
import subprocess
import sys
import wave
from array import array

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / 'build'
symbols = dict((n, int(v, 16)) for n, v in re.findall(
    r'^\s*(\w+)\s*=\s*\$([0-9a-f]+)',
    (BUILD / 'symbols.txt').read_text(), re.M))
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('vice', nargs='?', default='xplus4')
parser.add_argument('--record', action='store_true')
parser.add_argument('--sound-device', default='coreaudio')
args = parser.parse_args()
vice = args.vice
record = args.record
prg = (BUILD / 'c16-sound-fx.prg').read_bytes()
load = int.from_bytes(prg[:2], 'little')
offset = 2 + symbols['sfx_durations'] - load
durations = prg[offset:offset + 50]

for standard in ('pal', 'ntsc'):
    prefix = BUILD / f'vice-{standard}'
    commands = ['delete 1']  # remove persistent initbreak
    if record:
        commands += ['warp off']  # VICE does not flush WAV samples during warp
    if standard == 'ntsc':
        commands += ['keybuf "n"', f"until ${symbols['set_standard']:04x}",
                     f"until ${symbols['poll']:04x}"]
    # Allow TED to render the complete screen before taking the screenshot.
    commands += [f"break ${symbols['sfx_tick']:04x}", 'ignore 1 2', 'x', 'delete 1']
    commands += ['screen', f'bsave "{prefix}-screen.bin" 0 $0c00 $0fe7',
                 f'screenshot "{prefix}-screen.png" 2']
    for page, key in ((2, r"\x1d"), (3, r"\x1d"), (1, r"\x9d\x9d")):
        commands += [f'keybuf "{key}"', f"until ${symbols['menu_draw']:04x}",
                     f"until ${symbols['poll']:04x}"]
        if page == 1:
            commands += [f"until ${symbols['menu_draw']:04x}",
                         f"until ${symbols['poll']:04x}"]
        commands += [f'bsave "{prefix}-page{page}.bin" 0 $0c00 $0fe7']
    # All catalog IDs are entered through the actual demo's numeric input.
    for effect in range(50):
        key = f'{effect:02d}'
        frames = durations[effect] + 2
        if standard == 'ntsc':
            frames = (frames * 6 + 4) // 5
        commands += [f'keybuf "{key}\\x0d"', f"until ${symbols['sfx_play']:04x}",
                     f"until ${symbols['poll']:04x}",
                     f'bsave "{prefix}-{key}-playing.bin" 0 $ff0e $ff12',
                     f'bsave "{prefix}-{key}-input.bin" 0 $0f4c $0f4d',
                     f"break ${symbols['sfx_tick']:04x}", f'ignore 1 ${frames:02x}', 'x',
                     'delete 1',
                     f'bsave "{prefix}-{key}-ended.bin" 0 $ff0e $ff12']
    for effect in (22, 23, 24, 27, 41, 43, 47, 48):
        frames = durations[effect] * 3 + 2
        if standard == 'ntsc':
            frames = (frames * 6 + 4) // 5
        commands += ['keybuf "l"', f"until ${symbols['toggle_loop']:04x}",
                     f"until ${symbols['poll']:04x}",
                     f'keybuf "{effect:02d}\\x0d"',
                     f"until ${symbols['sfx_play']:04x}",
                     f"until ${symbols['poll']:04x}",
                     f"break ${symbols['sfx_tick']:04x}", f'ignore 1 ${frames:02x}', 'x',
                     'delete 1',
                     f'bsave "{prefix}-{effect:02d}-loop.bin" 0 '
                     f"${symbols['sfx_active']:04x} ${symbols['sfx_gap']:04x}",
                     'keybuf "s"', f"until ${symbols['stop']:04x}",
                     f"until ${symbols['poll']:04x}",
                     f'bsave "{prefix}-{effect:02d}-stopped.bin" 0 $ff0e $ff12']
    commands += ['keybuf "q"', f"until ${symbols['exit']:04x}",
                 'next', 'step', 'registers', 'quit']
    script = prefix.with_suffix('.mon')
    log = prefix.with_suffix('.log')
    script.write_text('\n'.join(commands) + '\n')
    log.write_text('')
    audio_options = ['-soundwarpmode', '1', '-soundrecdev', 'wav',
                     '-soundrecarg', str(prefix.with_suffix('.wav'))] if record else []
    with prefix.with_suffix('.stdout.log').open('w') as output:
        result = subprocess.run([
            vice, '-default', '-console', '-model', 'c16', '-ramsize', '16',
            f'-{standard}', '-sound', '-sounddev', args.sound_device if record else 'dummy',
            '-soundoutput', '1', '-warp',
            *audio_options,
            '-autostartprgmode', '1', '-autostart', str(BUILD / 'c16-sound-fx.prg'),
            '-initbreak', hex(symbols['poll']), '-moncommands', str(script),
            '-monlog', '-monlogname', str(log), '-limitcycles', '200000000'
        ], cwd=ROOT, stdout=output, stderr=subprocess.STDOUT, timeout=60)
    assert result.returncode == 0, prefix.with_suffix('.stdout.log')
    text = log.read_text()
    screen = Path(f'{prefix}-screen.bin').read_bytes()
    decoded = ''.join(chr(b + 64) if b < 32 else chr(b) for b in screen)
    assert '50 SOUND EFFECTS' in decoded
    for page, first in ((1, '00 JINGLE-WIN'), (2, '20 STEP-STONE'), (3, '40 TELEPORT')):
        data = Path(f'{prefix}-page{page}.bin').read_bytes()
        content = ''.join(chr(b + 64) if b < 32 else chr(b) for b in data)
        assert first in content, (standard, page, content)
        assert data[36] == ord(str(page))
    assert 'ERROR' not in text and 'not a valid checkpoint' not in text
    for effect in range(50):
        key = f'{effect:02d}'
        playing = Path(f'{prefix}-{key}-playing.bin').read_bytes()
        ended = Path(f'{prefix}-{key}-ended.bin').read_bytes()
        assert playing[3] != 0 and ended[3] == 0, (standard, key)
        assert playing[4] & 0xfc == ended[4] & 0xfc, (standard, key)
        assert Path(f'{prefix}-{key}-input.bin').read_bytes() == key.encode('ascii')
    for effect in (22, 23, 24, 27, 41, 43, 47, 48):
        state = Path(f'{prefix}-{effect:02d}-loop.bin').read_bytes()
        assert state[0] == 1 and state[1] == 1 and state[3] == 0
        assert Path(f'{prefix}-{effect:02d}-stopped.bin').read_bytes()[3] == 0
    final_pc = int(re.findall(r'^\.;([0-9a-f]{4}) ', text, re.M)[-1], 16)
    assert 0x8000 <= final_pc < 0xff00, hex(final_pc)
    if record:
        with wave.open(str(prefix.with_suffix('.wav'))) as recording:
            assert recording.getsampwidth() == 2
            channels, rate = recording.getnchannels(), recording.getframerate()
            pcm = recording.readframes(recording.getnframes())
            samples = array('h', pcm)
            if sys.byteorder != 'little':
                samples.byteswap()
            assert samples and max(samples) - min(samples) > 100, 'audio recording is silent'
        # This VICE build leaves placeholder RIFF lengths on monitor quit.
        # Finalize from the actual captured PCM, preserving every sample.
        assert len(pcm) % (channels * 2) == 0
        with wave.open(str(prefix.with_suffix('.wav')), 'wb') as finalized:
            finalized.setnchannels(channels)
            finalized.setsampwidth(2)
            finalized.setframerate(rate)
            finalized.writeframes(pcm)
        with wave.open(str(prefix.with_suffix('.wav'))) as finalized:
            assert finalized.getnframes() == len(pcm) // (channels * 2)
        print(f'WAV: {prefix.with_suffix(".wav")} ({len(pcm) / (channels * 2 * rate):.2f} s)')
    print(f'VICE {standard.upper()}: 50 effect starts/ends, 8 loops/stops, screen text, '
          f'Q return to BASIC (${final_pc:04X}) passed')
