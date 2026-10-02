; MOS TED data sheet, registers 14-18. Only bits 0-1 of FF12 are sound.
TED_FREQ1_LO = $ff0e
TED_FREQ2_LO = $ff0f
TED_FREQ2_HI = $ff10
TED_SOUND = $ff11
TED_FREQ1_HI = $ff12
TED_FREQ_HI_MASK = $03
TED_VIDEO_MASK = $fc
TED_VOICE1 = $10
TED_VOICE2 = $20
TED_NOISE = $40
TED_RELOAD = $80

TED_BACKGROUND = $ff15
TED_BORDER = $ff19
TED_BG_COLOR = (3 << 4) + 6
TED_WHITE = (7 << 4) + 1                 ; luminance 7, color 1, no blink

KERNAL_CHROUT = $ffd2
KERNAL_GETIN = $ffe4
SCREEN_BASE = $0c00
ATTRIBUTE_BASE = $0800
PROGRAM_BASE = $1001
RAM_END = $4000                 ; exclusive, unexpanded C16

; Verified against installed Commodore KERNAL 318004-05, $DB11-$DC2B.
KERNAL_KEY_SCAN = $c6           ; matrix index, $40 means released
KERNAL_SHIFT = $0543
KERNAL_REPEAT = $0540          ; bit 6 disables all KERNAL key repeat
KERNAL_STOP = $ffe1
