.GBHEADER
	NINTENDOLOGO
	NAME "WALLYSWORLD"
	ROMDMG
	LICENSEECODENEW "XX"
	CARTRIDGETYPE $00
	RAMSIZE $00
	COUNTRYCODE $01
.ENDGB

.MEMORYMAP
	DEFAULTSLOT 0
	SLOTSIZE $4000
	SLOT 0 $0000
	SLOT 1 $4000
.ENDME

.ROMBANKMAP
	BANKSTOTAL 2
	BANKSIZE $4000
	BANKS 2
.ENDRO

.BANK 0
.ORG $0100
	nop
	jp start

.ORG $0150
start:

.INCLUDE "variables.i"
; setup player
ld HL, PLAYER_Y
ld [HL], 64
ld HL, PLAYER_X
ld [HL], 32
ld HL, PLAYER_X2
ld [HL], 32 + 8

; setup other globals
ld A, 0
ld [FRAMECOUNTER], A
ld A, 0
ld [VELOCITY], A
ld A, 7
ld [SCROLLCOUNTER], A
ld A, 0
ld [NEXTBLOCK], A
ld A, 2
ld [BLOCKTILE], A
ld A, 1
ld [GRAVITY], A

; find vblank period
call find_vblank
	
; turn off LCD
ld HL, LCDC
res 7, [HL]
res 4, [HL] ; use 9000 for BG tiles
set 1, [HL] ; turn on sprites
set 2, [HL] ; 8x16 sprites
	
; load tiles into VRAM
ld DE, bgtiles
ld HL, $9000
ld BC, bgtileend - bgtiles
call copy_loop	

; top two rows of blocks
ld HL, $9800 + 2 * BG_WIDTH
ld A, 1
ld B, SCREEN_WIDTH
block_loop:
	ld [HL+], A
	call change_tile
	dec B
	jp nz, block_loop

ld BC, 12
add HL, BC
ld A, 2
ld B, SCREEN_WIDTH
block_loop2:
	ld [HL+], A
	call change_tile
	dec B
	jp nz, block_loop2
	
; middle empty section
ld A, 0
ld D, 12
middle_section_loop:
	ld BC, 12
	add HL, BC
	ld B, SCREEN_WIDTH
	place_tile_loop:
		ld [HL+], A
		dec B
		jp nz, place_tile_loop
	dec D
	jp nz, middle_section_loop
	
; bottom two rows of blocks
ld BC, 12
add HL, BC
ld A, 1
ld B, SCREEN_WIDTH
block_loop3:
	ld [HL+], A
	call change_tile
	dec B
	jp nz, block_loop3

ld BC, 12
add HL, BC
ld A, 2
ld B, SCREEN_WIDTH
block_loop4:
	ld [HL+], A
	call change_tile
	dec B
	jp nz, block_loop4

; clear OAM
ld A, 0
ld B, 160
ld HL, $FE00

clear_OAM_loop:
	ld [HL+], A
	dec B
	jp nz, clear_OAM_loop

; load sprites into VRAM
ld DE, sprites
ld HL, $8000
ld BC, spritesend - sprites
call copy_loop

; set sprite pos, leftside
ld HL, $FE00
ld A, [PLAYER_Y]
ld [HL+], A
ld A, [PLAYER_X]
ld [HL+], A
ld A, 0
ld [HL+], A
ld [HL], A
; rightside
ld HL, $FE04
ld A, [PLAYER_Y]
ld [HL+], A
ld A, [PLAYER_X2]
ld [HL+], A
ld A, 2
ld [HL+], A
ld A, 0
ld [HL], A

; turn that shit back on
ld HL, $FF40
set 7, [HL]

; set the palette to default colours
ld HL, $FF47 ; BG tiles
ld [HL], %11100100

ld HL, $FF48 ; sprites
ld [HL], %11100100

