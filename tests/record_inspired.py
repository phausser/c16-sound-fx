"""Record game-inspired IDs 50-69 sequentially in real PAL VICE."""
from pathlib import Path
from array import array
import re
import subprocess
import sys
import wave

root = Path(__file__).resolve().parents[1]
build = root / 'build'
symbols = {n: int(v, 16) for n, v in re.findall(
    r'^\s*(\w+)\s*=\s*\$([0-9a-f]+)',
    (build / 'symbols.txt').read_text(), re.M)}
prg = (build / 'c16-sound-fx.prg').read_bytes()
load = int.from_bytes(prg[:2], 'little')
offset = 2 + symbols['sfx_durations'] - load
prefix = build / 'game-inspired-pal'
commands = ['delete 1', 'warp off']
for effect in range(50, 70):
    frames = prg[offset + effect] + 12  # natural end followed by audible gap
    commands += [f'keybuf "{effect:02d}\\x0d"',
                 f"until ${symbols['sfx_play']:04x}",
                 f"until ${symbols['poll']:04x}",
                 f"break ${symbols['sfx_tick']:04x}", f'ignore 1 ${frames:02x}',
                 'x', 'delete 1',
                 f'bsave "{prefix}-{effect}-ended.bin" 0 $ff11 $ff11']
commands += ['quit']
script = prefix.with_suffix('.mon')
script.write_text('\n'.join(commands) + '\n')
with prefix.with_suffix('.stdout.log').open('w') as output:
    result = subprocess.run([
        sys.argv[1] if len(sys.argv) > 1 else 'xplus4', '-default', '-console',
        '-model', 'c16', '-ramsize', '16', '-pal', '-sound', '-soundoutput', '1',
        '-sounddev', sys.argv[2] if len(sys.argv) > 2 else 'coreaudio',
        '-warp', '-soundwarpmode', '1', '-soundrecdev', 'wav',
        '-soundrecarg', str(prefix.with_suffix('.wav')),
        '-autostartprgmode', '1', '-autostart', str(build / 'c16-sound-fx.prg'),
        '-initbreak', hex(symbols['poll']), '-moncommands', str(script),
        '-limitcycles', '40000000'
    ], cwd=root, stdout=output, stderr=subprocess.STDOUT, timeout=60)
assert result.returncode == 0
for effect in range(50, 70):
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
print(f'Preview: {path}; IDs 50-69, {len(pcm)/(channels*width*rate):.2f} s; '
      'non-silent PCM and 20 natural endings verified, listening assessment open')
