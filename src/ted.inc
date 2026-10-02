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

KERNAL_CHROUT = $ffd2
KERNAL_GETIN = $ffe4
SCREEN_BASE = $0c00
ATTRIBUTE_BASE = $0800
PROGRAM_BASE = $1001
RAM_END = $4000                 ; exclusive, unexpanded C16
