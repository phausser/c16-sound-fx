; Step 1 startup screen only. Full selection menu follows in step 4.
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
    !pet "C16 SOUND FX",13,13
    !pet "STEP 1: BUILD AND START OK",13
    !pet "16 KB RAM / PAL",13,13
    !pet "SOUND ENGINE FOLLOWS IN STEP 2",13
    !pet "Q: RETURN TO BASIC",13,0
!if * - startup_text > 255 { !error "Startup text exceeds index range" }
