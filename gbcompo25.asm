.GBHEADER
	NINTENDOLOGO
	NAME "TEST"
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
	di
	ld sp, $FFFE
	
	ld a, %00000001
	ldh ($FF), a
	
	ld a, %10000000
	ldh ($26), a
	ld a, %01110111
	ldh ($24), a
	ld a, %11111111
	ldh ($25), a

loop:
	ld a, 40
pause:
	halt
	nop
	dec a
	jr nz, pause
	
	ld a, %10001000
	ldh ($11), a
	ld a, %11110001
	ldh ($12), a
	ld a, %00000000
	ldh ($13), a
	ld a, %11000100
	ldh ($14), a
	jr loop