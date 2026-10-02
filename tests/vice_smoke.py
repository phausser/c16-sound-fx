"""VICE monitor integration: real ROM, keyboard buffer, frames, PAL/NTSC."""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / 'build'
symbols = dict((n, int(v, 16)) for n, v in re.findall(
    r'^\s*(\w+)\s*=\s*\$([0-9a-f]+)',
    (BUILD / 'symbols.txt').read_text(), re.M))
vice = sys.argv[1] if len(sys.argv) > 1 else 'xplus4'

for standard in ('pal', 'ntsc'):
    prefix = BUILD / f'vice-{standard}'
    commands = ['delete 1']  # remove persistent initbreak
    if standard == 'ntsc':
        commands += ['keybuf "n"', f"until ${symbols['set_standard']:04x}",
                     f"until ${symbols['poll']:04x}"]
    commands += ['screen']
    for key in range(1, 5):
        commands += [f'keybuf "{key}"', f"until ${symbols['sfx_play']:04x}",
                     f"until ${symbols['poll']:04x}",
                     f'bsave "{prefix}-{key}-playing.bin" 0 $ff0e $ff12',
                     f"break ${symbols['sfx_tick']:04x}", 'ignore 1 60', 'x',
                     'delete 1',
                     f'bsave "{prefix}-{key}-ended.bin" 0 $ff0e $ff12']
    commands += ['keybuf "q"', f"until ${symbols['exit']:04x}",
                 'next', 'step', 'registers', 'quit']
    script = prefix.with_suffix('.mon')
    log = prefix.with_suffix('.log')
    script.write_text('\n'.join(commands) + '\n')
    log.write_text('')
    with prefix.with_suffix('.stdout.log').open('w') as output:
        result = subprocess.run([
            vice, '-default', '-console', '-model', 'c16', '-ramsize', '16',
            f'-{standard}', '-sound', '-sounddev', 'dummy', '-warp',
            '-autostartprgmode', '1', '-autostart', str(BUILD / 'c16-sound-fx.prg'),
            '-initbreak', hex(symbols['poll']), '-moncommands', str(script),
            '-monlog', '-monlogname', str(log), '-limitcycles', '20000000'
        ], cwd=ROOT, stdout=output, stderr=subprocess.STDOUT, timeout=30)
    assert result.returncode == 0, prefix.with_suffix('.stdout.log')
    text = log.read_text()
    assert 'SOUND ENGINE PROTOTYPES' in text
    assert 'ERROR' not in text and 'not a valid checkpoint' not in text
    for key in range(1, 5):
        playing = Path(f'{prefix}-{key}-playing.bin').read_bytes()
        ended = Path(f'{prefix}-{key}-ended.bin').read_bytes()
        assert playing[3] != 0 and ended[3] == 0, (standard, key)
        assert playing[4] & 0xfc == ended[4] & 0xfc, (standard, key)
    final_pc = int(re.findall(r'^\.;([0-9a-f]{4}) ', text, re.M)[-1], 16)
    assert 0x8000 <= final_pc < 0xff00, hex(final_pc)
    print(f'VICE {standard.upper()}: four prototype starts/ends, screen text, '
          f'Q return to BASIC (${final_pc:04X}) passed')
