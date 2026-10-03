; Direct screen writes avoid scrolling the 25th line and use no zero page.
menu_init:
    lda KERNAL_REPEAT
    sta menu_saved_repeat
    lda #$40
    sta KERNAL_REPEAT
    lda #$93
    jsr KERNAL_CHROUT
    lda #TED_BG_COLOR
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
    cmp #SFX_COUNT-1
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
    cpx #SFX_PAGE_COUNT-1
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
.next_page:
    cmp menu_page_ends,x
    bcc +
    inx
    bne .next_page
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
    sta SCREEN_BASE+37
    lda #24
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
    lda #4
    ldx menu_effect_id
    cpx #100
    bcc +
    lda #5                   ; three-digit ID shifts category, not name
+
    sta menu_column
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
    beq .category_pad
    jsr menu_put
    inc menu_column
    iny
    bne .category_text
.category_pad:
    lda menu_column
    cmp #20
    beq .name_setup
    lda #' '
    jsr menu_put
    inc menu_column
    lda menu_column
    cmp #20
    bne .category_pad
.name_setup:
    lda menu_effect_id
    asl
    tax
    lda sfx_names,x
    sta menu_load+1
    lda sfx_names+1,x
    sta menu_load+2
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
    beq +
    jmp .row
+
    jmp menu_status

menu_number:
    cmp #100
    bcc .two_digits
    sbc #100                 ; carry set
    pha
    lda #'1'
    jsr menu_put
    pla
.two_digits:
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
    ldx #0
    lda sfx_loop
    beq +
    ldx #3
+
    ldy #0
menu_loop_text:
    lda menu_loop_status,x
    ora #$80
    sta SCREEN_BASE+21,y
    inx
    iny
    cpy #3
    bne menu_loop_text
    rts
menu_loop_status: !scr "offon "
menu_selected: !byte 0
menu_item: !byte 0
menu_rows: !byte 0
menu_column: !byte 0
menu_header:
    !scr "c=16 sound fx  loop: off  (h)elp     1/"
    !byte '0'+SFX_PAGE_COUNT
menu_help: !byte 0
menu_page_end: !byte 24
menu_effect_id: !byte 0
menu_page_starts:
    !for .page, 0, SFX_PAGE_COUNT-1 { !byte .page*24 }
menu_page_ends:
    !for .page, 1, SFX_PAGE_COUNT {
        !if .page*24 > SFX_COUNT { !byte SFX_COUNT } else { !byte .page*24 }
    }

menu_draw_help:
    lda #<SCREEN_BASE
    sta menu_store+1
    lda #>SCREEN_BASE
    sta menu_store+2
    lda #<menu_help_text
    sta menu_help_load+1
    lda #>menu_help_text
    sta menu_help_load+2
    ldx #0                    ; row; row 0 is the inverse header
menu_help_row:
    ldy #0                    ; column
menu_help_copy:
menu_help_load:
    lda $ffff
    beq menu_help_end
    jsr menu_help_put
    jsr menu_help_next
    iny
    bne menu_help_copy
menu_help_end:
    jsr menu_help_next        ; skip line terminator
menu_help_pad:
    cpy #40
    beq menu_help_line_done
    lda #' '
    jsr menu_help_put
    iny
    bne menu_help_pad
menu_help_line_done:
    inx
    cpx #25
    bne menu_help_row
    jmp menu_status
menu_help_put:
    cpx #0
    bne +
    ora #$80
+
    jmp menu_put
menu_help_next:
    inc menu_help_load+1
    bne +
    inc menu_help_load+2
+
    rts
; Zero-terminated rows, padded with spaces to 40 columns when drawn.
!macro help_line .text {
    .start = *
    !scr .text
    !if * - .start > 40 { !error "Help row exceeds 40 columns" }
    !byte 0
}
menu_help_text:
    +help_line "c=16 sound fx  loop: off  (h)elp     hlp"
    !byte 0
    +help_line "cursor up/down: select effect"
    +help_line "cursor left/right: change page"
    !byte 0
    +help_line "return / space: start or restart"
    +help_line "0-104 then return: start by api id"
    !byte 0
    +help_line "l: toggle loop"
    +help_line "s / run-stop: stop sound and loop"
    !byte 0
    +help_line "p: pal timing / n: ntsc timing"
    +help_line "match timing to emulator or hardware"
    !byte 0
    +help_line "q: exit to basic"
    !byte 0
    +help_line "h / return / space: back to catalog"
    !byte 0
    +help_line "navigation does not change playing fx"
    !byte 0
    !byte 0
    !byte 0
    !byte 0
    !byte 0
    !byte 0
!if * - menu_help_text > 1000 { !error "Help text too large" }

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
    !byte 0,1,2,3,4,8,9,39,69,75,76,77,78,79,82,83,84,94,98,5,6,7,51,54,64,67,80,92,93,10,11,12,13,14,43,44,45,57,66,68,102,103,15,16,17,18,19,20,21,22,23,24,70,71,72,73,74,81,88,89,90,95,97,41,42,62,99,46,47,48,63,104,36,37,38,40,53,60,61,87,96,100,101,25,26,27,30,50,52,56,58,59,65,85,28,29,31,32,33,34,35,49,55,86,91
menu_categories:
    !byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,5,5,5,5,6,6,6,6,6,7,7,7,7,7,7,7,7,7,7,7,8,8,8,8,8,8,8,8,8,8,8,9,9,10,10,10,10,10,10,10,10,10
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

!if menu_categories-menu_order != SFX_COUNT { !error "Menu order count" }
!if menu_category_names-menu_categories != SFX_COUNT { !error "Menu category count" }
