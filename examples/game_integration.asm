; Minimal game loop: animated player plus sound events, no menu dependency.
!cpu 6502
!source "src/ted.inc"
* = PROGRAM_BASE
example_basic:
    !word example_basic_end
    !word 10
    !byte $9e
    !byte '0'+example_entry/1000, '0'+(example_entry/100)%10
    !byte '0'+(example_entry/10)%10, '0'+example_entry%10, 0
example_basic_end:
    !word 0
example_entry:
    cld
    lda KERNAL_REPEAT
    sta example_saved_repeat
    lda #$40
    sta KERNAL_REPEAT
    lda #$93
    jsr KERNAL_CHROUT
    ldx #0
.print:
    lda example_text,x
    beq .ready
    txa
    pha
    lda example_text,x
    jsr KERNAL_CHROUT
    pla
    tax
    inx
    bne .print
.ready:
    lda #0                       ; explicit PAL; N selects NTSC
    jsr sfx_init
example_poll:
    lda $ff1c
    and #1
    beq .low
    lda example_frame_seen
    bne .keys
    inc example_frame_seen
    jsr sfx_tick                  ; only call site, one call per video frame
    jsr example_update_player     ; game keeps running during every sound
    jmp .keys
.low:
    lda #0
    sta example_frame_seen
.keys:
    jsr KERNAL_STOP
    bne +
    jsr sfx_stop
+
    jsr KERNAL_GETIN
    cmp #'Q'
    beq example_exit
    cmp #'S'
    beq .stop
    cmp #'P'
    beq .pal
    cmp #'N'
    beq .ntsc
    cmp #'L'
    beq .engine
    cmp #' '
    beq .jump
    cmp #'F'
    beq .fire
    cmp #'C'
    bne example_poll
    lda #SFX_COIN_PICKUP
    jmp example_play
.jump:
    lda #SFX_JUMP
    jmp example_play
.fire:
    lda #SFX_LASER_SHOT
    jmp example_play
.engine:
    lda #1
    jsr sfx_set_loop
    lda #SFX_ENGINE_IDLE
example_play:
    jsr sfx_play                  ; event replaces prior effect immediately
    jmp example_poll
.stop:
    jsr sfx_stop
    jmp example_poll
.pal:
    lda #0
    beq example_standard
.ntsc:
    lda #1
example_standard:
    pha
    jsr sfx_shutdown
    pla
    jsr sfx_init
    jmp example_poll
example_exit:
    jsr sfx_shutdown
    lda example_saved_repeat
    sta KERNAL_REPEAT
    rts

example_update_player:
    inc example_move_timer
    lda example_move_timer
    and #3
    bne .done
    ldx example_player_x
    lda #' '
    sta SCREEN_BASE+12*40,x
    inx
    cpx #40
    bcc +
    ldx #0
+
    stx example_player_x
    lda #0                       ; screen code @
    sta SCREEN_BASE+12*40,x
.done:
    rts
example_frame_seen: !byte 0
example_player_x: !byte 0
example_move_timer: !byte 0
example_saved_repeat: !byte 0
example_text:
    !pet "soundengine game example",13,13
    !pet "space jump   f shot   c coin",13
    !pet "l engine loop   s/run-stop stop",13
    !pet "p pal   n ntsc   q basic",13,0
!if *-example_text > 255 { !error "Example text too long" }

!source "src/sfx_engine.asm"
!source "src/sfx_data.asm"
example_end:
!if example_end > RAM_END { !error "Example exceeds 16 KB RAM" }
!if example_basic < SCREEN_BASE+$400 { !error "Example overlaps screen" }
!if example_entry < 1000 { !error "Example SYS needs four digits" }
!if example_entry > 9999 { !error "Example SYS needs four digits" }
