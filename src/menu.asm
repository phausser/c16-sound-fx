; Direct screen writes avoid scrolling the 25th line and use no zero page.
menu_init:
    lda KERNAL_REPEAT
    sta menu_saved_repeat
    lda #$40
    sta KERNAL_REPEAT
    lda #$93
    jsr KERNAL_CHROUT
    lda #0
    sta TED_BACKGROUND
    sta TED_BORDER
    lda #TED_WHITE
    ldx #0
.colors:
    sta ATTRIBUTE_BASE,x
    sta ATTRIBUTE_BASE+$100,x
    sta ATTRIBUTE_BASE+$200,x
    inx
    bne .colors
    ldx #0
.tail:
    sta ATTRIBUTE_BASE+$300,x
    inx
    cpx #232                  ; exactly 1000 visible character attributes
    bne .tail
    jmp menu_draw

; A=PETSCII; navigation consumed, all other keys returned unchanged.
menu_key:
    cmp #'H'
    bne +
    lda menu_help
    eor #1
    sta menu_help
    lda #0
    sta menu_held_key
    jsr menu_draw
    lda #0
    rts
+
    ldx menu_help
    beq +
    cmp #13
    beq .close_help
    cmp #' '
    beq .close_help
    cmp #'0'
    bcc .help_action
    cmp #'9'+1
    bcc .help_ignore
.help_action:
    cmp #$11
    beq .help_ignore
    cmp #$91
    beq .help_ignore
    cmp #$1d
    beq .help_ignore
    cmp #$9d
    bne +
.help_ignore:
    lda #0
    rts
.close_help:
    lda #0
    sta menu_help
    jsr menu_draw
    lda #0
    rts
+
    cmp #$11
    beq .navigation
    cmp #$91
    beq .navigation
    cmp #$1d
    beq .navigation
    cmp #$9d
    beq .navigation
    rts
.navigation:
    sta menu_held_key
    lda KERNAL_KEY_SCAN
    sta menu_held_scan
    lda KERNAL_SHIFT
    sta menu_held_shift
    ldx sfx_ntsc
    lda menu_repeat_delay,x
    sta menu_repeat_timer
    lda menu_held_key
menu_navigate:
    cmp #$11
    beq .down
    cmp #$91
    beq .up
    cmp #$1d
    beq .right
    jmp .left
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
    jsr menu_page_index
    cpx #2
    beq .done
    lda menu_selected
    sec
    sbc menu_page_starts,x
    inx
    clc
    adc menu_page_starts,x
    cmp menu_page_ends,x
    bcc +
    lda menu_page_ends,x
    sec
    sbc #1
+
    sta menu_selected
    jmp .redraw
.left:
    jsr menu_page_index
    cpx #0
    beq .done
    lda menu_selected
    sec
    sbc menu_page_starts,x
    dex
    clc
    adc menu_page_starts,x
    cmp menu_page_ends,x
    bcc +
    lda menu_page_ends,x
    sec
    sbc #1
+
    sta menu_selected
.redraw:
    lda #0
    sta input_digits
    jsr menu_draw
.done:
    lda #0
    rts

menu_page_index:
    ldx #0
    lda menu_selected
    cmp #20
    bcc +
    inx
    cmp #40
    bcc +
    inx
+
    rts

menu_draw:
    lda menu_help
    beq +
    jmp menu_draw_help
+
    lda #<SCREEN_BASE
    sta menu_store+1
    lda #>SCREEN_BASE
    sta menu_store+2
    ldx #0
.header:
    lda menu_header,x
    ora #$80
    jsr menu_put
    inx
    cpx #40
    bne .header
    jsr menu_page_index
    lda menu_page_starts,x
    sta menu_item
    lda menu_page_ends,x
    sta menu_page_end
    txa
    clc
    adc #'1'
    ora #$80
    sta SCREEN_BASE+36
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
    cmp menu_page_end
    bcs .blank
    tax
    lda menu_order,x
    sta menu_effect_id
    jsr menu_number
    lda #' '
    jsr menu_put
    lda menu_effect_id
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
    beq .category
    and #$3f                 ; catalog PETSCII uppercase -> screen codes
    jsr menu_put
    inc menu_column
    iny
    bne .name
.category:
    lda #' '
    jsr menu_put
    inc menu_column
    ldx menu_item
    lda menu_categories,x
    asl
    tax
    lda menu_category_names,x
    sta menu_category_load+1
    lda menu_category_names+1,x
    sta menu_category_load+2
    ldy #0
.category_text:
menu_category_load:
    lda $ffff,y
    beq .pad
    jsr menu_put
    inc menu_column
    iny
    bne .category_text
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
    beq +
    jmp .row
+
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
    ldx menu_selected
    lda menu_order,x
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
    !scr "                                        "
    !scr "                                        "
    !scr "h: help                                 "
!if * - menu_footer != 160 { !error "Footer must fill four rows" }
menu_help: !byte 0
menu_page_end: !byte 20
menu_effect_id: !byte 0
menu_page_starts: !byte 0,20,40
menu_page_ends: !byte 20,40,50

menu_draw_help:
    lda #<SCREEN_BASE
    sta menu_store+1
    lda #>SCREEN_BASE
    sta menu_store+2
    lda #<menu_help_text
    sta menu_help_load+1
    lda #>menu_help_text
    sta menu_help_load+2
    ldx #0
    ldy #0
menu_help_copy:
menu_help_load:
    lda $ffff
    cpx #0
    bne +
    ora #$80
+
    jsr menu_put
    inc menu_help_load+1
    bne +
    inc menu_help_load+2
+
    iny
    cpy #40
    bne menu_help_copy
    ldy #0
    inx
    cpx #25
    bne menu_help_copy
    jmp menu_status
menu_help_text:
    !scr "c16 sound fx - help                     "
    !scr "                                        "
    !scr "cursor up/down: select effect           "
    !scr "cursor left/right: change page          "
    !scr "                                        "
    !scr "return / space: start or restart        "
    !scr "00-49 then return: start by api id      "
    !scr "                                        "
    !scr "l: toggle loop                          "
    !scr "s / run-stop: stop sound and loop       "
    !scr "                                        "
    !scr "p: pal timing / n: ntsc timing          "
    !scr "match timing to emulator or hardware    "
    !scr "                                        "
    !scr "q: exit to basic                        "
    !scr "                                        "
    !scr "h / return / space: back to catalog     "
    !scr "                                        "
    !scr "navigation does not change playing fx   "
    !scr "                                        "
    !scr "                                        "
    !scr "id: 00 playing: 0 loop: 0               "
    !scr "                                        "
    !scr "                                        "
    !scr "                                        "
!if * - menu_help_text != 1000 { !error "Help must fill 25 rows" }

; Called once per video frame. No held actions are synthesized.
menu_keyboard_tick:
    jsr KERNAL_STOP
    bne +
    jsr sfx_stop
+
    lda menu_held_key
    beq menu_keyboard_done
    lda KERNAL_KEY_SCAN
    cmp #$40
    beq .release
    cmp menu_held_scan
    bne .release
    lda KERNAL_SHIFT
    cmp menu_held_shift
    bne .release
    dec menu_repeat_timer
    bne menu_keyboard_done
    ldx sfx_ntsc
    lda menu_repeat_interval,x
    sta menu_repeat_timer
    lda menu_held_key
    jmp menu_navigate
.release:
    lda #0
    sta menu_held_key
menu_keyboard_done:
    rts
menu_shutdown:
    lda menu_saved_repeat
    sta KERNAL_REPEAT
    rts
menu_saved_repeat: !byte 0
menu_held_key: !byte 0
menu_held_scan: !byte $40
menu_held_shift: !byte 0
menu_repeat_timer: !byte 0
menu_repeat_delay: !byte 25,30
menu_repeat_interval: !byte 5,6

menu_order:
    !byte 0,1,2,3,4,8,9,39,5,6,7,10,11,12,13,14,43,44,45,15,16,17,18,19,20,21,22,23,24,41,42,46,47,48,36,37,38,40,25,26,27,30,28,29,31,32,33,34,35,49
menu_categories:
    !byte 0,0,0,0,0,0,0,0,1,1,1,2,2,2,2,2,3,3,3,4,4,4,4,4,4,4,4,4,4,5,5,6,6,6,7,7,7,7,8,8,8,8,9,9,10,10,10,10,10,10
menu_category_names:
    !word menu_category_0,menu_category_1,menu_category_2,menu_category_3,menu_category_4,menu_category_5,menu_category_6,menu_category_7,menu_category_8,menu_category_9,menu_category_10
menu_category_0: !scr "(jingle)"
    !byte 0
menu_category_1: !scr "(sammeln)"
    !byte 0
menu_category_2: !scr "(menu)"
    !byte 0
menu_category_3: !scr "(signal)"
    !byte 0
menu_category_4: !scr "(bewegung)"
    !byte 0
menu_category_5: !scr "(fahrgeraeusch)"
    !byte 0
menu_category_6: !scr "(umgebung)"
    !byte 0
menu_category_7: !scr "(objekt)"
    !byte 0
menu_category_8: !scr "(schuss)"
    !byte 0
menu_category_9: !scr "(explosion)"
    !byte 0
menu_category_10: !scr "(kampf)"
    !byte 0
