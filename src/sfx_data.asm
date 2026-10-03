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
.fx50: ; 50: im-robot, 7 ticks; Impossible Mission: Roboterlaser
    +step 1, 2100, 110, $16, .clock
    +step 1, 1700, 110, $16, .clock
    +step 1, 1300, 110, $15, .clock
    +step 1, 950, 110, $15, .clock
    +step 1, 700, 110, $14, .clock
    +step 2, 450, 110, $12, .clock
    !byte 0
.fx51: ; 51: boulder-diamond, 3 ticks; pickup contour from SID analysis
    +step 1, 320, 110, $14, .clock
    +step 1, 320, 110, $12, .clock
    +step 1, 320, 110, $11, .clock
    !byte 0
.fx52: ; 52: uridium-laser, 7 ticks; Uridium: Laserschuss
    +step 1, 3200, 110, $16, .clock
    +step 1, 2400, 110, $15, .clock
    +step 1, 1800, 110, $15, .clock
    +step 1, 1200, 110, $14, .clock
    +step 1, 800, 110, $13, .clock
    +step 2, 400, 110, $11, .clock
    !byte 0
.fx53: ; 53: paradroid-link, 13 ticks; Paradroid: Transfer
    +step 2, 330, 660, $34, .clock
    +step 2, 440, 880, $35, .clock
    +step 2, 660, 1320, $35, .clock
    +step 2, 440, 880, $34, .clock
    +step 2, 880, 1760, $34, .clock
    +step 3, 1320, 2640, $32, .clock
    !byte 0
.fx54: ; 54: wizball-pickup, 13 ticks; Wizball: Pickup
    +step 2, 440, 447, $34, .clock
    +step 2, 660, 669, $35, .clock
    +step 2, 880, 891, $35, .clock
    +step 2, 1320, 1335, $34, .clock
    +step 2, 1760, 1778, $33, .clock
    +step 3, 2200, 2221, $31, .clock
    !byte 0
.fx55: ; 55: karate-punch, 8 ticks; International Karate: Treffer
    +step 1, 220, 1800, $57, .clock
    +step 2, 150, 650, $56, .clock
    +step 2, 120, 300, $54, .clock
    +step 3, 110, 160, $41, .clock
    !byte 0
.fx56: ; 56: ninja-shuriken, 8 ticks; The Last Ninja: Shuriken
    +step 1, 1700, 3200, $54, .clock
    +step 2, 1200, 2400, $55, .clock
    +step 2, 800, 1600, $53, .clock
    +step 3, 500, 900, $51, .clock
    !byte 0
.fx57: ; 57: lemmings-ohno, 29 ticks; Lemmings: Oh no
    +step 4, 620, 1240, $34, .clock
    +step 3, 580, 1160, $35, .clock
    +step 3, 530, 1060, $33, .clock
    +step 2, 110, 110, $00, .clock
    +step 3, 820, 1640, $35, .clock
    +step 4, 700, 1400, $35, .clock
    +step 5, 560, 1120, $34, .clock
    +step 5, 420, 840, $32, .clock
    !byte 0
.fx58: ; 58: worms-bazooka, 25 ticks; Worms: Bazooka
    +step 2, 180, 1600, $57, .clock
    +step 3, 240, 2000, $55, .clock
    +step 3, 330, 1500, $53, .clock
    +step 3, 440, 900, $52, .clock
    +step 2, 110, 110, $00, .clock
    +step 2, 120, 650, $57, .clock
    +step 4, 110, 350, $45, .clock
    +step 6, 110, 180, $42, .clock
    !byte 0
.fx59: ; 59: turrican-beam, 12 ticks; Turrican II: Strahl
    +step 2, 440, 2200, $54, .clock
    +step 2, 660, 2800, $55, .clock
    +step 2, 880, 3400, $54, .clock
    +step 2, 660, 2800, $53, .clock
    +step 2, 440, 2200, $54, .clock
    +step 2, 550, 2500, $55, .clock
    !byte 0
.fx60: ; 60: pinball-bumper, 10 ticks; Pinball Dreams: Bumper
    +step 1, 330, 337, $36, .clock
    +step 2, 660, 671, $35, .clock
    +step 2, 880, 894, $34, .clock
    +step 2, 660, 671, $33, .clock
    +step 3, 440, 447, $31, .clock
    !byte 0
.fx61: ; 61: alienbreed-door, 18 ticks; Alien Breed: Tuer
    +step 2, 140, 400, $53, .clock
    +step 3, 180, 600, $54, .clock
    +step 3, 240, 900, $55, .clock
    +step 3, 330, 1300, $54, .clock
    +step 3, 440, 1700, $53, .clock
    +step 4, 660, 2200, $51, .clock
    !byte 0
.fx62: ; 62: lotus-engine, 12 ticks; Lotus Turbo Challenge 2: Motor
    +step 2, 130, 260, $34, .clock
    +step 2, 138, 276, $35, .clock
    +step 2, 146, 292, $34, .clock
    +step 2, 155, 310, $35, .clock
    +step 2, 146, 292, $34, .clock
    +step 2, 138, 276, $33, .clock
    !byte 0
.fx63: ; 63: mc-creeper, 50 ticks; Minecraft: Creeper-Zischen und Explosion
    +step 5, 110, 2200, $41, .clock
    +step 5, 110, 2600, $42, .clock
    +step 5, 110, 3000, $43, .clock
    +step 5, 110, 3400, $44, .clock
    +step 5, 110, 3800, $45, .clock
    +step 2, 110, 900, $48, .clock
    +step 4, 110, 650, $46, .clock
    +step 6, 110, 400, $44, .clock
    +step 8, 110, 220, $42, .clock
    +step 5, 110, 140, $41, .clock
    !byte 0
.fx64: ; 64: mc-xp, 11 ticks; Minecraft: Erfahrungsorb
    +step 2, 880, 1320, $33, .clock
    +step 2, 1320, 1980, $34, .clock
    +step 3, 1760, 2640, $33, .clock
    +step 4, 1320, 1980, $31, .clock
    !byte 0
.fx65: ; 65: portal-shot, 14 ticks; Portal 2: Portal-Schuss
    +step 1, 170, 1600, $56, .clock
    +step 2, 300, 2400, $55, .clock
    +step 2, 600, 3200, $54, .clock
    +step 2, 1200, 1800, $53, .clock
    +step 3, 800, 1000, $52, .clock
    +step 4, 400, 500, $51, .clock
    !byte 0
.fx66: ; 66: halo-recharge, 32 ticks; Halo Infinite: Schildaufladung
    +step 4, 440, 1800, $51, .clock
    +step 4, 554, 2200, $52, .clock
    +step 4, 659, 2600, $53, .clock
    +step 4, 880, 3000, $54, .clock
    +step 4, 1109, 3400, $54, .clock
    +step 4, 1319, 3800, $53, .clock
    +step 3, 1760, 110, $13, .clock
    +step 5, 1760, 110, $11, .clock
    !byte 0
.fx67: ; 67: fortnite-shield, 21 ticks; Fortnite: Schildtrank
    +step 2, 180, 650, $53, .clock
    +step 2, 260, 900, $54, .clock
    +step 2, 180, 650, $52, .clock
    +step 2, 330, 1100, $54, .clock
    +step 2, 220, 750, $52, .clock
    +step 3, 660, 1800, $53, .clock
    +step 3, 988, 110, $14, .clock
    +step 5, 1319, 110, $12, .clock
    !byte 0
.fx68: ; 68: apex-ping, 12 ticks; Apex Legends: Ping
    +step 2, 1047, 1568, $33, .clock
    +step 3, 1568, 2352, $34, .clock
    +step 3, 2093, 3136, $32, .clock
    +step 4, 1568, 2352, $31, .clock
    !byte 0
.fx69: ; 69: zelda-discovery, 28 ticks; Zelda Breath of the Wild: Entdeckung
    +step 3, 659, 110, $14, .clock
    +step 3, 784, 110, $14, .clock
    +step 3, 988, 110, $15, .clock
    +step 3, 1319, 110, $15, .clock
    +step 4, 1568, 110, $14, .clock
    +step 5, 1976, 110, $13, .clock
    +step 7, 2637, 110, $11, .clock
    !byte 0
.fx70: ; 70: flap-soft, 12 ticks, intentional wing-rest pause
    +step 1, 110, 1500, $42, .clock
    +step 2, 110, 1100, $43, .clock
    +step 2, 110, 700, $42, .clock
    +step 2, 110, 400, $41, .clock
    +step 5, 110, 110, $00, .clock
    !byte 0
.fx71: ; 71: flap-snappy, 8 ticks, intentional wing-rest pause
    +step 1, 440, 2400, $54, .clock
    +step 1, 330, 1600, $54, .clock
    +step 1, 220, 950, $53, .clock
    +step 1, 160, 500, $51, .clock
    +step 4, 110, 110, $00, .clock
    !byte 0
.fx72: ; 72: flap-double, 16 ticks, intentional wing-rest pause
    +step 1, 110, 2000, $43, .clock
    +step 2, 110, 1200, $42, .clock
    +step 2, 110, 110, $00, .clock
    +step 1, 110, 1700, $44, .clock
    +step 2, 110, 850, $42, .clock
    +step 2, 110, 450, $41, .clock
    +step 6, 110, 110, $00, .clock
    !byte 0
.fx73: ; 73: flap-flutter, 12 ticks, intentional wing-rest pause
    +step 1, 330, 1800, $53, .clock
    +step 1, 260, 900, $52, .clock
    +step 1, 110, 110, $00, .clock
    +step 1, 390, 2100, $53, .clock
    +step 1, 300, 1050, $52, .clock
    +step 1, 110, 110, $00, .clock
    +step 1, 440, 2400, $53, .clock
    +step 1, 330, 1200, $52, .clock
    +step 4, 110, 110, $00, .clock
    !byte 0
.fx74: ; 74: flap-chirp, 16 ticks, intentional wing-rest pause
    +step 1, 700, 1600, $52, .clock
    +step 2, 950, 1100, $53, .clock
    +step 2, 1300, 650, $52, .clock
    +step 1, 110, 110, $00, .clock
    +step 1, 1700, 110, $13, .clock
    +step 2, 2100, 110, $12, .clock
    +step 1, 1600, 110, $11, .clock
    +step 6, 110, 110, $00, .clock
    !byte 0
.fx75: ; 75: life-fall, 14 ticks, life lost one-shot
    +step 2, 900, 1800, $54, .clock
    +step 3, 600, 1200, $53, .clock
    +step 4, 350, 700, $52, .clock
    +step 5, 140, 300, $51, .clock
    !byte 0
.fx76: ; 76: life-thud, 14 ticks, life lost one-shot
    +step 2, 130, 1600, $55, .clock
    +step 3, 120, 700, $54, .clock
    +step 4, 115, 300, $52, .clock
    +step 5, 110, 180, $11, .clock
    !byte 0
.fx77: ; 77: life-sigh, 22 ticks, life lost one-shot
    +step 4, 440, 460, $33, .clock
    +step 5, 370, 390, $33, .clock
    +step 6, 294, 310, $32, .clock
    +step 7, 220, 230, $31, .clock
    !byte 0
.fx78: ; 78: life-sad, 26 ticks, life lost one-shot
    +step 5, 392, 110, $13, .clock
    +step 1, 110, 110, $00, .clock
    +step 5, 330, 110, $13, .clock
    +step 1, 110, 110, $00, .clock
    +step 7, 262, 110, $12, .clock
    +step 7, 196, 110, $11, .clock
    !byte 0
.fx79: ; 79: life-wobble, 24 ticks, life lost one-shot
    +step 3, 330, 345, $34, .clock
    +step 3, 294, 308, $33, .clock
    +step 3, 311, 326, $33, .clock
    +step 4, 247, 260, $32, .clock
    +step 4, 262, 275, $32, .clock
    +step 7, 165, 174, $31, .clock
    !byte 0
.fx80: ; 80: mario-coin, 14 ticks; Super Mario Bros.: Muenze
    +step 2, 1109, 110, $15, .clock
    +step 4, 1480, 110, $15, .clock
    +step 4, 1480, 110, $13, .clock
    +step 4, 1480, 110, $11, .clock
    !byte 0
.fx81: ; 81: mario-jump, 11 ticks; Super Mario Bros.: Sprung
    +step 1, 350, 110, $14, .clock
    +step 1, 450, 110, $15, .clock
    +step 1, 560, 110, $15, .clock
    +step 1, 680, 110, $14, .clock
    +step 1, 800, 110, $14, .clock
    +step 2, 950, 110, $13, .clock
    +step 2, 1100, 110, $12, .clock
    +step 2, 1200, 110, $11, .clock
    !byte 0
.fx82: ; 82: mario-1up, 18 ticks; Super Mario Bros.: Extraleben
    +step 3, 1047, 110, $15, .clock
    +step 3, 1319, 110, $15, .clock
    +step 3, 2093, 110, $15, .clock
    +step 3, 1760, 110, $15, .clock
    +step 3, 1976, 110, $14, .clock
    +step 3, 2637, 110, $13, .clock
    !byte 0
.fx83: ; 83: mario-mushroom, 30 ticks; Super Mario Bros.: Power-up
    +step 2, 392, 110, $14, .clock
    +step 2, 523, 110, $15, .clock
    +step 2, 659, 110, $15, .clock
    +step 2, 440, 110, $14, .clock
    +step 2, 587, 110, $15, .clock
    +step 2, 740, 110, $15, .clock
    +step 2, 494, 110, $14, .clock
    +step 2, 659, 110, $15, .clock
    +step 2, 831, 110, $15, .clock
    +step 2, 523, 110, $14, .clock
    +step 2, 698, 110, $15, .clock
    +step 2, 880, 110, $15, .clock
    +step 2, 587, 110, $14, .clock
    +step 2, 784, 110, $14, .clock
    +step 2, 988, 110, $13, .clock
    !byte 0
.fx84: ; 84: mario-pipe, 18 ticks; Super Mario Bros.: Rohr/Schrumpfen
    +step 1, 880, 110, $15, .clock
    +step 1, 659, 110, $15, .clock
    +step 1, 523, 110, $15, .clock
    +step 1, 110, 110, $00, .clock
    +step 1, 740, 110, $15, .clock
    +step 1, 554, 110, $15, .clock
    +step 1, 440, 110, $15, .clock
    +step 1, 110, 110, $00, .clock
    +step 1, 622, 110, $14, .clock
    +step 1, 466, 110, $14, .clock
    +step 1, 370, 110, $14, .clock
    +step 1, 110, 110, $00, .clock
    +step 2, 523, 110, $13, .clock
    +step 2, 392, 110, $12, .clock
    +step 2, 311, 110, $11, .clock
    !byte 0
.fx85: ; 85: mario-fireball, 7 ticks; Super Mario Bros.: Feuerball
    +step 1, 1400, 110, $15, .clock
    +step 1, 900, 110, $14, .clock
    +step 1, 600, 110, $13, .clock
    +step 1, 1200, 110, $13, .clock
    +step 1, 700, 110, $12, .clock
    +step 2, 450, 110, $11, .clock
    !byte 0
.fx86: ; 86: mario-stomp, 8 ticks; Super Mario Bros.: Gegner zertreten
    +step 1, 900, 2000, $55, .clock
    +step 2, 600, 1200, $54, .clock
    +step 2, 300, 600, $53, .clock
    +step 3, 200, 110, $12, .clock
    !byte 0
.fx87: ; 87: mario-brick, 13 ticks; Super Mario Bros.: Block zerbricht
    +step 2, 110, 3000, $46, .clock
    +step 1, 110, 1800, $44, .clock
    +step 1, 110, 110, $00, .clock
    +step 2, 110, 2400, $45, .clock
    +step 1, 110, 1200, $43, .clock
    +step 1, 110, 110, $00, .clock
    +step 2, 110, 1600, $43, .clock
    +step 3, 110, 700, $41, .clock
    !byte 0
.fx88: ; 88: mario-flagpole, 36 ticks; Super Mario Bros.: Fahnenmast
    +step 3, 2000, 110, $14, .clock
    +step 3, 1750, 110, $14, .clock
    +step 3, 1530, 110, $14, .clock
    +step 3, 1340, 110, $14, .clock
    +step 3, 1170, 110, $14, .clock
    +step 3, 1020, 110, $14, .clock
    +step 3, 890, 110, $14, .clock
    +step 3, 780, 110, $13, .clock
    +step 3, 680, 110, $13, .clock
    +step 3, 600, 110, $13, .clock
    +step 3, 520, 110, $12, .clock
    +step 3, 450, 110, $11, .clock
    !byte 0
.fx89: ; 89: mario-spin, 10 ticks; Super Mario World: Wirbelsprung
    +step 1, 600, 2400, $54, .clock
    +step 1, 900, 3200, $53, .clock
    +step 1, 700, 2600, $54, .clock
    +step 1, 1000, 3400, $53, .clock
    +step 1, 800, 2800, $54, .clock
    +step 1, 1100, 3600, $53, .clock
    +step 1, 900, 3000, $53, .clock
    +step 1, 1200, 3800, $52, .clock
    +step 2, 110, 2000, $41, .clock
    !byte 0
.fx90: ; 90: angry-launch, 18 ticks; Angry Birds: Schleuder
    +step 3, 150, 300, $52, .clock
    +step 3, 170, 360, $53, .clock
    +step 3, 190, 420, $53, .clock
    +step 1, 110, 110, $00, .clock
    +step 1, 110, 3200, $46, .clock
    +step 2, 110, 2200, $45, .clock
    +step 2, 110, 1400, $43, .clock
    +step 3, 110, 800, $41, .clock
    !byte 0
.fx91: ; 91: fruit-slice, 10 ticks; Fruit Ninja: Schnitt
    +step 1, 110, 1500, $43, .clock
    +step 1, 110, 3000, $45, .clock
    +step 2, 110, 3800, $44, .clock
    +step 1, 110, 110, $00, .clock
    +step 1, 110, 600, $46, .clock
    +step 2, 110, 350, $43, .clock
    +step 2, 110, 200, $41, .clock
    !byte 0
.fx92: ; 92: flappy-point, 12 ticks; Flappy Bird: Punkt
    +step 2, 1319, 110, $15, .clock
    +step 3, 1976, 110, $16, .clock
    +step 3, 1976, 110, $14, .clock
    +step 4, 1976, 110, $12, .clock
    !byte 0
.fx93: ; 93: temple-coin, 9 ticks; Temple Run: Muenze
    +step 1, 1760, 1786, $34, .clock
    +step 1, 2349, 2384, $34, .clock
    +step 1, 2794, 2836, $34, .clock
    +step 1, 110, 110, $00, .clock
    +step 1, 2093, 2124, $33, .clock
    +step 1, 2794, 2836, $33, .clock
    +step 3, 3520, 3573, $32, .clock
    !byte 0
.fx94: ; 94: candy-match, 13 ticks; Candy Crush Saga: Reihe
    +step 2, 659, 988, $34, .clock
    +step 1, 110, 110, $00, .clock
    +step 2, 880, 1319, $35, .clock
    +step 1, 110, 110, $00, .clock
    +step 2, 1175, 1760, $35, .clock
    +step 1, 110, 110, $00, .clock
    +step 4, 1568, 2349, $33, .clock
    !byte 0
.fx95: ; 95: subway-jump, 8 ticks; Subway Surfers: Sprung
    +step 1, 300, 1200, $53, .clock
    +step 1, 420, 1800, $54, .clock
    +step 1, 560, 2400, $54, .clock
    +step 1, 720, 3000, $53, .clock
    +step 2, 900, 110, $13, .clock
    +step 2, 1050, 110, $12, .clock
    !byte 0
.fx96: ; 96: cutrope-snip, 14 ticks; Cut the Rope: Schnitt und Schlucken
    +step 1, 1760, 3600, $55, .clock
    +step 1, 110, 2400, $43, .clock
    +step 2, 110, 110, $00, .clock
    +step 3, 330, 110, $14, .clock
    +step 3, 220, 110, $14, .clock
    +step 4, 165, 110, $12, .clock
    !byte 0
.fx97: ; 97: doodle-spring, 14 ticks; Doodle Jump: Sprungfeder
    +step 1, 200, 110, $15, .clock
    +step 1, 260, 110, $15, .clock
    +step 1, 340, 110, $15, .clock
    +step 1, 300, 110, $14, .clock
    +step 1, 420, 110, $14, .clock
    +step 1, 380, 110, $14, .clock
    +step 1, 520, 110, $13, .clock
    +step 1, 470, 110, $13, .clock
    +step 2, 640, 110, $13, .clock
    +step 2, 600, 110, $12, .clock
    +step 2, 760, 110, $11, .clock
    !byte 0
.fx98: ; 98: pokemongo-catch, 26 ticks; Pokemon GO: Fang
    +step 1, 900, 110, $13, .clock
    +step 5, 110, 110, $00, .clock
    +step 1, 900, 110, $13, .clock
    +step 5, 110, 110, $00, .clock
    +step 1, 900, 110, $13, .clock
    +step 5, 110, 110, $00, .clock
    +step 2, 1319, 110, $14, .clock
    +step 2, 1760, 110, $14, .clock
    +step 4, 2637, 110, $12, .clock
    !byte 0
.fx99: ; 99: jetpack-thrust, 8 ticks; Jetpack Joyride: Duesenschub
    +step 2, 130, 1800, $54, .clock
    +step 2, 140, 2200, $55, .clock
    +step 2, 125, 1600, $54, .clock
    +step 2, 135, 2400, $55, .clock
    !byte 0
.fx100: ; 100: bd-boulder, 4 ticks; Boulder Dash: Felsbrocken (Rauschen 143.5 Hz)
    +step 2, 110, 144, $47, .clock
    +step 1, 110, 144, $44, .clock
    +step 1, 110, 144, $41, .clock
    !byte 0
.fx101: ; 101: bd-diamond-fall, 10 ticks; Boulder Dash: fallende Diamanten (2092-3980 Hz)
    +step 2, 3200, 110, $15, .clock
    +step 1, 3200, 110, $12, .clock
    +step 2, 2350, 110, $15, .clock
    +step 1, 2350, 110, $12, .clock
    +step 2, 3700, 110, $15, .clock
    +step 2, 3700, 110, $11, .clock
    !byte 0
.fx102: ; 102: bd-crack, 38 ticks; Boulder Dash: Crack (Rauschen 736.6 Hz, 750 ms Decay)
    +step 4, 110, 737, $48, .clock
    +step 5, 110, 737, $47, .clock
    +step 5, 110, 737, $46, .clock
    +step 5, 110, 737, $45, .clock
    +step 5, 110, 737, $44, .clock
    +step 5, 110, 737, $43, .clock
    +step 5, 110, 737, $42, .clock
    +step 4, 110, 737, $41, .clock
    !byte 0
.fx103: ; 103: bd-timeout, 30 ticks; Boulder Dash: Zeit laeuft ab (577.5/593.1/608.7 Hz)
    +step 2, 578, 110, $16, .clock
    +step 3, 578, 110, $14, .clock
    +step 3, 578, 110, $12, .clock
    +step 2, 578, 110, $11, .clock
    +step 2, 593, 110, $16, .clock
    +step 3, 593, 110, $14, .clock
    +step 3, 593, 110, $12, .clock
    +step 2, 593, 110, $11, .clock
    +step 2, 609, 110, $16, .clock
    +step 3, 609, 110, $14, .clock
    +step 3, 609, 110, $12, .clock
    +step 2, 609, 110, $11, .clock
    !byte 0
.fx104: ; 104: bd-amoeba, 16 ticks; Boulder Dash: Amoebe (125-234 Hz)
    +step 2, 160, 110, $13, .clock
    +step 2, 210, 110, $14, .clock
    +step 2, 130, 110, $13, .clock
    +step 2, 190, 110, $14, .clock
    +step 2, 145, 110, $13, .clock
    +step 2, 225, 110, $14, .clock
    +step 2, 175, 110, $13, .clock
    +step 2, 135, 110, $14, .clock
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
    !word .fx50, .fx50
    !word .fx51, .fx51
    !word .fx52, .fx52
    !word .fx53, .fx53
    !word .fx54, .fx54
    !word .fx55, .fx55
    !word .fx56, .fx56
    !word .fx57, .fx57
    !word .fx58, .fx58
    !word .fx59, .fx59
    !word .fx60, .fx60
    !word .fx61, .fx61
    !word .fx62, .fx62
    !word .fx63, .fx63
    !word .fx64, .fx64
    !word .fx65, .fx65
    !word .fx66, .fx66
    !word .fx67, .fx67
    !word .fx68, .fx68
    !word .fx69, .fx69
    !word .fx70, .fx70
    !word .fx71, .fx71
    !word .fx72, .fx72
    !word .fx73, .fx73
    !word .fx74, .fx74
    !word .fx75, .fx75
    !word .fx76, .fx76
    !word .fx77, .fx77
    !word .fx78, .fx78
    !word .fx79, .fx79
    !word .fx80, .fx80
    !word .fx81, .fx81
    !word .fx82, .fx82
    !word .fx83, .fx83
    !word .fx84, .fx84
    !word .fx85, .fx85
    !word .fx86, .fx86
    !word .fx87, .fx87
    !word .fx88, .fx88
    !word .fx89, .fx89
    !word .fx90, .fx90
    !word .fx91, .fx91
    !word .fx92, .fx92
    !word .fx93, .fx93
    !word .fx94, .fx94
    !word .fx95, .fx95
    !word .fx96, .fx96
    !word .fx97, .fx97
    !word .fx98, .fx98
    !word .fx99, .fx99
    !word .fx100, .fx100
    !word .fx101, .fx101
    !word .fx102, .fx102
    !word .fx103, .fx103
    !word .fx104, .fx104
    !if * - .export_table != SFX_COUNT*4 { !error "Catalog pointer table size" }
}
!zone pal_data {
    +catalog 110840, ~sfx_table_pal
}
!zone ntsc_data {
    +catalog 111861, ~sfx_table_ntsc
}
sfx_flags:
    !byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,3,1,0
    !byte 0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0
    !byte 1,1,1,1,1
    !byte 0,0,0,0,0
    !byte 0,0,0,0,0,0,0,0,0,0
    !byte 0,0,0,0,0,0,0,0,0,3
    !byte 0,0,0,0,1
