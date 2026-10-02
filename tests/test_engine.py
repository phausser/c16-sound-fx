"""Run real assembled 6502 routines; no mock of the engine logic."""
from pathlib import Path
import re
from py65.devices.mpu6502 import MPU

ROOT = Path(__file__).resolve().parents[1]
SYMBOLS = dict((name, int(value, 16)) for name, value in re.findall(
    r"^\s*(\w+)\s*=\s*\$([0-9a-f]+)",
    (ROOT / "build/symbols.txt").read_text(), re.M))
MAX_TICK = 0


class Memory(list):
    def __init__(self):
        super().__init__([0] * 65536)
        self.writes = []

    def __setitem__(self, address, value):
        if isinstance(address, int):
            self.writes.append((address, value))
        super().__setitem__(address, value)


class Engine:
    def __init__(self, ntsc=0):
        self.mem = Memory()
        prg = (ROOT / "build/c16-sound-fx.prg").read_bytes()
        start = int.from_bytes(prg[:2], "little")
        self.mem[start:start + len(prg) - 2] = prg[2:]
        self.cpu = MPU(memory=self.mem)
        for address, value in zip(range(0xff0e, 0xff13), (12, 34, 0xb2, 0x25, 0xad)):
            self.mem[address] = value
        self.saved = self.mem[0xff0e:0xff13]
        self.call("sfx_init", ntsc)
        assert not self.cpu.p & 1

    def call(self, name, a=0):
        global MAX_TICK
        self.cpu.a = a
        self.cpu.pc = SYMBOLS[name]
        self.cpu.sp = 0xff
        self.cpu.stPushWord(0x02ff)  # RTS returns to sentinel $0300
        before = self.cpu.processorCycles
        self.mem.writes = []
        for _ in range(1000):
            self.cpu.step()
            if self.cpu.pc == 0x0300:
                break
        else:
            raise AssertionError(f"{name} did not return")
        cycles = self.cpu.processorCycles - before
        if name == "sfx_tick":
            MAX_TICK = max(MAX_TICK, cycles)
            assert cycles <= 1000
            assert sum(addr == 0xff11 for addr, _ in self.mem.writes) <= 1
        assert self.mem[0xff12] & 0xfc == self.saved[4] & 0xfc
        assert self.mem[0xff10] & 0xfc == self.saved[2] & 0xfc
        assert all(0x1001 <= addr < 0x4000 or 0x100 <= addr < 0x200
                   or 0xff0e <= addr <= 0xff12 for addr, _ in self.mem.writes)
        return cycles

    def state(self, name):
        return self.mem[SYMBOLS[name]]

    def ticks(self, count):
        for _ in range(count):
            self.call("sfx_tick")


for ntsc in (0, 1):
    for effect, duration in ((0, 30), (17, 5), (26, 10), (43, 25)):
        e = Engine(ntsc)
        e.call("sfx_play", effect)
        assert e.state("sfx_active") == 1
        assert e.mem[0xff11] != 0
        frames = (duration * 60 + 49) // 50 if ntsc else duration
        e.ticks(frames - 1)
        assert e.state("sfx_active") == 1
        e.ticks(1)
        assert e.state("sfx_active") == 0 and e.mem[0xff11] == 0
        e.call("sfx_shutdown")
        assert e.mem[0xff0e:0xff13] == e.saved

    e = Engine(ntsc)
    e.call("sfx_set_loop", 1)
    e.call("sfx_play", 43)
    for _ in range(300):
        e.call("sfx_tick")
        assert e.state("sfx_active") and e.mem[0xff11]
    e.call("sfx_set_loop", 0)
    e.ticks(30)
    assert not e.state("sfx_active")

    e = Engine(ntsc)
    e.call("sfx_set_loop", 1)
    e.call("sfx_play", 17)
    end = 6 if ntsc else 5
    e.ticks(end)
    assert e.state("sfx_gap") and not e.mem[0xff11]
    e.ticks(11 if ntsc else 9)
    assert not e.mem[0xff11]
    e.ticks(1)
    assert e.mem[0xff11] and not e.state("sfx_gap")
    e.call("sfx_stop")
    assert not e.state("sfx_loop") and not e.state("sfx_active")
    e.ticks(100)
    assert not e.mem[0xff11]

e = Engine()
e.call("sfx_play", 0)
for routine, invalids in (("sfx_play", (50, 255)), ("sfx_init", (2, 255)),
                         ("sfx_set_loop", (2, 255))):
    before = e.mem[0x1001:0x4000], e.mem[0xff0e:0xff13]
    for value in invalids:
        e.call(routine, value)
        assert e.cpu.p & 1
        assert before == (e.mem[0x1001:0x4000], e.mem[0xff0e:0xff13])
e.ticks(9)
e.call("sfx_play", 0)
assert e.state("sfx_delay") == 10
e.ticks(30)
assert not e.state("sfx_active")

# Video owner changes upper bits while engine is active: shutdown keeps them.
e = Engine()
e.mem[0xff12] = 0x54 | (e.mem[0xff12] & 3)
e.saved[4] = 0x54 | (e.saved[4] & 3)
e.call("sfx_play", 26)
e.ticks(10)
e.call("sfx_shutdown")
assert e.mem[0xff12] == e.saved[4]

# All stable slots are bounded, including unfinished silent entries.
for effect in range(50):
    e = Engine()
    e.call("sfx_play", effect)
    assert not e.cpu.p & 1
    e.ticks(100)
    assert not e.state("sfx_active")

# Frequency conversion really uses different PAL and NTSC values.
pal, ntsc = Engine(0), Engine(1)
pal.call("sfx_play", 0)
ntsc.call("sfx_play", 0)
assert (pal.mem[0xff0e], pal.mem[0xff12] & 3) != (
    ntsc.mem[0xff0e], ntsc.mem[0xff12] & 3)

# Stream crossing a page boundary and independent repeat entry.
e = Engine(1)
table = SYMBOLS['sfx_table_ntsc'] + 43 * 4
e.mem[table:table + 4] = [0xfe, 0x1f, 0x04, 0x20]
e.mem[0x1ffe:0x200b] = [1, 1, 1, 2, 2, 0x16, 1, 3, 3, 4, 0, 0x17, 0]
e.call('sfx_set_loop', 1)
e.call('sfx_play', 43)
assert e.mem[0xff0e] == 1
e.ticks(2)
assert e.mem[0xff0e] == 3
for _ in range(20):
    e.ticks(1)
    assert e.mem[0xff0e] == 3 and e.mem[0xff11] == 0x17
e.call('sfx_set_loop', 0)
e.ticks(2)
assert not e.state('sfx_active')

# Loop disabling during a one-shot pause never restarts the effect.
e = Engine()
e.call('sfx_set_loop', 1)
e.call('sfx_play', 17)
e.ticks(5)
e.call('sfx_set_loop', 0)
e.ticks(10)
assert not e.state('sfx_active') and not e.mem[0xff11]

print(f"Engine checks passed; maximum measured tick: {MAX_TICK} CPU cycles")
print(f"Code: {SYMBOLS['sfx_code_end'] - SYMBOLS['sfx_init']} bytes; "
      f"state: {SYMBOLS['sfx_state_end'] - SYMBOLS['sfx_state']} bytes "
      "(2 mutable operand bytes included in code); zero page: 0 bytes")
