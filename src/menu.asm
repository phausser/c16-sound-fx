; Direct screen writes avoid scrolling the 25th line and use no zero page.
menu_init:
    lda #$93
    jsr KERNAL_CHROUT
    jmp menu_draw

; A=PETSCII; navigation consumed, all other keys returned unchanged.
menu_key:
    cmp #$11
    beq .down
    cmp #$91
    beq .up
    cmp #$1d
    beq .right
    cmp #$9d
    beq .left
    rts
.down:
    lda menu_selected
    cmp #49
    beq .done
    inc menu_selected
    jmp .redraw
.up:
    lda menu_selected
    beq .done
    dec menu_selected
    jmp .redraw
.right:
    lda menu_selected
    cmp #40
    bcs .done
    clc
    adc #20
    cmp #50
    bcc +
    lda #49
+
    sta menu_selected
    jmp .redraw
.left:
    lda menu_selected
    cmp #20
    bcc .done
    sec
    sbc #20
    sta menu_selected
.redraw:
    lda #0
    sta input_digits
    jsr menu_draw
.done:
    lda #0
    rts

menu_draw:
    lda #<SCREEN_BASE
    sta menu_store+1
    lda #>SCREEN_BASE
    sta menu_store+2
    ldx #0
.header:
    lda menu_header,x
    jsr menu_put
    inx
    cpx #40
    bne .header
    lda menu_selected
    ldx #0
    cmp #20
    bcc .page
    ldx #20
    cmp #40
    bcc .page
    ldx #40
.page:
    stx menu_item
    txa
    ldx #'1'
    cmp #0
    beq +
    inx
    cmp #20
    beq +
    inx
+
    stx SCREEN_BASE+36
    lda #20
    sta menu_rows
.row:
    lda #' '
    ldx menu_item
    cpx menu_selected
    bne +
    lda #'>'
+
    jsr menu_put
    lda menu_item
    cmp #50
    bcs .blank
    jsr menu_number
    lda #' '
    jsr menu_put
    lda menu_item
    asl
    tax
    lda sfx_names,x
    sta menu_load+1
    lda sfx_names+1,x
    sta menu_load+2
    lda #4
    sta menu_column
    ldy #0
.name:
menu_load:
    lda $ffff,y
    beq .pad
    and #$3f                 ; catalog PETSCII uppercase -> screen codes
    jsr menu_put
    inc menu_column
    iny
    bne .name
.blank:
    lda #1
    sta menu_column
.pad:
    lda #' '
    jsr menu_put
    inc menu_column
    lda menu_column
    cmp #40
    bne .pad
    inc menu_item
    dec menu_rows
    bne .row
    ldx #0
.footer:
    lda menu_footer,x
    jsr menu_put
    inx
    cpx #160
    bne .footer
    jmp menu_status

menu_number:
    ldx #'0'
.tens:
    cmp #10
    bcc .units
    sec
    sbc #10
    inx
    bne .tens
.units:
    pha
    txa
    jsr menu_put
    pla
    clc
    adc #'0'
    jmp menu_put

menu_put:
menu_store:
    sta SCREEN_BASE
    inc menu_store+1
    bne +
    inc menu_store+2
+
    rts

menu_status:
    lda #<(SCREEN_BASE+21*40+4)
    sta menu_store+1
    lda #>(SCREEN_BASE+21*40+4)
    sta menu_store+2
    lda input_digits
    bne +
    lda menu_selected
    jsr menu_number
+
    lda sfx_active
    clc
    adc #'0'
    sta SCREEN_BASE+21*40+15
    lda sfx_loop
    clc
    adc #'0'
    sta SCREEN_BASE+21*40+23
    rts
menu_selected: !byte 0
menu_item: !byte 0
menu_rows: !byte 0
menu_column: !byte 0
menu_header:
    !scr "c16 sound fx - 50 sound effects     1/3 "
menu_footer:
    !scr "id: 00 playing: 0 loop: 0               "
    !scr "cursor: select/page  return/space: play "
    !scr "l: loop  s/run-stop: stop  q: basic     "
    !scr "00-49: direct id  p: pal  n: ntsc       "
!if * - menu_footer != 160 { !error "Footer must fill four rows" }