loop:
	nop
	
	; input
	ld HL, $FF00
	res 5, [HL] ; check buttons, not dpad
	ld A, [$FF00]
	ld A, [$FF00]
	ld A, [$FF00]
	ld A, [$FF00]
	cpl
	and $0F
	cp 1
	call z, set_velocity
	
	; logic
	ld A, [PLAYER_Y] ; collision, all WIP
	sra A
	sra A
	sra A
	sla A
	sla A
	sla A
	sla A
	sla A
	ld B, A
	ld A, [PLAYER_X]
	sub 8
	add A, B
	ld B, 0
	ld C, A
	ld HL, $9800
	add HL, BC
	ld A, [HL]
	cp 1
	call nc, player_dead
	
	; check top
	; check bottom
	
	
	; render
	call find_vblank
	
	ld A, [FRAMECOUNTER] ; draw only every 2 frames
	inc A
	ld [FRAMECOUNTER], A
	cp 2
	jp nz, loop
	
	ld A, 0 ; reset frame counter to zero
	ld [FRAMECOUNTER], A
	
	ld A, [VELOCITY]
	cp 1
	call z, add_velocity
	
	ld A, [GRAVITY]
	cp 1
	call z, add_gravity
	
	ld HL, $FE00 ; update player position
	ld A, [PLAYER_Y]
	ld [HL], A
	ld HL, $FE04
	ld A, [PLAYER_Y]
	ld [HL], A
	
	ld A, [$FF43] ; scroll the bg
	inc A
	ld [$FF43], A
	
	ld A, [SCROLLCOUNTER]
	inc A
	ld [SCROLLCOUNTER], A
	cp 8
	jp nz, loop
	
	; add column of blocks
	ld HL, $9800 + 2 * BG_WIDTH + SCREEN_WIDTH ; yikes
	ld A, [NEXTBLOCK]
	ld C, A
	ld B, 0
	add HL, BC
	
	ld A, [BLOCKTILE]
	ld D, A
	ld BC, BG_WIDTH
	ld A, 2
	call draw_next_block

	ld BC, 12 * BG_WIDTH ; skip to the bottom
	add HL, BC
	
	ld A, [BLOCKTILE]
	ld D, A
	ld BC, BG_WIDTH
	ld A, 2
	call draw_next_block
	
	ld A, 0 ; reset scroll counter
	ld [SCROLLCOUNTER], A
	
	ld A, [NEXTBLOCK]
	inc A
	ld [NEXTBLOCK], A
	cp 12
	call z, reset_next_block
	
	ld A, [BLOCKTILE]
	call change_tile
	ld [BLOCKTILE], A
	
	jp loop

; DE -> start of data to be copied
; HL -> address of where to put the data copied
; BC -> length of data copied
copy_loop:
	ld A, [DE]
	inc DE
	ld [HL+], A
	dec BC
	ld A, B
	or A, C
	jp nz, copy_loop
	ret

; For changing inbetween bg tiles
change_tile:
	inc A
	cp 2
	jp nz, @set_A_1
	ret
	@set_A_1:
		ld A, 1
		ret

add_velocity:
	ld A, [PLAYER_Y] ; maybe look at later
	dec A
	dec A
	ld [PLAYER_Y], A
	ld A, 0 ; clear it
	ld [VELOCITY], A
	ret

set_velocity:
	ld A, 1
	ld [VELOCITY], A
	ret

find_vblank:
	ld A, [LCDY]
	cp 144
	jp nz, find_vblank
	ret

reset_next_block:
	ld A, 0
	ld [NEXTBLOCK], A
	ret

draw_next_block:
	ld E, A
	ld A, D
	call change_tile
	ld [HL], A
	add HL, BC
	ld D, A
	ld A, E
	dec A
	jp nz, draw_next_block
	ret

player_dead:
	ld A, 0
	ld [VELOCITY], A
	ld [GRAVITY], A
	ret

add_gravity:
	ld A, [PLAYER_Y]
	inc A
	ld [PLAYER_Y], A
	ret

bgtiles:
	.DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.DB $86,$86,$79,$79,$7F,$7F,$7F,$3F
	.DB $7F,$5F,$7F,$2F,$7F,$57,$80,$80
	.DB $01,$01,$FE,$EA,$FE,$F4,$FE,$FA
	.DB $FE,$FE,$FE,$FE,$FE,$FE,$01,$01
bgtileend:

sprites:
	.DB $00,$00,$00,$00,$00,$00,$1F,$00
	.DB $00,$00,$80,$00,$C3,$00,$FF,$00
	.DB $7F,$00,$0F,$00,$07,$00,$03,$00
	.DB $01,$00,$00,$00,$08,$00,$07,$00
	.DB $00,$00,$00,$00,$C0,$00,$FE,$00
	.DB $C0,$00,$F0,$00,$F8,$00,$0C,$00
	.DB $06,$00,$06,$00,$06,$00,$FE,$00
	.DB $FC,$00,$F8,$00,$89,$00,$FE,$00
spritesend:
