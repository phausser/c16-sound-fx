ACME ?= acme
VICE ?= xplus4
PRG := build/c16-sound-fx.prg
SOURCES := $(wildcard src/*.asm src/*.inc)

.PHONY: all run clean
all: $(PRG)

$(PRG): $(SOURCES) Makefile | build
	$(ACME) --format cbm --outfile $@ --symbollist build/symbols.txt --report build/listing.txt src/main.asm

build:
	mkdir -p $@

run: $(PRG)
	$(VICE) -default -model c16 -ramsize 16 -pal -sound -sounddev coreaudio +warp -autostartprgmode 1 -autostart $(PRG)

clean:
	$(RM) -r build
