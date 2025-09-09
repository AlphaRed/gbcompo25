; Hardware and global variables
; Hardware related variable definitions
.DEFINE LCDY $FF44 ; Y coordinate for vblank
.DEFINE LCDC $FF40 ; LCD control reg

; Global variable definitions
.DEFINE PLAYER_Y $C000
.DEFINE PLAYER_X $C002
.DEFINE PLAYER_X2 $C004 ; for the second sprite

.DEFINE FRAMECOUNTER $C006 ; move this around it
.DEFINE VELOCITY $C008
.DEFINE SCROLLCOUNTER $C00A
; Other?