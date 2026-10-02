; Catalog test controls only. Full selection menu follows in step 4.
menu_init:
    lda #$93                  ; clear through KERNAL, preserve video setup
    jsr KERNAL_CHROUT
    ldx #0
.print:
    lda startup_text,x
    beq .done
    txa
    pha
    lda startup_text,x
    jsr KERNAL_CHROUT
    pla
    tax
    inx
    bne .print
.done:
    rts
startup_text:
    !pet "c16 sound fx",13,13
    !pet "step 3: 50 sound effects",13,13
    !pet "id: 00",13
    !pet "type 00-49 then return/space",13,13
    !pet "l loop     s stop     q basic",13
    !pet "p pal      n ntsc (match emulator)",13
    !pet "default: pal / loop off",13,0
!if * - startup_text > 255 { !error "Startup text exceeds index range" }
