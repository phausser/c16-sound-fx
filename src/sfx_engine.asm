; Writable RAM code, no zero page, IRQ installation or KERNAL calls.
; All API calls clobber A/X/Y and flags. Caller serializes calls.
; init: A=0 PAL, A=1 NTSC. Invalid parameters return C=1 unchanged.
sfx_init:
    cmp #2
    bcc +
    jmp sfx_invalid
+
    sta sfx_ntsc
    lda TED_FREQ1_LO
    sta sfx_saved
    lda TED_FREQ2_LO
    sta sfx_saved+1
    lda TED_FREQ2_HI
    sta sfx_saved+2
    lda TED_SOUND
    sta sfx_saved+3
    lda TED_FREQ1_HI
    sta sfx_saved+4
    lda #0
    sta sfx_phase
    jsr sfx_stop
    clc
    rts

; play: A=stable ID 0..69. Flag bit 0: seamless loop; bit 1: noise variation.
!zone sfx_play_zone
sfx_play:
    cmp #SFX_COUNT
    bcs sfx_invalid
    tax
    lda sfx_flags,x
    and #1
    sta sfx_seamless
    lda sfx_flags,x
    and #2
    sta sfx_variation
    lda #$a5
    sta sfx_random
    lda sfx_ntsc
    beq .pal
    lda #<sfx_table_ntsc
    sta sfx_lookup+1
    lda #>sfx_table_ntsc
    jmp .table_high
.pal:
    lda #<sfx_table_pal
    sta sfx_lookup+1
    lda #>sfx_table_pal
.table_high:
    sta sfx_lookup+2
    txa
    asl
    asl                         ; Carry is the ninth index bit (IDs >=64)
    tax
    lda sfx_lookup+2
    adc #0
    sta sfx_lookup+2
    jsr sfx_lookup
    sta sfx_start
    inx
    jsr sfx_lookup
    sta sfx_start+1
    inx
    jsr sfx_lookup
    sta sfx_repeat
    inx
    jsr sfx_lookup
.pointer:
    sta sfx_repeat+1
    jsr sfx_rewind
    lda #1
    sta sfx_active
    lda #0
    sta sfx_gap
    jsr sfx_step
    clc
    rts
sfx_lookup:
    lda $ffff,x                 ; writable table operand, supports IDs >=64
    rts
sfx_invalid:
    sec
    rts

sfx_set_loop:
    cmp #2
    bcs sfx_invalid
    sta sfx_loop
    clc
    rts

sfx_stop:
    lda #0
    sta TED_SOUND
    sta sfx_active
    sta sfx_loop
    sta sfx_delay
    sta sfx_gap
    rts

; Call once per video frame. At most one audible step is applied.
!zone sfx_tick_zone
sfx_tick:
    lda sfx_ntsc
    beq .logical
    lda sfx_phase
    clc
    adc #50
    cmp #60
    bcc .skip
    sbc #60
    sta sfx_phase
.logical:
    lda sfx_active
    beq .done
    dec sfx_delay
    bne .done
    lda sfx_gap
    beq .next
    lda #0
    sta sfx_gap
    lda sfx_loop
    bne .restart
    jmp sfx_finish
.restart:
    jsr sfx_rewind_loop
.next:
    jmp sfx_step
.skip:
    sta sfx_phase
.done:
    rts

!zone sfx_step_zone
sfx_step:
    ldx #0
    jsr sfx_read
    bne .duration
    lda sfx_loop
    bne +
    jmp sfx_finish
+
    lda sfx_seamless
    beq .pause
    jsr sfx_rewind_loop
    ldx #0
    jsr sfx_read
    bne .duration
    jmp sfx_finish          ; malformed empty repeat streams cannot loop forever
.duration:
    sta sfx_delay
    inx
    jsr sfx_read
    sta TED_FREQ1_LO
    inx
    jsr sfx_read
    and #3
    sta sfx_high
    lda TED_FREQ1_HI
    and #TED_VIDEO_MASK
    ora sfx_high
    sta TED_FREQ1_HI
    inx
    jsr sfx_read
    sta sfx_noise
    lda sfx_variation
    beq .fixed_noise
    lda sfx_random          ; reproducible 8-bit Galois LFSR, nonzero seed
    lsr
    bcc +
    eor #$b8
+
    sta sfx_random
    and #$0f
    eor sfx_noise           ; vary only low frequency bits, stay within 10 bits
    sta sfx_noise
.fixed_noise:
    lda sfx_noise
    sta TED_FREQ2_LO
    inx
    jsr sfx_read
    and #3
    sta sfx_high
    lda TED_FREQ2_HI
    and #$fc
    ora sfx_high
    sta TED_FREQ2_HI
    inx
    jsr sfx_read
    sta TED_SOUND
    clc
    lda sfx_read+1
    adc #6
    sta sfx_read+1
    bcc .done
    inc sfx_read+2
.done:
    rts
.pause:
    lda #0
    sta TED_SOUND
    lda #10                ; 200 ms between one-shot repetitions
    sta sfx_delay
    lda #1
    sta sfx_gap
    rts
sfx_finish:
    lda #0
    sta TED_SOUND
    sta sfx_active
    sta sfx_delay
    sta sfx_gap
    rts                    ; retain user's loop preference at natural end

sfx_rewind:
    lda sfx_start
    sta sfx_read+1
    lda sfx_start+1
    sta sfx_read+2
    rts
sfx_read:
    lda $ffff,x            ; operand is private mutable engine state
    rts
sfx_rewind_loop:
    lda sfx_repeat
    sta sfx_read+1
    lda sfx_repeat+1
    sta sfx_read+2
    rts

sfx_shutdown:
    jsr sfx_stop
    lda sfx_saved
    sta TED_FREQ1_LO
    lda sfx_saved+1
    sta TED_FREQ2_LO
    lda sfx_saved+2
    and #3
    sta sfx_high
    lda TED_FREQ2_HI
    and #$fc
    ora sfx_high
    sta TED_FREQ2_HI
    lda sfx_saved+4
    and #3
    sta sfx_high
    lda TED_FREQ1_HI
    and #TED_VIDEO_MASK
    ora sfx_high
    sta TED_FREQ1_HI
    lda sfx_saved+3
    sta TED_SOUND
    rts
sfx_code_end:

sfx_state:
sfx_saved:    !fill 5,0
sfx_ntsc:     !byte 0
sfx_phase:    !byte 0
sfx_active:   !byte 0
sfx_loop:     !byte 0
sfx_delay:    !byte 0
sfx_gap:      !byte 0
sfx_seamless: !byte 0
sfx_high:     !byte 0
sfx_start:    !word 0
sfx_repeat:   !word 0
sfx_variation: !byte 0
sfx_random:    !byte $a5
sfx_noise:     !byte 0
sfx_state_end:
