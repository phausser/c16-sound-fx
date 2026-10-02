"""Verify menu-free game integration in the real 16 KB C16 emulator."""
from pathlib import Path
import re
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
build = root / 'build'
symbols = {n: int(v, 16) for n, v in re.findall(
    r'^\s*(\w+)\s*=\s*\$([0-9a-f]+)',
    (build / 'example-symbols.txt').read_text(), re.M)}
vice = sys.argv[1] if len(sys.argv) > 1 else 'xplus4'
assert 'menu_init' not in symbols

for standard in ('pal', 'ntsc'):
    prefix = build / f'example-{standard}'
    def until(name):
        return f"until ${symbols[name]:04x}"
    def save(tag, first, last=None):
        return (f'bsave "{prefix}-{tag}.bin" 0 ${symbols[first]:04x} '
                f'${symbols[last or first]:04x}')
    commands = ['delete 1']
    if standard == 'ntsc':
        commands += ['keybuf "n"', until('example_standard'), until('example_poll')]
    for key, effect in ((' ', 15), ('f', 25), ('c', 5)):
        commands += [f'keybuf "{key}"', until('sfx_play'), until('example_poll'),
                     f'bsave "{prefix}-{effect}-start.bin" 0 '
                     f"${symbols['sfx_start']:04x} ${symbols['sfx_start'] + 1:04x}",
                     f'bsave "{prefix}-{effect}-sound.bin" 0 $ff11 $ff11',
                     f"break ${symbols['sfx_tick']:04x}", 'ignore 1 $20', 'x', 'delete 1',
                     f'bsave "{prefix}-{effect}-ended.bin" 0 $ff11 $ff11']
    commands += ['keybuf "l"', until('sfx_play'), until('example_poll'),
                 save('before', 'example_player_x'),
                 f"break ${symbols['sfx_tick']:04x}", 'ignore 1 $0c', 'x', 'delete 1',
                 save('after', 'example_player_x'), save('active', 'sfx_active', 'sfx_loop'),
                 'keybuf "s"', until('sfx_stop'), until('example_poll'),
                 save('stopped', 'sfx_active', 'sfx_loop'),
                 'keybuf "q"', until('example_exit'), 'next', 'step', 'step', 'step',
                 'registers', 'quit']
    script = prefix.with_suffix('.mon')
    log = prefix.with_suffix('.log')
    script.write_text('\n'.join(commands) + '\n')
    log.write_text('')
    with prefix.with_suffix('.stdout.log').open('w') as output:
        result = subprocess.run([
            vice, '-default', '-console', '-model', 'c16', '-ramsize', '16',
            f'-{standard}', '-sound', '-sounddev', 'dummy', '-warp',
            '-autostartprgmode', '1', '-autostart', str(build / 'game-integration.prg'),
            '-initbreak', hex(symbols['example_poll']), '-moncommands', str(script),
            '-monlog', '-monlogname', str(log), '-limitcycles', '30000000'
        ], cwd=root, stdout=output, stderr=subprocess.STDOUT, timeout=60)
    assert result.returncode == 0, prefix
    text = log.read_text(encoding='latin-1')
    assert 'ERROR' not in text and 'not a valid checkpoint' not in text
    prg = (build / 'game-integration.prg').read_bytes()
    load = int.from_bytes(prg[:2], 'little')
    table = symbols[f'sfx_table_{standard}']
    for effect in (15, 25, 5):
        offset = 2 + table + effect * 4 - load
        assert Path(f'{prefix}-{effect}-start.bin').read_bytes() == prg[offset:offset + 2]
        assert Path(f'{prefix}-{effect}-sound.bin').read_bytes() != b'\x00'
        assert Path(f'{prefix}-{effect}-ended.bin').read_bytes() == b'\x00'
    before = Path(f'{prefix}-before.bin').read_bytes()[0]
    after = Path(f'{prefix}-after.bin').read_bytes()[0]
    assert 0 <= before < 40 and 0 <= after < 40 and before != after
    assert Path(f'{prefix}-active.bin').read_bytes() == b'\x01\x01'
    assert Path(f'{prefix}-stopped.bin').read_bytes() == b'\x00\x00'
    pc = int(re.findall(r'^\.;([0-9a-f]{4}) ', text, re.M)[-1], 16)
    assert 0x8000 <= pc < 0xff00, hex(pc)
    print(f'Example VICE {standard.upper()}: 3 sound events/endings, live game '
          'during engine loop, stop and BASIC return passed')
