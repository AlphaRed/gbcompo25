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

; find vblank period
find_vblank:
	ld A, [$FF44]
	cp 144
	jp c, find_vblank
	
; turn off LCD
ld HL, $FF40
res 7, [HL]
res 4, [HL] ; use 9000 for BG tiles
set 1, [HL] ; turn on sprites
set 2, [HL] ; 8x16 sprites

	
; load tiles into VRAM
ld DE, bgtiles
ld HL, $9000
ld BC, bgtileend - bgtiles
call copy_loop

; set the tilemap
ld HL, $9800 + 2 * 32 ; skip two top rows
ld A, 1
ld B, 10

left_block_loop:
	ld [HL+], A
	inc HL
	dec B
	jp nz, left_block_loop

ld HL, $9800 + 2 * 32 + 1 ; skip two top rows
ld A, 2
ld B, 10

right_block_loop:
	ld [HL+], A
	inc HL
	dec B
	jp nz, right_block_loop

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

; set sprite pos
ld HL, $FE00
ld A, 16
ld [HL+], A
ld A, 8
ld [HL+], A
ld A, 0
ld [HL+], A
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

bgtiles:
	.DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.DB $86,$86,$79,$79,$7F,$7F,$7F,$3F
	.DB $7F,$5F,$7F,$2F,$7F,$57,$80,$80
	.DB $01,$01,$FE,$EA,$FE,$F4,$FE,$FA
	.DB $FE,$FE,$FE,$FE,$FE,$FE,$01,$01
bgtileend:

sprites:
	.DB $00,$00,$3C,$3C,$7E,$7E,$7E,$7E
	.DB $7E,$00,$7E,$00,$3C,$00,$00,$7C
	.DB $00,$7E,$00,$7E,$00,$7E,$00,$3E
	.DB $00,$3E,$00,$3E,$36,$36,$36,$36
spritesend: