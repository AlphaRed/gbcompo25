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

	
; load tiles into VRAM
ld DE, bgtiles
ld HL, $9000
ld BC, bgtileend - bgtiles

copy_loop:
	ld A, [DE]
	inc DE
	ld [HL+], A
	dec BC
	ld A, B
	or A, C
	jp nz, copy_loop

; set the tilemap
ld HL, $9800 + 4 * 32
ld A, 1
ld B, 20

grass_loop:
	ld [HL+], A
	dec B
	jp nz, grass_loop

ld HL, $9800 + 5 * 32
ld A, 2
ld B, 20
ld DE, 12
ld C, 13

skip_loop:
	dirt_loop:
		ld [HL+], A
		dec B
		jp NZ, dirt_loop
	add HL, DE
	dec C
	ld B, 20
	jp NZ, skip_loop
	

; turn that shit back on
ld HL, $FF40
set 7, [HL]

; set the palette to default colours
ld HL, $FF47
ld [HL], %11100100

loop:
	nop
	jp loop

bgtiles:
	.DB $00,$00,$00,$00,$00,$00,$00,$00
	.DB $00,$00,$00,$00,$00,$00,$00,$00
	.DB $A5,$00,$FF,$00,$BA,$45,$00,$FF
	.DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
	.DB $24,$DB,$82,$7D,$53,$AC,$18,$E7
	.DB $24,$DB,$03,$FC,$26,$D9,$3A,$C5
	.DB $80,$0F,$F0,$80,$FF,$F0,$FF,$7F
	.DB $7F,$0F,$0F,$00,$07,$E0,$00,$F8
bgtileend: