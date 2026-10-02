ACME ?= acme
VICE ?= xplus4
PYTHON ?= python3
VICE_SOUND_DEVICE ?= coreaudio
VICE_STANDARD ?= pal
PRG := build/c16-sound-fx.prg
SOURCES := $(wildcard src/*.asm src/*.inc)

.PHONY: all run test test-vice clean
all: $(PRG)

$(PRG): $(SOURCES) Makefile | build
	$(ACME) --format cbm --outfile $@ --symbollist build/symbols.txt --report build/listing.txt src/main.asm

build:
	mkdir -p $@

run: $(PRG)
	$(VICE) -default -model c16 -ramsize 16 -$(VICE_STANDARD) -sound -sounddev $(VICE_SOUND_DEVICE) +warp -autostartprgmode 1 -autostart $(PRG)

test: $(PRG)
	$(PYTHON) tests/test_engine.py

test-vice: $(PRG)
	$(PYTHON) tests/vice_smoke.py $(VICE)

clean:
	$(RM) -r build
