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
res 4, [HL] ; use 8800 for BG tiles

	
; load tiles into VRAM
ld DE, tile
ld HL, $9000
ld BC, tileend - tile

copy_loop:
	ld A, [DE]
	inc DE
	ld [HL+], A
	dec BC
	ld A, B
	or A, C
	jp nz, copy_loop

; set the tilemap
ld HL, $9800
ld [HL], 80

; turn that shit back on
ld HL, $FF40
set 7, [HL]

loop:
	nop
	jp loop

tile:
	.DB $00,$00,$24,$24,$24,$24,$00,$00
	.DB $00,$00,$42,$42,$3C,$3C,$00,$00
tileend: