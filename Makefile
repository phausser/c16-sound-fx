ACME ?= acme
VICE ?= xplus4
PYTHON ?= python3
VICE_SOUND_DEVICE ?= coreaudio
VICE_STANDARD ?= pal
PRG := build/c16-sound-fx.prg
EXAMPLE := build/game-integration.prg
SOURCES := $(wildcard src/*.asm src/*.inc)

.PHONY: all run test test-vice record-vice clean example run-example test-example-vice record-inspired record-flaps record-life record-mario record-ios record-boulder
all: $(PRG)

$(PRG): $(SOURCES) Makefile | build
	$(ACME) --format cbm --outfile $@ --symbollist build/symbols.txt --report build/listing.txt src/main.asm

example: $(EXAMPLE)

$(EXAMPLE): examples/game_integration.asm src/sfx_engine.asm src/sfx_data.asm src/ted.inc Makefile | build
	$(ACME) --format cbm --outfile $@ --symbollist build/example-symbols.txt --report build/example-listing.txt examples/game_integration.asm

run-example: $(EXAMPLE)
	$(VICE) -default -model c16 -ramsize 16 -$(VICE_STANDARD) -sound -sounddev $(VICE_SOUND_DEVICE) +warp -autostartprgmode 1 -autostart $(EXAMPLE)

test-example-vice: $(EXAMPLE)
	$(PYTHON) tests/vice_example.py $(VICE)

build:
	mkdir -p $@

run: $(PRG)
	$(VICE) -default -model c16 -ramsize 16 -$(VICE_STANDARD) -sound -sounddev $(VICE_SOUND_DEVICE) +warp -autostartprgmode 1 -autostart $(PRG)

test: $(PRG)
	$(PYTHON) tests/test_engine.py
	$(PYTHON) tests/test_menu.py

test-vice: $(PRG)
	$(PYTHON) tests/vice_smoke.py $(VICE)

record-vice: $(PRG)
	$(PYTHON) tests/vice_smoke.py $(VICE) --record --sound-device $(VICE_SOUND_DEVICE)

record-inspired: $(PRG)
	$(PYTHON) tests/record_inspired.py $(VICE) $(VICE_SOUND_DEVICE)

record-flaps: $(PRG)
	$(PYTHON) tests/record_inspired.py $(VICE) $(VICE_SOUND_DEVICE) --first 70 --last 74 --cycles 4

clean:
	$(RM) -r build

record-life: $(PRG)
	$(PYTHON) tests/record_inspired.py $(VICE) $(VICE_SOUND_DEVICE) --first 75 --last 79

record-mario: $(PRG)
	$(PYTHON) tests/record_inspired.py $(VICE) $(VICE_SOUND_DEVICE) --first 80 --last 89

record-ios: $(PRG)
	$(PYTHON) tests/record_inspired.py $(VICE) $(VICE_SOUND_DEVICE) --first 90 --last 99

record-boulder: $(PRG)
	$(PYTHON) tests/record_inspired.py $(VICE) $(VICE_SOUND_DEVICE) --first 100 --last 104
