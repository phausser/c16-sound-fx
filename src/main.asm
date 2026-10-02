!cpu 6502
!source "src/ted.inc"

* = PROGRAM_BASE
basic_start:
    !word basic_end
    !word 10
    !byte $9e                  ; SYS, decimal address derived from entry
    !byte '0' + entry / 1000
    !byte '0' + (entry / 100) % 10
    !byte '0' + (entry / 10) % 10
    !byte '0' + entry % 10
    !byte 0
basic_end:
    !word 0

entry:
    jsr menu_init
poll:
    jsr KERNAL_GETIN           ; IRQ keyboard scan stays enabled
    cmp #'Q'
    bne poll
    rts                       ; return through BASIC SYS

!source "src/menu.asm"
program_end:

!if basic_start < SCREEN_BASE + $400 { !error "Program overlaps screen" }
!if ATTRIBUTE_BASE + $400 > SCREEN_BASE { !error "Screen/attributes overlap" }
!if program_end > RAM_END { !error "Program exceeds 16 KB C16 RAM" }
!if entry < 1000 { !error "SYS stub needs four decimal digits" }
!if entry > 9999 { !error "SYS stub needs four decimal digits" }
