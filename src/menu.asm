; Prototype controls only. Full selection menu follows in step 4.
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
    !pet "STEP 2: SOUND ENGINE PROTOTYPES",13,13
    !pet "1 WIN      2 LANDING",13
    !pet "3 BLASTER  4 ALARM",13,13
    !pet "L LOOP     S STOP     Q BASIC",13
    !pet "P PAL      N NTSC (MATCH EMULATOR)",13
    !pet "DEFAULT: PAL / LOOP OFF",13,0
!if * - startup_text > 255 { !error "Startup text exceeds index range" }