sfx_durations:
    !byte 30,30,20,25,13,6,10,10,25,25,2,6,6,10,8,9,13,5,10,30,4,5,20,20,25,8,10,12,15,40,10,8,10,13,20,13,20,10,2,18,30,20,30,25,3,15,18,30,40,13
    !byte 7,3,7,13,13,8,8,29,25,12,10,18,12,50,11,14,32,21,12,28
    !byte 12,8,16,12,16
    !byte 14,14,22,26,24
    !byte 14,11,18,30,18,7,8,13,36,10
    !byte 18,10,12,9,13,8,14,14,26,8
    !byte 4,10,38,30,16
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
    !word sfx_name_50
    !word sfx_name_51
    !word sfx_name_52
    !word sfx_name_53
    !word sfx_name_54
    !word sfx_name_55
    !word sfx_name_56
    !word sfx_name_57
    !word sfx_name_58
    !word sfx_name_59
    !word sfx_name_60
    !word sfx_name_61
    !word sfx_name_62
    !word sfx_name_63
    !word sfx_name_64
    !word sfx_name_65
    !word sfx_name_66
    !word sfx_name_67
    !word sfx_name_68
    !word sfx_name_69
    !word sfx_name_70
    !word sfx_name_71
    !word sfx_name_72
    !word sfx_name_73
    !word sfx_name_74
    !word sfx_name_75
    !word sfx_name_76
    !word sfx_name_77
    !word sfx_name_78
    !word sfx_name_79
    !word sfx_name_80
    !word sfx_name_81
    !word sfx_name_82
    !word sfx_name_83
    !word sfx_name_84
    !word sfx_name_85
    !word sfx_name_86
    !word sfx_name_87
    !word sfx_name_88
    !word sfx_name_89
    !word sfx_name_90
    !word sfx_name_91
    !word sfx_name_92
    !word sfx_name_93
    !word sfx_name_94
    !word sfx_name_95
    !word sfx_name_96
    !word sfx_name_97
    !word sfx_name_98
    !word sfx_name_99
    !word sfx_name_100
    !word sfx_name_101
    !word sfx_name_102
    !word sfx_name_103
    !word sfx_name_104
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
SFX_IM_ROBOT = 50
sfx_name_50: !pet "im-robot",0
SFX_BOULDER_DIAMOND = 51
sfx_name_51: !pet "boulder-diamond",0
SFX_URIDIUM_LASER = 52
sfx_name_52: !pet "uridium-laser",0
SFX_PARADROID_LINK = 53
sfx_name_53: !pet "paradroid-link",0
SFX_WIZBALL_PICKUP = 54
sfx_name_54: !pet "wizball-pickup",0
SFX_KARATE_PUNCH = 55
sfx_name_55: !pet "karate-punch",0
SFX_NINJA_SHURIKEN = 56
sfx_name_56: !pet "ninja-shuriken",0
SFX_LEMMINGS_OHNO = 57
sfx_name_57: !pet "lemmings-ohno",0
SFX_WORMS_BAZOOKA = 58
sfx_name_58: !pet "worms-bazooka",0
SFX_TURRICAN_BEAM = 59
sfx_name_59: !pet "turrican-beam",0
SFX_PINBALL_BUMPER = 60
sfx_name_60: !pet "pinball-bumper",0
SFX_ALIENBREED_DOOR = 61
sfx_name_61: !pet "alienbreed-door",0
SFX_LOTUS_ENGINE = 62
sfx_name_62: !pet "lotus-engine",0
SFX_MC_CREEPER = 63
sfx_name_63: !pet "mc-creeper",0
SFX_MC_XP = 64
sfx_name_64: !pet "mc-xp",0
SFX_PORTAL_SHOT = 65
sfx_name_65: !pet "portal-shot",0
SFX_HALO_RECHARGE = 66
sfx_name_66: !pet "halo-recharge",0
SFX_FORTNITE_SHIELD = 67
sfx_name_67: !pet "fortnite-shield",0
SFX_APEX_PING = 68
sfx_name_68: !pet "apex-ping",0
SFX_ZELDA_DISCOVERY = 69
sfx_name_69: !pet "zelda-discovery",0
SFX_FLAP_SOFT = 70
sfx_name_70: !pet "flap-soft",0
SFX_FLAP_SNAPPY = 71
sfx_name_71: !pet "flap-snappy",0
SFX_FLAP_DOUBLE = 72
sfx_name_72: !pet "flap-double",0
SFX_FLAP_FLUTTER = 73
sfx_name_73: !pet "flap-flutter",0
SFX_FLAP_CHIRP = 74
sfx_name_74: !pet "flap-chirp",0
sfx_data_end:
SFX_LIFE_FALL = 75
sfx_name_75: !pet "life-fall",0
SFX_LIFE_THUD = 76
sfx_name_76: !pet "life-thud",0
SFX_LIFE_SIGH = 77
sfx_name_77: !pet "life-sigh",0
SFX_LIFE_SAD = 78
sfx_name_78: !pet "life-sad",0
SFX_LIFE_WOBBLE = 79
sfx_name_79: !pet "life-wobble",0
SFX_MARIO_COIN = 80
sfx_name_80: !pet "mario-coin",0
SFX_MARIO_JUMP = 81
sfx_name_81: !pet "mario-jump",0
SFX_MARIO_1UP = 82
sfx_name_82: !pet "mario-1up",0
SFX_MARIO_MUSHROOM = 83
sfx_name_83: !pet "mario-mushroom",0
SFX_MARIO_PIPE = 84
sfx_name_84: !pet "mario-pipe",0
SFX_MARIO_FIREBALL = 85
sfx_name_85: !pet "mario-fireball",0
SFX_MARIO_STOMP = 86
sfx_name_86: !pet "mario-stomp",0
SFX_MARIO_BRICK = 87
sfx_name_87: !pet "mario-brick",0
SFX_MARIO_FLAGPOLE = 88
sfx_name_88: !pet "mario-flagpole",0
SFX_MARIO_SPIN = 89
sfx_name_89: !pet "mario-spin",0
SFX_ANGRY_LAUNCH = 90
sfx_name_90: !pet "angry-launch",0
SFX_FRUIT_SLICE = 91
sfx_name_91: !pet "fruit-slice",0
SFX_FLAPPY_POINT = 92
sfx_name_92: !pet "flappy-point",0
SFX_TEMPLE_COIN = 93
sfx_name_93: !pet "temple-coin",0
SFX_CANDY_MATCH = 94
sfx_name_94: !pet "candy-match",0
SFX_SUBWAY_JUMP = 95
sfx_name_95: !pet "subway-jump",0
SFX_CUTROPE_SNIP = 96
sfx_name_96: !pet "cutrope-snip",0
SFX_DOODLE_SPRING = 97
sfx_name_97: !pet "doodle-spring",0
SFX_POKEMONGO_CATCH = 98
sfx_name_98: !pet "pokemongo-catch",0
SFX_JETPACK_THRUST = 99
sfx_name_99: !pet "jetpack-thrust",0
SFX_BD_BOULDER = 100
sfx_name_100: !pet "bd-boulder",0
SFX_BD_DIAMOND_FALL = 101
sfx_name_101: !pet "bd-diamond-fall",0
SFX_BD_CRACK = 102
sfx_name_102: !pet "bd-crack",0
SFX_BD_TIMEOUT = 103
sfx_name_103: !pet "bd-timeout",0
SFX_BD_AMOEBA = 104
sfx_name_104: !pet "bd-amoeba",0

!if sfx_durations - sfx_flags != SFX_COUNT { !error "Exactly SFX_COUNT flags required" }
!if sfx_names - sfx_durations != SFX_COUNT { !error "Exactly SFX_COUNT durations required" }
!if sfx_name_0 - sfx_names != SFX_COUNT*2 { !error "Exactly SFX_COUNT names required" }
