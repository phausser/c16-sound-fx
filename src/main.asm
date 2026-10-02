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
    lda #0                    ; demo defaults to PAL; N/P selects standard
    jsr sfx_init
poll:
    lda $ff1c                 ; rising raster bit 8: once per frame
    and #1
    beq .low
    lda frame_seen
    bne .keys
    inc frame_seen
    jsr sfx_tick
    jmp .keys
.low:
    lda #0
    sta frame_seen
.keys:
    jsr KERNAL_GETIN           ; IRQ keyboard scan stays enabled
    cmp #'Q'
    beq exit
    cmp #'S'
    beq stop
    cmp #3                    ; RUN/STOP buffered PETSCII
    beq stop
    cmp #'L'
    beq toggle_loop
    cmp #'N'
    beq ntsc
    cmp #'P'
    beq pal
    cmp #'1'
    bcc poll
    cmp #'5'
    bcs poll
    sec
    sbc #'1'
    tax
    lda prototype_ids,x
    jsr sfx_play
    jmp poll
stop:
    jsr sfx_stop
    jmp poll
toggle_loop:
    lda sfx_loop
    eor #1
    jsr sfx_set_loop
    jmp poll
ntsc:
    lda #1
    bne set_standard
pal:
    lda #0
set_standard:
    pha
    jsr sfx_shutdown
    pla
    jsr sfx_init
    jmp poll
exit:
    jsr sfx_shutdown
    rts                       ; return through BASIC SYS
frame_seen: !byte 0
prototype_ids: !byte 0,17,26,43

!source "src/menu.asm"
!source "src/sfx_engine.asm"
!source "src/sfx_data.asm"
program_end:

!if basic_start < SCREEN_BASE + $400 { !error "Program overlaps screen" }
!if ATTRIBUTE_BASE + $400 > SCREEN_BASE { !error "Screen/attributes overlap" }
!if program_end > RAM_END { !error "Program exceeds 16 KB C16 RAM" }
!if entry < 1000 { !error "SYS stub needs four decimal digits" }
!if entry > 9999 { !error "SYS stub needs four decimal digits" }
