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

; find vblank period
find_vblank:
	ld A, [LCDY]
	cp 144
	jp c, find_vblank
	
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
ld HL, $9800 + 2 * 32
ld A, 1
ld B, 20
block_loop:
	ld [HL+], A
	call change_tile
	dec B
	jp nz, block_loop

ld BC, 12
add HL, BC
ld A, 2
ld B, 20
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
	ld B, 20
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
ld B, 20
block_loop3:
	ld [HL+], A
	call change_tile
	dec B
	jp nz, block_loop3

ld BC, 12
add HL, BC
ld A, 2
ld B, 20
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
ld A, 16
ld [HL+], A
ld A, 8
ld [HL+], A
ld A, 0
ld [HL+], A
ld [HL], A
; rightside
ld HL, $FE04
ld A, 16
ld [HL+], A
ld A, 16
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
	res 4, [HL] ; check dpad
	
	
	; logic
	; render
	
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
