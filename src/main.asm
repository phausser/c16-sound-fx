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
    cld
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
    jsr menu_keyboard_tick
    jsr menu_status
    jmp .keys
.low:
    lda #0
    sta frame_seen
.keys:
    jsr KERNAL_GETIN           ; IRQ keyboard scan stays enabled
    jsr menu_key
    cmp #0
    bne +
    jmp ignore_key
+
    cmp #'Q'
    bne +
    jmp exit
+
    cmp #'S'
    bne +
    jmp stop
+
    cmp #3                    ; RUN/STOP buffered PETSCII
    bne +
    jmp stop
+
    cmp #'L'
    bne +
    jmp toggle_loop
+
    cmp #'N'
    bne +
    jmp ntsc
+
    cmp #'P'
    bne +
    jmp pal
+
    cmp #13
    bne +
    jmp play_input
+
    cmp #' '
    bne +
    jmp play_input
+
    cmp #'0'
    bcc ignore_key
    cmp #'9'+1
    bcs ignore_key
    sec
    sbc #'0'
    sta input_digit
    lda input_digits
    cmp #1
    beq second_digit
    lda #0
    sta input_id
    sta input_digits
second_digit:
    lda input_id
    asl
    sta input_tens
    asl
    asl
    clc
    adc input_tens
    adc input_digit
    sta input_id
    inc input_digits
ignore_key:
    jmp poll
play_input:
    lda input_digits
    bne +
    ldx menu_selected
    lda menu_order,x
    sta input_id
+
    lda input_id            ; IDs 50..99 rejected without interrupting playback
    jsr sfx_play
    lda #0
    sta input_digits
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
    jsr menu_shutdown
    rts                       ; return through BASIC SYS
frame_seen: !byte 0
input_id: !byte 0
input_digits: !byte 0
input_digit: !byte 0
input_tens: !byte 0

!source "src/menu.asm"
!source "src/sfx_engine.asm"
!source "src/sfx_data.asm"
program_end:

!if basic_start < SCREEN_BASE + $400 { !error "Program overlaps screen" }
!if ATTRIBUTE_BASE + $400 > SCREEN_BASE { !error "Screen/attributes overlap" }
!if program_end > RAM_END { !error "Program exceeds 16 KB C16 RAM" }
!if entry < 1000 { !error "SYS stub needs four decimal digits" }
!if entry > 9999 { !error "SYS stub needs four decimal digits" }
