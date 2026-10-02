"""Execute the assembled menu with sampled KERNAL key state and STOP stub."""
from pathlib import Path
import re
from py65.devices.mpu6502 import MPU

root = Path(__file__).resolve().parents[1]
symbols = {n: int(v, 16) for n, v in re.findall(
    r'^\s*(\w+)\s*=\s*\$([0-9a-f]+)',
    (root / 'build/symbols.txt').read_text(), re.M)}
COUNT = symbols["SFX_COUNT"]
prg = (root / 'build/c16-sound-fx.prg').read_bytes()

for ntsc, delay, interval in ((0, 25, 5), (1, 30, 6)):
    cpu = MPU()
    load = int.from_bytes(prg[:2], 'little')
    cpu.memory[load:load + len(prg) - 2] = prg[2:]
    # STOP returns nonzero when not pressed; no IRQ or ROM is simulated here.
    cpu.memory[0xffe1:0xffe4] = [0xa9, 1, 0x60]

    def call(name, a=0):
        cpu.a = a
        cpu.pc = symbols[name]
        cpu.sp = 0xff
        cpu.stPushWord(0x02ff)
        for _ in range(50000):
            cpu.step()
            if cpu.pc == 0x0300:
                return
        raise AssertionError(f'{name} did not return')

    def state(name):
        return cpu.memory[symbols[name]]

    order = cpu.memory[symbols['menu_order']:symbols['menu_order'] + COUNT]
    categories = cpu.memory[symbols['menu_categories']:symbols['menu_categories'] + COUNT]
    assert sorted(order) == list(range(COUNT))
    assert categories == sorted(categories)
    call('menu_draw')
    assert all(b & 0x80 for b in cpu.memory[0x0c00:0x0c28])
    def screen_text():
        return ''.join(chr((b & 0x7f) + 64) if (b & 0x7f) < 32
                       else chr(b & 0x7f) for b in cpu.memory[0x0c00:0x0fe8])
    assert 'C=16 SOUND FX' in screen_text()[:40]
    assert '(H)ELP' in screen_text()[:40]
    assert 'LOOP: OFF' in screen_text()[:40]
    assert 'STATUS:' not in screen_text()
    call('sfx_init', ntsc)
    for position, effect in enumerate(order):
        cpu.memory[symbols['menu_selected']] = position
        call('menu_draw')
        name_address = cpu.memory[symbols['sfx_names'] + effect * 2] | (
            cpu.memory[symbols['sfx_names'] + effect * 2 + 1] << 8)
        name = ''
        while cpu.memory[name_address]:
            name += chr(cpu.memory[name_address])
            name_address += 1
        assert f'>{effect:02d} (' in screen_text()
        row = 1 + position % 24
        line = screen_text()[row * 40:(row + 1) * 40]
        assert line[20:20 + len(name)] == name
        assert line[19] == ' '
        assert line.startswith(f'>{effect:02d} (')
        call('sfx_play', effect)
        expected_start = cpu.memory[symbols['sfx_start']:symbols['sfx_start'] + 2]
        call('sfx_stop')
        cpu.memory[symbols['input_digits']] = 0
        cpu.pc = symbols['play_input']
        for _ in range(1000):
            cpu.step()
            if cpu.pc == symbols['poll']:
                break
        else:
            raise AssertionError('selected start did not return to polling')
        assert cpu.memory[symbols['sfx_start']:symbols['sfx_start'] + 2] == expected_start
        assert state('sfx_active') == 1
    cpu.memory[symbols['menu_selected']] = 0
    call('sfx_init', ntsc)
    call('sfx_set_loop', 1)
    call('sfx_play', 43)
    call('menu_status')
    assert 'LOOP: ON ' in screen_text()[:40]
    assert 'STATUS:' not in screen_text()
    sound = cpu.memory[0xff0e:0xff13]
    call('menu_key', ord('H'))
    assert state('menu_help') == 1 and 'CURSOR UP/DOWN' in screen_text()
    call('menu_key', 0x11)
    assert state('menu_selected') == 0
    call('menu_key', 13)
    assert state('menu_help') == 0
    assert cpu.memory[0xff0e:0xff13] == sound
    cpu.memory[0xc6] = 12  # sampled held matrix position
    cpu.memory[0x0543] = 0
    call('menu_key', 0x11)
    assert state('menu_selected') == 1
    for _ in range(delay - 1):
        call('menu_keyboard_tick')
    assert state('menu_selected') == 1
    call('menu_keyboard_tick')
    assert state('menu_selected') == 2
    for _ in range(interval):
        call('menu_keyboard_tick')
    assert state('menu_selected') == 3
    assert state('sfx_active') == state('sfx_loop') == 1
    assert cpu.memory[0xff0e:0xff13] == sound
    cpu.memory[0xc6] = 0x40
    for _ in range(delay * 2):
        call('menu_keyboard_tick')
    assert state('menu_selected') == 3 and state('menu_held_key') == 0
    # A modifier change cancels repetition, as does changing the physical key.
    cpu.memory[0xc6] = 12
    call('menu_key', 0x11)
    cpu.memory[0x0543] = 1
    call('menu_keyboard_tick')
    assert state('menu_held_key') == 0
    for key in (ord('L'), ord('S'), 13, 32):
        call('menu_key', key)
        assert cpu.a == key and state('menu_held_key') == 0
    for _ in range(COUNT + 10):
        call('menu_key', 0x11)
    assert state('menu_selected') == COUNT-1
    for _ in range(COUNT + 10):
        call('menu_key', 0x91)
    assert state('menu_selected') == 0
    # Held RUN/STOP uses the public KERNAL API, independent of GETIN buffering.
    cpu.memory[0xffe1:0xffe4] = [0xa9, 0, 0x60]
    call('menu_keyboard_tick')
    assert state('sfx_active') == state('sfx_loop') == 0
    cpu.memory[symbols['menu_saved_repeat']] = 0x80
    call('menu_shutdown')
    assert cpu.memory[0x0540] == 0x80

print(f'Menu checks passed: {COUNT} categorized selected starts, inverse header/help, '
      'PAL/NTSC held navigation, release, bounds, '
      'live-loop isolation, STOP, repeat-setting restoration')
