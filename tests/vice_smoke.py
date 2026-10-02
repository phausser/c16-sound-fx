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
durations = prg[offset:offset + symbols["SFX_COUNT"]]

flag_offset = 2 + symbols['sfx_flags'] - load
loop_ids = [i for i in range(symbols['SFX_COUNT']) if prg[flag_offset + i] & 1]
for standard in ('pal', 'ntsc'):
    prefix = BUILD / f'vice-{standard}'
    commands = ['delete 1', f'bsave "{prefix}-repeat.bin" 0 $0540 $0540',
                f'bsave "{prefix}-repeat-saved.bin" 0 '
                f"${symbols['menu_saved_repeat']:04x} ${symbols['menu_saved_repeat']:04x}"]  # remove persistent initbreak
    if record:
        commands += ['warp off']  # VICE does not flush WAV samples during warp
    if standard == 'ntsc':
        commands += ['keybuf "n"', f"until ${symbols['set_standard']:04x}",
                     f"until ${symbols['poll']:04x}"]
    # Allow TED to render the complete screen before taking the screenshot.
    commands += [f"break ${symbols['sfx_tick']:04x}", 'ignore 1 2', 'x', 'delete 1']
    commands += [f'bsave "{prefix}-attributes.bin" 0 $0800 $0be7',
                 f'bsave "{prefix}-colors.bin" 0 $ff15 $ff19']
    commands += ['screen', f'bsave "{prefix}-screen.bin" 0 $0c00 $0fe7',
                 f'screenshot "{prefix}-screen.png" 2']
    # Visit all category pages and return to the first without wrapping.
    for page, key in ([(p, r"\x1d") for p in range(2, symbols['SFX_PAGE_COUNT'] + 1)] +
                      [(p, r"\x9d") for p in range(symbols['SFX_PAGE_COUNT'] - 1, 0, -1)]):
        commands += [f'keybuf "{key}"', f"until ${symbols['menu_draw']:04x}",
                     f"until ${symbols['poll']:04x}",
                     f'bsave "{prefix}-page{page}.bin" 0 $0c00 $0fe7']
    commands += ['keybuf "h"', f"until ${symbols['menu_draw']:04x}",
                 f"until ${symbols['poll']:04x}",
                 f"break ${symbols['sfx_tick']:04x}", 'ignore 1 2', 'x', 'delete 1',
                 f'bsave "{prefix}-help.bin" 0 $0c00 $0fe7',
                 f'screenshot "{prefix}-help.png" 2',
                 'keybuf "h"', f"until ${symbols['menu_draw']:04x}",
                 f"until ${symbols['poll']:04x}"]
    # All catalog IDs are entered through the actual demo's numeric input.
    for effect in range(symbols["SFX_COUNT"]):
        key = f'{effect:02d}'
        frames = durations[effect] + 2
        if standard == 'ntsc':
            frames = (frames * 6 + 4) // 5
        commands += [f'keybuf "{key}\\x0d"', f"until ${symbols['sfx_play']:04x}",
                     f"until ${symbols['poll']:04x}",
                     f'bsave "{prefix}-{key}-playing.bin" 0 $ff0e $ff12',
                     f'bsave "{prefix}-{key}-input.bin" 0 '
                     f"${symbols['input_id']:04x} ${symbols['input_id']:04x}",
                     f"break ${symbols['sfx_tick']:04x}", f'ignore 1 ${frames:02x}', 'x',
                     'delete 1',
                     f'bsave "{prefix}-{key}-ended.bin" 0 $ff0e $ff12',
                     f'keybuf "{key}\\x0d"', f"until ${symbols['sfx_play']:04x}",
                     f"until ${symbols['poll']:04x}",
                     'keybuf "s"', f"until ${symbols['stop']:04x}",
                     f"until ${symbols['poll']:04x}",
                     f'bsave "{prefix}-{key}-manual-stop.bin" 0 $ff11 $ff11']
    for effect in loop_ids:
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
                     'keybuf "\\x1d"', f"until ${symbols['menu_draw']:04x}",
                     f"until ${symbols['poll']:04x}",
                     'keybuf "\\x9d"', f"until ${symbols['menu_draw']:04x}",
                     f"until ${symbols['poll']:04x}",
                     f'bsave "{prefix}-{effect:02d}-navigated.bin" 0 '
                     f"${symbols['sfx_active']:04x} ${symbols['sfx_gap']:04x}",
                     'keybuf "s"', f"until ${symbols['stop']:04x}",
                     f"until ${symbols['poll']:04x}",
                     f'bsave "{prefix}-{effect:02d}-stopped.bin" 0 $ff0e $ff12']
    commands += ['keybuf "q"', f"until ${symbols['exit']:04x}",
                  'next', 'next',
                 f'bsave "{prefix}-repeat-restored.bin" 0 $0540 $0540',
                 'step', 'registers', 'quit' ]
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
    assert Path(f'{prefix}-repeat.bin').read_bytes() == b'\x40'
    assert Path(f'{prefix}-repeat-restored.bin').read_bytes() == Path(
        f'{prefix}-repeat-saved.bin').read_bytes()
    text = log.read_text(encoding="latin-1")
    assert Path(f'{prefix}-attributes.bin').read_bytes() == bytes([0x71]) * 1000
    colors = Path(f'{prefix}-colors.bin').read_bytes()
    expected_background = symbols.get("TED_BG_COLOR", 0) & 0x7f
    assert colors[0] & 0x7f == expected_background
    assert colors[4] & 0x7f == expected_background
    screen = Path(f'{prefix}-screen.bin').read_bytes()
    decoded = ''.join(chr((b & 0x7f) + 64) if (b & 0x7f) < 32 else chr(b & 0x7f) for b in screen)
    assert 'C=16 SOUND FX' in decoded
    assert 'LOOP: OFF' in decoded[:40] and '(H)ELP' in decoded[:40]
    assert 'STATUS:' not in decoded
    assert f"{prg[2 + symbols['menu_order'] - load + 23]:02d} (" in decoded[24 * 40:25 * 40]
    assert all(b & 0x80 for b in screen[:40])
    assert '(JINGLE)' in decoded and '(SAMMELN)' in decoded
    assert 'CURSOR: SELECT/PAGE' not in decoded
    help_data = Path(f'{prefix}-help.bin').read_bytes()
    help_text = ''.join(chr((b & 0x7f) + 64) if (b & 0x7f) < 32
                        else chr(b & 0x7f) for b in help_data)
    assert 'CURSOR UP/DOWN' in help_text and 'RUN-STOP' in help_text
    assert all(b & 0x80 for b in help_data[:40])
    order_offset = 2 + symbols['menu_order'] - load
    for page in range(1, symbols['SFX_PAGE_COUNT'] + 1):
        data = Path(f'{prefix}-page{page}.bin').read_bytes()
        effect = prg[order_offset + (page - 1) * 24]
        assert data[40:44] == f'>{effect:02d} '.encode('ascii'), (standard, page)
        assert data[37] == ord(str(page)) | 0x80
        assert data[39] == ord(str(symbols['SFX_PAGE_COUNT'])) | 0x80
        if page == symbols['SFX_PAGE_COUNT']:
            rows = symbols['SFX_COUNT'] - (page - 1) * 24
            assert data[(rows + 1) * 40:] == b' ' * ((24 - rows) * 40)
    assert 'ERROR' not in text and 'not a valid checkpoint' not in text
    for effect in range(symbols["SFX_COUNT"]):
        key = f'{effect:02d}'
        playing = Path(f'{prefix}-{key}-playing.bin').read_bytes()
        ended = Path(f'{prefix}-{key}-ended.bin').read_bytes()
        assert Path(f'{prefix}-{key}-manual-stop.bin').read_bytes() == b'\x00'
        assert playing[3] != 0 and ended[3] == 0, (standard, key)
        assert playing[4] & 0xfc == ended[4] & 0xfc, (standard, key)
        assert Path(f'{prefix}-{key}-input.bin').read_bytes() == bytes([effect])
    for effect in loop_ids:
        state = Path(f'{prefix}-{effect:02d}-loop.bin').read_bytes()
        assert state[0] == 1 and state[1] == 1 and state[3] == 0
        navigated = Path(f'{prefix}-{effect:02d}-navigated.bin').read_bytes()
        assert navigated[0] == navigated[1] == 1
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
    print(f"VICE {standard.upper()}: {symbols['SFX_COUNT']} effect starts/ends/stops, "
          f'{len(loop_ids)} loops/stops, screen text, '
          f'Q return to BASIC (${final_pc:04X}) passed')
