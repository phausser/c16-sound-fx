; Step format: duration, freq1 low/high, freq2 low/high, control.
; Duration 0 ends stream. Each ordinary step takes 1..255 logical ticks.
; PAL/NTSC values are rounded from MOS TED data sheet constants.
!macro step .ticks, .hz1, .hz2, .control, .clock {
    !if .ticks < 1 { !error "Step duration must be positive" }
    !if .ticks > 255 { !error "Step duration exceeds byte" }
    !if (.control & $0f) > 8 { !error "Volume exceeds TED range" }
    !if (.control & $60) = $60 { !error "Tone 2 overrides noise" }
    !if (.control & $80) != 0 { !error "Reload bit not allowed in steps" }
    .n1 = 1024 - (.clock + .hz1 / 2) / .hz1
    .n2 = 1024 - (.clock + .hz2 / 2) / .hz2
    !if .n1 < 0 { !error "Frequency 1 too low" }
    !if .n1 > 1023 { !error "Frequency 1 too high" }
    !if .n2 < 0 { !error "Frequency 2 too low" }
    !if .n2 > 1023 { !error "Frequency 2 too high" }
    !byte .ticks, <.n1, >.n1, <.n2, >.n2, .control
}

!macro prototypes .clock, ~.export_table {
.win:
    +step 10, 523, 110, $16, .clock
    +step 10, 659, 110, $16, .clock
    +step 10, 784, 110, $16, .clock
    !byte 0
.landing:
    +step 2, 110, 500, $46, .clock
    +step 2, 110, 300, $43, .clock
    +step 1, 110, 200, $41, .clock
    !byte 0
.blaster:
    +step 2, 1200, 800, $57, .clock
    +step 2, 800, 550, $56, .clock
    +step 2, 500, 350, $54, .clock
    +step 4, 200, 200, $42, .clock
    !byte 0
.alarm:
    +step 12, 660, 110, $16, .clock
    +step 13, 880, 110, $16, .clock
    !byte 0
.empty:
    !byte 0
.table:
    .export_table = *
    !for .id, 0, 49 {
        !if .id = 0 { !word .win, .win } else {
        !if .id = 17 { !word .landing, .landing } else {
        !if .id = 26 { !word .blaster, .blaster } else {
        !if .id = 43 { !word .alarm, .alarm } else { !word .empty, .empty }
        } } }
    }
}
!zone pal_data {
    +prototypes 110840, ~sfx_table_pal
}
!zone ntsc_data {
    +prototypes 111861, ~sfx_table_ntsc
}
sfx_flags:
    !for .id, 0, 49 {
        !if .id = 43 { !byte 1 } else { !byte 0 }
    }
sfx_data_end:
