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


; Handcrafted catalog: each macro invocation creates separate clock-correct streams.
!macro catalog .clock, ~.export_table {
.fx0: ; 0: jingle-win, 30 ticks
    +step 10, 523, 110, $16, .clock
    +step 10, 659, 110, $16, .clock
    +step 10, 784, 110, $16, .clock
    !byte 0
.fx1: ; 1: jingle-lose, 30 ticks
    +step 10, 784, 110, $16, .clock
    +step 10, 659, 110, $15, .clock
    +step 10, 523, 110, $13, .clock
    !byte 0
.fx2: ; 2: level-up, 20 ticks
    +step 5, 392, 110, $16, .clock
    +step 5, 523, 110, $16, .clock
    +step 5, 659, 110, $16, .clock
    +step 5, 1047, 110, $16, .clock
    !byte 0
.fx3: ; 3: extra-life, 25 ticks
    +step 5, 784, 110, $16, .clock
    +step 5, 1047, 110, $16, .clock
    +step 3, 110, 110, $00, .clock
    +step 6, 784, 110, $16, .clock
    +step 6, 1568, 110, $16, .clock
    !byte 0
.fx4: ; 4: checkpoint, 13 ticks
    +step 6, 523, 110, $14, .clock
    +step 7, 784, 110, $14, .clock
    !byte 0
.fx5: ; 5: coin-pickup, 6 ticks
    +step 2, 1047, 110, $15, .clock
    +step 4, 2093, 110, $14, .clock
    !byte 0
.fx6: ; 6: gem-pickup, 10 ticks
    +step 4, 1319, 110, $14, .clock
    +step 6, 2093, 110, $13, .clock
    !byte 0
.fx7: ; 7: key-pickup, 10 ticks
    +step 6, 880, 906, $34, .clock
    +step 4, 1109, 1140, $32, .clock
    !byte 0
.fx8: ; 8: power-up, 25 ticks
    +step 5, 220, 110, $13, .clock
    +step 5, 330, 110, $16, .clock
    +step 5, 440, 110, $13, .clock
    +step 5, 660, 110, $16, .clock
    +step 5, 880, 110, $15, .clock
    !byte 0
.fx9: ; 9: power-down, 25 ticks
    +step 5, 880, 110, $17, .clock
    +step 5, 660, 110, $15, .clock
    +step 5, 440, 110, $14, .clock
    +step 5, 220, 110, $12, .clock
    +step 5, 130, 110, $11, .clock
    !byte 0
.fx10: ; 10: menu-move, 2 ticks
    +step 2, 1200, 110, $12, .clock
    !byte 0
.fx11: ; 11: menu-select, 6 ticks
    +step 3, 660, 110, $13, .clock
    +step 3, 990, 110, $14, .clock
    !byte 0
.fx12: ; 12: menu-back, 6 ticks
    +step 2, 660, 110, $13, .clock
    +step 4, 330, 110, $12, .clock
    !byte 0
.fx13: ; 13: action-denied, 10 ticks
    +step 4, 146, 110, $15, .clock
    +step 2, 110, 110, $00, .clock
    +step 4, 130, 110, $14, .clock
    !byte 0
.fx14: ; 14: pause-toggle, 8 ticks
    +step 4, 440, 110, $14, .clock
    +step 4, 440, 110, $12, .clock
    !byte 0
.fx15: ; 15: jump, 9 ticks
    +step 3, 300, 110, $14, .clock
    +step 3, 500, 110, $15, .clock
    +step 3, 800, 110, $13, .clock
    !byte 0
.fx16: ; 16: double-jump, 13 ticks
    +step 3, 330, 110, $14, .clock
    +step 3, 550, 110, $15, .clock
    +step 1, 110, 110, $00, .clock
    +step 3, 660, 110, $14, .clock
    +step 3, 1000, 110, $13, .clock
    !byte 0
.fx17: ; 17: landing, 5 ticks
    +step 2, 110, 500, $46, .clock
    +step 2, 110, 300, $43, .clock
    +step 1, 110, 200, $41, .clock
    !byte 0
.fx18: ; 18: bounce, 10 ticks
    +step 2, 300, 110, $14, .clock
    +step 2, 550, 110, $15, .clock
    +step 2, 800, 110, $14, .clock
    +step 2, 550, 110, $13, .clock
    +step 2, 300, 110, $12, .clock
    !byte 0
.fx19: ; 19: fall, 30 ticks
    +step 8, 880, 110, $14, .clock
    +step 8, 660, 110, $14, .clock
    +step 6, 440, 110, $13, .clock
    +step 4, 220, 110, $12, .clock
    +step 4, 110, 110, $11, .clock
    !byte 0
.fx20: ; 20: step-stone, 4 ticks
    +step 1, 110, 900, $45, .clock
    +step 3, 110, 250, $42, .clock
    !byte 0
.fx21: ; 21: step-grass, 5 ticks
    +step 3, 110, 1500, $43, .clock
    +step 2, 110, 800, $42, .clock
    !byte 0
.fx22: ; 22: walk-steps, 20 ticks
    +step 2, 110, 600, $44, .clock
    +step 3, 110, 220, $42, .clock
    +step 5, 110, 110, $00, .clock
    +step 2, 110, 600, $44, .clock
    +step 3, 110, 220, $42, .clock
    +step 5, 110, 110, $00, .clock
    !byte 0
.fx23: ; 23: swim-stroke, 20 ticks
    +step 4, 260, 1000, $54, .clock
    +step 4, 390, 700, $53, .clock
    +step 6, 110, 500, $42, .clock
    +step 6, 110, 300, $41, .clock
    !byte 0
.fx24: ; 24: vogelflug, 25 ticks
    +step 3, 880, 110, $13, .clock
    +step 2, 1175, 110, $12, .clock
    +step 3, 110, 110, $00, .clock
    +step 4, 1320, 110, $13, .clock
    +step 3, 110, 110, $00, .clock
    +step 3, 660, 110, $12, .clock
    +step 2, 990, 110, $12, .clock
    +step 5, 110, 110, $00, .clock
    !byte 0
.fx25: ; 25: laser-shot, 8 ticks
    +step 2, 2200, 110, $15, .clock
    +step 2, 1500, 110, $14, .clock
    +step 2, 900, 110, $13, .clock
    +step 2, 400, 110, $11, .clock
    !byte 0
.fx26: ; 26: blaster-shot, 10 ticks
    +step 2, 1200, 800, $57, .clock
    +step 2, 800, 550, $56, .clock
    +step 2, 500, 350, $54, .clock
    +step 4, 110, 200, $42, .clock
    !byte 0
.fx27: ; 27: machine-gun, 12 ticks
    +step 1, 110, 1500, $46, .clock
    +step 1, 110, 350, $43, .clock
    +step 2, 110, 110, $00, .clock
    +step 1, 110, 1500, $46, .clock
    +step 1, 110, 350, $43, .clock
    +step 2, 110, 110, $00, .clock
    +step 1, 110, 1500, $46, .clock
    +step 1, 110, 350, $43, .clock
    +step 2, 110, 110, $00, .clock
    !byte 0
.fx28: ; 28: explosion-small, 15 ticks
    +step 3, 110, 2000, $47, .clock
    +step 4, 110, 1000, $45, .clock
    +step 4, 110, 500, $43, .clock
    +step 4, 110, 200, $41, .clock
    !byte 0
.fx29: ; 29: explosion-large, 40 ticks
    +step 4, 130, 1800, $57, .clock
    +step 6, 115, 1000, $56, .clock
    +step 10, 110, 650, $45, .clock
    +step 10, 110, 350, $43, .clock
    +step 10, 110, 150, $41, .clock
    !byte 0
.fx30: ; 30: ricochet, 10 ticks
    +step 2, 1800, 110, $15, .clock
    +step 2, 600, 110, $14, .clock
    +step 2, 2200, 110, $14, .clock
    +step 2, 900, 110, $13, .clock
    +step 2, 1600, 110, $11, .clock
    !byte 0
.fx31: ; 31: sword-swing, 8 ticks
    +step 2, 110, 350, $42, .clock
    +step 4, 110, 1800, $44, .clock
    +step 2, 110, 600, $42, .clock
    !byte 0
.fx32: ; 32: sword-hit, 10 ticks
    +step 2, 1100, 1300, $56, .clock
    +step 3, 1080, 500, $54, .clock
    +step 5, 1060, 110, $11, .clock
    !byte 0
.fx33: ; 33: player-hit, 13 ticks
    +step 3, 200, 900, $56, .clock
    +step 3, 160, 500, $55, .clock
    +step 3, 130, 350, $53, .clock
    +step 4, 110, 180, $42, .clock
    !byte 0
.fx34: ; 34: enemy-defeat, 20 ticks
    +step 4, 440, 1200, $55, .clock
    +step 4, 330, 800, $54, .clock
    +step 4, 220, 500, $53, .clock
    +step 2, 110, 110, $00, .clock
    +step 3, 110, 300, $42, .clock
    +step 1, 110, 110, $00, .clock
    +step 2, 110, 180, $41, .clock
    !byte 0
.fx35: ; 35: shield-hit, 13 ticks
    +step 6, 740, 761, $34, .clock
    +step 7, 730, 750, $32, .clock
    !byte 0
.fx36: ; 36: door-open, 20 ticks
    +step 5, 130, 300, $53, .clock
    +step 5, 170, 500, $54, .clock
    +step 5, 230, 750, $53, .clock
    +step 5, 300, 1000, $52, .clock
    !byte 0
.fx37: ; 37: door-close, 10 ticks
    +step 2, 110, 1200, $46, .clock
    +step 3, 110, 500, $44, .clock
    +step 5, 110, 180, $42, .clock
    !byte 0
.fx38: ; 38: switch-click, 2 ticks
    +step 2, 110, 2000, $44, .clock
    !byte 0
.fx39: ; 39: chest-open, 18 ticks
    +step 4, 523, 110, $14, .clock
    +step 5, 659, 110, $14, .clock
    +step 4, 784, 110, $14, .clock
    +step 5, 1047, 110, $13, .clock
    !byte 0
.fx40: ; 40: teleport, 30 ticks
    +step 5, 300, 110, $13, .clock
    +step 5, 110, 1200, $43, .clock
    +step 5, 600, 110, $14, .clock
    +step 5, 110, 1800, $43, .clock
    +step 5, 1200, 900, $54, .clock
    +step 5, 1800, 1500, $52, .clock
    !byte 0
.fx41: ; 41: engine-idle, 20 ticks
    +step 5, 120, 124, $33, .clock
    +step 5, 128, 132, $34, .clock
    +step 5, 120, 124, $33, .clock
    +step 5, 115, 119, $32, .clock
    !byte 0
.fx42: ; 42: engine-boost, 30 ticks
    +step 5, 120, 300, $53, .clock
    +step 5, 180, 500, $54, .clock
    +step 5, 240, 800, $54, .clock
    +step 5, 360, 1200, $55, .clock
    +step 5, 540, 1600, $55, .clock
    +step 5, 800, 2000, $56, .clock
    !byte 0
.fx43: ; 43: alarm, 25 ticks
    +step 12, 660, 110, $16, .clock
    +step 13, 880, 110, $16, .clock
    !byte 0
.fx44: ; 44: timer-tick, 3 ticks
    +step 1, 1500, 110, $13, .clock
    +step 2, 750, 110, $11, .clock
    !byte 0
.fx45: ; 45: countdown-end, 15 ticks
    +step 3, 1200, 110, $15, .clock
    +step 1, 110, 110, $00, .clock
    +step 3, 1200, 110, $15, .clock
    +step 1, 110, 110, $00, .clock
    +step 3, 1200, 110, $15, .clock
    +step 1, 110, 110, $00, .clock
    +step 3, 1800, 110, $16, .clock
    !byte 0
.fx46: ; 46: water-splash, 18 ticks
    +step 3, 110, 2400, $46, .clock
    +step 5, 110, 1500, $44, .clock
    +step 5, 110, 800, $43, .clock
    +step 5, 110, 400, $41, .clock
    !byte 0
.fx47: ; 47: fire-crackle, 30 ticks
    +step 1, 110, 2000, $43, .clock
    +step 2, 110, 110, $00, .clock
    +step 2, 110, 1000, $42, .clock
    +step 3, 110, 110, $00, .clock
    +step 1, 110, 3000, $44, .clock
    +step 1, 110, 110, $00, .clock
    +step 3, 110, 1400, $42, .clock
    +step 4, 110, 110, $00, .clock
    +step 1, 110, 2200, $43, .clock
    +step 2, 110, 110, $00, .clock
    +step 2, 110, 700, $42, .clock
    +step 8, 110, 110, $00, .clock
    !byte 0
.fx48: ; 48: wind-gust, 40 ticks
    +step 5, 110, 400, $41, .clock
    +step 5, 110, 600, $42, .clock
    +step 5, 110, 900, $43, .clock
    +step 5, 110, 1200, $44, .clock
    +step 5, 110, 1000, $44, .clock
    +step 5, 110, 700, $43, .clock
    +step 5, 110, 500, $42, .clock
    +step 5, 110, 350, $41, .clock
    !byte 0
.fx49: ; 49: electric-zap, 13 ticks
    +step 1, 1800, 2500, $56, .clock
    +step 1, 350, 1500, $54, .clock
    +step 1, 1800, 2500, $56, .clock
    +step 1, 350, 1500, $54, .clock
    +step 1, 1800, 2500, $56, .clock
    +step 1, 350, 1500, $54, .clock
    +step 1, 1800, 2500, $56, .clock
    +step 1, 350, 1500, $54, .clock
    +step 5, 110, 800, $42, .clock
    !byte 0
    .export_table = *
    !word .fx0, .fx0
    !word .fx1, .fx1
    !word .fx2, .fx2
    !word .fx3, .fx3
    !word .fx4, .fx4
    !word .fx5, .fx5
    !word .fx6, .fx6
    !word .fx7, .fx7
    !word .fx8, .fx8
    !word .fx9, .fx9
    !word .fx10, .fx10
    !word .fx11, .fx11
    !word .fx12, .fx12
    !word .fx13, .fx13
    !word .fx14, .fx14
    !word .fx15, .fx15
    !word .fx16, .fx16
    !word .fx17, .fx17
    !word .fx18, .fx18
    !word .fx19, .fx19
    !word .fx20, .fx20
    !word .fx21, .fx21
    !word .fx22, .fx22
    !word .fx23, .fx23
    !word .fx24, .fx24
    !word .fx25, .fx25
    !word .fx26, .fx26
    !word .fx27, .fx27
    !word .fx28, .fx28
    !word .fx29, .fx29
    !word .fx30, .fx30
    !word .fx31, .fx31
    !word .fx32, .fx32
    !word .fx33, .fx33
    !word .fx34, .fx34
    !word .fx35, .fx35
    !word .fx36, .fx36
    !word .fx37, .fx37
    !word .fx38, .fx38
    !word .fx39, .fx39
    !word .fx40, .fx40
    !word .fx41, .fx41
    !word .fx42, .fx42
    !word .fx43, .fx43
    !word .fx44, .fx44
    !word .fx45, .fx45
    !word .fx46, .fx46
    !word .fx47, .fx47
    !word .fx48, .fx48
    !word .fx49, .fx49
}
!zone pal_data {
    +catalog 110840, ~sfx_table_pal
}
!zone ntsc_data {
    +catalog 111861, ~sfx_table_ntsc
}
sfx_flags:
    !byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,3,1,0
sfx_durations:
    !byte 30,30,20,25,13,6,10,10,25,25,2,6,6,10,8,9,13,5,10,30,4,5,20,20,25,8,10,12,15,40,10,8,10,13,20,13,20,10,2,18,30,20,30,25,3,15,18,30,40,13
sfx_names:
    !word sfx_name_0
    !word sfx_name_1
    !word sfx_name_2
    !word sfx_name_3
    !word sfx_name_4
    !word sfx_name_5
    !word sfx_name_6
    !word sfx_name_7
    !word sfx_name_8
    !word sfx_name_9
    !word sfx_name_10
    !word sfx_name_11
    !word sfx_name_12
    !word sfx_name_13
    !word sfx_name_14
    !word sfx_name_15
    !word sfx_name_16
    !word sfx_name_17
    !word sfx_name_18
    !word sfx_name_19
    !word sfx_name_20
    !word sfx_name_21
    !word sfx_name_22
    !word sfx_name_23
    !word sfx_name_24
    !word sfx_name_25
    !word sfx_name_26
    !word sfx_name_27
    !word sfx_name_28
    !word sfx_name_29
    !word sfx_name_30
    !word sfx_name_31
    !word sfx_name_32
    !word sfx_name_33
    !word sfx_name_34
    !word sfx_name_35
    !word sfx_name_36
    !word sfx_name_37
    !word sfx_name_38
    !word sfx_name_39
    !word sfx_name_40
    !word sfx_name_41
    !word sfx_name_42
    !word sfx_name_43
    !word sfx_name_44
    !word sfx_name_45
    !word sfx_name_46
    !word sfx_name_47
    !word sfx_name_48
    !word sfx_name_49
SFX_JINGLE_WIN = 0
sfx_name_0: !pet "jingle-win",0
SFX_JINGLE_LOSE = 1
sfx_name_1: !pet "jingle-lose",0
SFX_LEVEL_UP = 2
sfx_name_2: !pet "level-up",0
SFX_EXTRA_LIFE = 3
sfx_name_3: !pet "extra-life",0
SFX_CHECKPOINT = 4
sfx_name_4: !pet "checkpoint",0
SFX_COIN_PICKUP = 5
sfx_name_5: !pet "coin-pickup",0
SFX_GEM_PICKUP = 6
sfx_name_6: !pet "gem-pickup",0
SFX_KEY_PICKUP = 7
sfx_name_7: !pet "key-pickup",0
SFX_POWER_UP = 8
sfx_name_8: !pet "power-up",0
SFX_POWER_DOWN = 9
sfx_name_9: !pet "power-down",0
SFX_MENU_MOVE = 10
sfx_name_10: !pet "menu-move",0
SFX_MENU_SELECT = 11
sfx_name_11: !pet "menu-select",0
SFX_MENU_BACK = 12
sfx_name_12: !pet "menu-back",0
SFX_ACTION_DENIED = 13
sfx_name_13: !pet "action-denied",0
SFX_PAUSE_TOGGLE = 14
sfx_name_14: !pet "pause-toggle",0
SFX_JUMP = 15
sfx_name_15: !pet "jump",0
SFX_DOUBLE_JUMP = 16
sfx_name_16: !pet "double-jump",0
SFX_LANDING = 17
sfx_name_17: !pet "landing",0
SFX_BOUNCE = 18
sfx_name_18: !pet "bounce",0
SFX_FALL = 19
sfx_name_19: !pet "fall",0
SFX_STEP_STONE = 20
sfx_name_20: !pet "step-stone",0
SFX_STEP_GRASS = 21
sfx_name_21: !pet "step-grass",0
SFX_WALK_STEPS = 22
sfx_name_22: !pet "walk-steps",0
SFX_SWIM_STROKE = 23
sfx_name_23: !pet "swim-stroke",0
SFX_VOGELFLUG = 24
sfx_name_24: !pet "vogelflug",0
SFX_LASER_SHOT = 25
sfx_name_25: !pet "laser-shot",0
SFX_BLASTER_SHOT = 26
sfx_name_26: !pet "blaster-shot",0
SFX_MACHINE_GUN = 27
sfx_name_27: !pet "machine-gun",0
SFX_EXPLOSION_SMALL = 28
sfx_name_28: !pet "explosion-small",0
SFX_EXPLOSION_LARGE = 29
sfx_name_29: !pet "explosion-large",0
SFX_RICOCHET = 30
sfx_name_30: !pet "ricochet",0
SFX_SWORD_SWING = 31
sfx_name_31: !pet "sword-swing",0
SFX_SWORD_HIT = 32
sfx_name_32: !pet "sword-hit",0
SFX_PLAYER_HIT = 33
sfx_name_33: !pet "player-hit",0
SFX_ENEMY_DEFEAT = 34
sfx_name_34: !pet "enemy-defeat",0
SFX_SHIELD_HIT = 35
sfx_name_35: !pet "shield-hit",0
SFX_DOOR_OPEN = 36
sfx_name_36: !pet "door-open",0
SFX_DOOR_CLOSE = 37
sfx_name_37: !pet "door-close",0
SFX_SWITCH_CLICK = 38
sfx_name_38: !pet "switch-click",0
SFX_CHEST_OPEN = 39
sfx_name_39: !pet "chest-open",0
SFX_TELEPORT = 40
sfx_name_40: !pet "teleport",0
SFX_ENGINE_IDLE = 41
sfx_name_41: !pet "engine-idle",0
SFX_ENGINE_BOOST = 42
sfx_name_42: !pet "engine-boost",0
SFX_ALARM = 43
sfx_name_43: !pet "alarm",0
SFX_TIMER_TICK = 44
sfx_name_44: !pet "timer-tick",0
SFX_COUNTDOWN_END = 45
sfx_name_45: !pet "countdown-end",0
SFX_WATER_SPLASH = 46
sfx_name_46: !pet "water-splash",0
SFX_FIRE_CRACKLE = 47
sfx_name_47: !pet "fire-crackle",0
SFX_WIND_GUST = 48
sfx_name_48: !pet "wind-gust",0
SFX_ELECTRIC_ZAP = 49
sfx_name_49: !pet "electric-zap",0
sfx_data_end:
!if sfx_durations - sfx_flags != 50 { !error "Exactly 50 flags required" }
!if sfx_names - sfx_durations != 50 { !error "Exactly 50 durations required" }
!if sfx_name_0 - sfx_names != 100 { !error "Exactly 50 names required" }
