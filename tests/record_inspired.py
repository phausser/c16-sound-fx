"""Record a range of effect IDs (default 50-69) sequentially in real PAL VICE."""
from pathlib import Path
from array import array
import argparse
import re
import subprocess
import sys
import wave

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('vice', nargs='?', default='xplus4')
parser.add_argument('sound_device', nargs='?')
parser.add_argument('--first', type=int, default=50)
parser.add_argument('--last', type=int, default=69)
parser.add_argument('--cycles', type=int, default=1)
args = parser.parse_args()
assert 0 <= args.first <= args.last and args.cycles >= 1
root = Path(__file__).resolve().parents[1]
build = root / 'build'
symbols = {n: int(v, 16) for n, v in re.findall(
    r'^\s*(\w+)\s*=\s*\$([0-9a-f]+)',
    (build / 'symbols.txt').read_text(), re.M)}
prg = (build / 'c16-sound-fx.prg').read_bytes()
load = int.from_bytes(prg[:2], 'little')
offset = 2 + symbols['sfx_durations'] - load
assert args.last < symbols['SFX_COUNT']
looping = args.cycles > 1
if looping:
    flag_offset = 2 + symbols['sfx_flags'] - load
    assert all(prg[flag_offset + i] & 1 for i in range(args.first, args.last + 1))
if looping:
    name = 'wing-loops-pal'
elif args.first >= 100:
    name = 'boulder-dash-pal'
elif args.first >= 90:
    name = 'ios-pal'
elif args.first >= 80:
    name = 'mario-pal'
elif args.first >= 75:
    name = 'life-lost-pal'
else:
    name = 'game-inspired-pal'
prefix = build / name
commands = ['delete 1', 'warp off']
if looping:
    commands += ['keybuf "l"', f"until ${symbols['toggle_loop']:04x}",
                 f"until ${symbols['poll']:04x}"]
for effect in range(args.first, args.last + 1):
    frames = prg[offset + effect] * args.cycles + (0 if looping else 12)  # natural end followed by audible gap
    commands += [f'keybuf "{effect:02d}\\x0d"',
                 f"until ${symbols['sfx_play']:04x}",
                 f"until ${symbols['poll']:04x}",
                 f"break ${symbols['sfx_tick']:04x}", f'ignore 1 ${frames:02x}',
                 'x', 'delete 1',
                 f'bsave "{prefix}-{effect}-active.bin" 0 '
                 f"${symbols['sfx_active']:04x} ${symbols['sfx_active']:04x}"]
    if looping:
        commands += ['keybuf "s"', f"until ${symbols['stop']:04x}",
                     f"until ${symbols['poll']:04x}"]
    commands += [f'bsave "{prefix}-{effect}-ended.bin" 0 $ff11 $ff11']
    if looping:
        commands += [f"break ${symbols['sfx_tick']:04x}", 'ignore 1 $0c',
                     'x', 'delete 1', 'keybuf "l"',
                     f"until ${symbols['toggle_loop']:04x}", f"until ${symbols['poll']:04x}"]
commands += ['quit']
script = prefix.with_suffix('.mon')
script.write_text('\n'.join(commands) + '\n')
with prefix.with_suffix('.stdout.log').open('w') as output:
    result = subprocess.run([
        args.vice, '-default', '-console',
        '-model', 'c16', '-ramsize', '16', '-pal', '-sound', '-soundoutput', '1',
        *(['-sounddev', args.sound_device] if args.sound_device else []),
        '-warp', '-soundwarpmode', '1', '-soundrecdev', 'wav',
        '-soundrecarg', str(prefix.with_suffix('.wav')),
        '-autostartprgmode', '1', '-autostart', str(build / 'c16-sound-fx.prg'),
        '-initbreak', hex(symbols['poll']), '-moncommands', str(script),
        '-limitcycles', '40000000'
    ], cwd=root, stdout=output, stderr=subprocess.STDOUT, timeout=60)
assert result.returncode == 0
for effect in range(args.first, args.last + 1):
    assert Path(f'{prefix}-{effect}-active.bin').read_bytes() == bytes([int(looping)])
    assert Path(f'{prefix}-{effect}-ended.bin').read_bytes() == b'\x00'
# VICE monitor quit can leave provisional RIFF lengths. Preserve captured PCM.
path = prefix.with_suffix('.wav')
with wave.open(str(path)) as recording:
    channels, width, rate = recording.getnchannels(), recording.getsampwidth(), recording.getframerate()
    pcm = recording.readframes(recording.getnframes())
assert width == 2 and pcm and len(pcm) % (channels * width) == 0
samples = array('h', pcm)
if sys.byteorder != 'little':
    samples.byteswap()
assert max(samples) - min(samples) > 100
with wave.open(str(path), 'wb') as recording:
    recording.setnchannels(channels)
    recording.setsampwidth(width)
    recording.setframerate(rate)
    recording.writeframes(pcm)
print(f'Preview: {path}; IDs {args.first}-{args.last}, {len(pcm)/(channels*width*rate):.2f} s; '
      f'non-silent PCM and {args.last-args.first+1} ' +
      ('loops/stops' if looping else 'natural endings') + ' verified, listening assessment open')
