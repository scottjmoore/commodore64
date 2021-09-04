    org $0801               ; Start of BASIC program memory

    dw $080b                ; Next line pointer
    dw $000a                ; Line 10
    db $9e," 2064"          ; SYS 2064 ($0810)
    db $00,$00,$00,$00,$00  ; zero padding

    struct  Sprite
        ptr:    db $00
        x:      dw $0000
        y:      db $00
    endstruct

Start:
    jsr InitScreen
    jsr InitSprites
    jsr InitInterrupts

Loop:
    dec SpriteList1 + 1 + 0
    inc SpriteList1 + 1 + 4
    dec SpriteList1 + 1 + 8
    inc SpriteList1 + 1 + 12
    dec SpriteList1 + 1 + 16
    inc SpriteList1 + 1 + 20
    dec SpriteList1 + 1 + 24
    inc SpriteList1 + 1 + 28
    inc SpriteList2 + 1 + 0
    inc SpriteList2 + 1 + 4
    inc SpriteList2 + 1 + 8
    dec SpriteList2 + 1 + 12
    inc SpriteList2 + 1 + 16
    dec SpriteList2 + 1 + 20
    inc SpriteList2 + 1 + 24
    dec SpriteList2 + 1 + 28
    dec SpriteList3 + 1 + 0
    inc SpriteList3 + 1 + 4
    dec SpriteList3 + 1 + 8
    inc SpriteList3 + 1 + 12
    dec SpriteList3 + 1 + 16
    inc SpriteList3 + 1 + 20
    dec SpriteList3 + 1 + 24
    inc SpriteList3 + 1 + 28

    lda $dc00
    and #1<<4
    bne NoFire
    jmp Exit
NoFire:
    lda #$00
.WaitStart
    cmp $d012
    bne .WaitStart
    lda #$ff
.WaitEnd
    cmp $d012
    bne .WaitEnd
    jmp Loop

Exit:
    jmp ($fffc)             ; Jump to code stored in 6502 reset vector

InitScreen:
    jsr $e544               ; Clear the screen

    lda #$00                ; Load accumulator with colour value for black
    sta $d020               ; Set border colour to black
    sta $d021               ; Set background colour 0 to black

    lda #0                  ; Load accumulator with zero
    ldy #0                  ; Set Y register to count 256 times
    ldx #3
InitScreenLoop1:
    sta $0400,y             ; Store the accumulator in screen memory + Y register
    sta $d800,y             ; Store the accumulator in colour memory + Y register
    clc 
    adc #1
    iny                     ; increment the Y register
    bne InitScreenLoop1           ; If != 0 go back to StartLoop
    inc InitScreenLoop1 + 2
    inc InitScreenLoop1 + 5
    dex 
    bne InitScreenLoop1
    
InitScreenLoop2:
    sta $0700,y             ; Store the accumulator in screen memory + Y register
    sta $db00,y             ; Store the accumulator in colour memory + Y register
    clc 
    adc #1
    iny                     ; increment the Y register
    cpy #232
    bne InitScreenLoop2      ; If != 232 go back to StartLoop
    rts 

InitSprites:
    lda #$ff
    sta $d015
    lda #$00
    sta $d01b
    lda #$ff
    sta $d01c
    lda #$02
    sta $d025
    lda #$06
    sta $d026
    lda #$0a
    sta $d027
    sta $d028
    sta $d029
    sta $d02a
    sta $d02b
    sta $d02c
    sta $d02d
    sta $d02e
    rts 

RasterStart     equ 34
RasterSize      equ 32
InitInterrupts:
    sei 
    lda #%01111111
    sta $dc0d
    and $d011
    sta $d011
    lda $dc0d
    lda $dd0d
    lda #RasterStart + (RasterSize * 0)
    sta $d012
    lda #<IrqService1
    sta $0314
    lda #>IrqService1
    sta $0315
    lda #%00000001
    sta $d01a
    cli 
    rts 

IrqService1:
    lda #$0f
    sta $d020
    lda #<SpriteList1
    sta $fb
    lda #>SpriteList1
    sta $fc
    lda #$00
    sta .SpriteX + 1
    sta .SpriteY + 1
    inc .SpriteY + 1
    ldy #0
    ldx #0
.IterateSpriteList
    lda ($fb),y
    beq .EndOfSpriteList
    iny 
    sta $07f8,x
    inx 
    lda ($fb),y
    iny 
    iny 
.SpriteX
    sta $d000
    inc .SpriteX + 1
    inc .SpriteX + 1
    lda ($fb),y
    iny 
.SpriteY
    sta $d001
    inc .SpriteY + 1
    inc .SpriteY + 1
    jmp .IterateSpriteList

.EndOfSpriteList
    lda #$01
    sta $d020
    lda #RasterStart + (RasterSize * 1)
    sta $d012
    lda #<IrqService2
    sta $0314
    lda #>IrqService2
    sta $0315
    asl $d019
    jmp $ea81

IrqService2:
    lda #$0f
    sta $d020
    lda #<SpriteList2
    sta $fb
    lda #>SpriteList2
    sta $fc
    lda #$00
    sta .SpriteX + 1
    sta .SpriteY + 1
    inc .SpriteY + 1
    ldy #0
    ldx #0
.IterateSpriteList
    lda ($fb),y
    beq .EndOfSpriteList
    iny 
    sta $07f8,x
    inx 
    lda ($fb),y
    iny 
    iny 
.SpriteX
    sta $d008
    inc .SpriteX + 1
    inc .SpriteX + 1
    lda ($fb),y
    iny 
.SpriteY
    sta $d009
    inc .SpriteY + 1
    inc .SpriteY + 1
    jmp .IterateSpriteList

.EndOfSpriteList
    lda #$02
    sta $d020
    lda #RasterStart + (RasterSize * 2)
    sta $d012
    lda #<IrqService3
    sta $0314
    lda #>IrqService3
    sta $0315
    asl $d019
    jmp $ea81
    
IrqService3:
    lda #$0f
    sta $d020
    lda #<SpriteList3
    sta $fb
    lda #>SpriteList3
    sta $fc
    lda #$00
    sta .SpriteX + 1
    sta .SpriteY + 1
    inc .SpriteY + 1
    ldy #0
    ldx #0
.IterateSpriteList
    lda ($fb),y
    beq .EndOfSpriteList
    iny 
    sta $07f8,x
    inx 
    lda ($fb),y
    iny 
    iny 
.SpriteX
    sta $d008
    inc .SpriteX + 1
    inc .SpriteX + 1
    lda ($fb),y
    iny 
.SpriteY
    sta $d009
    inc .SpriteY + 1
    inc .SpriteY + 1
    jmp .IterateSpriteList

.EndOfSpriteList
    lda #$03
    sta $d020
    lda #RasterStart + (RasterSize * 3)
    sta $d012
    lda #<IrqServiceLast
    sta $0314
    lda #>IrqServiceLast
    sta $0315
    asl $d019
    jmp $ea81
    
; IrqService4:
;     lda #$04
;     sta $d020
;     lda #RasterStart + (RasterSize * 4)
;     sta $d012
;     lda #<IrqService5
;     sta $0314
;     lda #>IrqService5
;     sta $0315
;     asl $d019
;     jmp $ea81
    
; IrqService5:
;     lda #$05
;     sta $d020
;     lda #RasterStart + (RasterSize * 5)
;     sta $d012
;     lda #<IrqService6
;     sta $0314
;     lda #>IrqService6
;     sta $0315
;     asl $d019
;     jmp $ea81
    
; IrqService6:
;     lda #$06
;     sta $d020
;     lda #RasterStart + (RasterSize * 6)
;     sta $d012
;     lda #<IrqService7
;     sta $0314
;     lda #>IrqService7
;     sta $0315
;     asl $d019
;     jmp $ea81
    
; IrqService7:
;     lda #$07
;     sta $d020
;     lda #RasterStart + (RasterSize * 7)
;     sta $d012
;     lda #<IrqService8
;     sta $0314
;     lda #>IrqService8
;     sta $0315
;     asl $d019
;     jmp $ea81
    
; IrqService8:
;     lda #$08
;     sta $d020
;     lda #RasterStart + (RasterSize * 8)
;     sta $d012
;     lda #<IrqService9
;     sta $0314
;     lda #>IrqService9
;     sta $0315
;     asl $d019
;     jmp $ea81
    
; IrqService9:
;     lda #$09
;     sta $d020
;     lda #RasterStart + (RasterSize * 9)
;     sta $d012
;     lda #<IrqService10
;     sta $0314
;     lda #>IrqService10
;     sta $0315
;     asl $d019
;     jmp $ea81
    
; IrqService10:
;     lda #$0a
;     sta $d020
;     lda #RasterStart + (RasterSize * 10)
;     sta $d012
;     lda #<IrqService11
;     sta $0314
;     lda #>IrqService11
;     sta $0315
;     asl $d019
;     jmp $ea81
    
; IrqService11:
;     lda #$0b
;     sta $d020
;     lda #RasterStart + (RasterSize * 11)
;     sta $d012
;     lda #<IrqService12
;     sta $0314
;     lda #>IrqService12
;     sta $0315
;     asl $d019
;     jmp $ea81
    
; IrqService12:
;     lda #$0c
;     sta $d020
;     lda #RasterStart + (RasterSize * 12)
;     sta $d012
;     lda #<IrqServiceLast
;     sta $0314
;     lda #>IrqServiceLast
;     sta $0315
;     asl $d019
;     jmp $ea81
    
IrqServiceLast:
    lda #$00
    sta $d020
    lda #RasterStart + (RasterSize * 0)
    sta $d012
    lda #<IrqService1
    sta $0314
    lda #>IrqService1
    sta $0315
    asl $d019
    jmp $ea31

SpriteList1:
    Sprite Sprite0 >> 6,16,45
    Sprite Sprite0 >> 6,48,45
    Sprite Sprite0 >> 6,80,45
    Sprite Sprite0 >> 6,112,45
    Sprite Sprite0 >> 6,144,45
    Sprite Sprite0 >> 6,176,45
    Sprite Sprite0 >> 6,208,45
    Sprite Sprite0 >> 6,240,45
    db $00

SpriteList2:
    Sprite Sprite1 >> 6,16,45 + 32
    Sprite Sprite1 >> 6,48,45 + 32
    Sprite Sprite1 >> 6,80,45 + 32
    Sprite Sprite1 >> 6,112,45 + 32
    Sprite Sprite1 >> 6,144,45 + 32
    Sprite Sprite1 >> 6,176,45 + 32
    Sprite Sprite1 >> 6,208,45 + 32
    Sprite Sprite1 >> 6,240,45 + 32
    db $00

SpriteList3:
    Sprite Sprite2 >> 6,16,45 + 64
    Sprite Sprite3 >> 6,48,45 + 64
    Sprite Sprite4 >> 6,80,45 + 64
    Sprite Sprite2 >> 6,112,45 + 64
    Sprite Sprite3 >> 6,144,45 + 64
    Sprite Sprite4 >> 6,176,45 + 64
    Sprite Sprite2 >> 6,208,45 + 64
    Sprite Sprite3 >> 6,240,45 + 64
    db $00

SpriteList4:
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite

SpriteList5:
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite

SpriteList6:
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite

SpriteList7:
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite

SpriteList8:
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite

SpriteList9:
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite

SpriteList10:
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite

SpriteList11:
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite

SpriteList12:
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite

SpriteList13:
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite

    align 6

Sprite0:
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $55, $00
	db $03, $57, $00, $0F, $FF, $C0, $0F, $FF, $C0, $02, $AA, $00, $0D, $FD, $C0, $3D, $FD, $F0, $35, $FD, $70
	db $B5, $75, $78, $A5, $55, $68, $05, $55, $40, $05, $55, $40, $05, $45, $40, $01, $55, $00, $0F, $FF, $C0
	db 0

Sprite1:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $50, $00, $05, $55, $00
	db $0F, $E8, $00, $3B, $AE, $00, $3A, $EB, $80, $3E, $AF, $00, $02, $AA, $00, $0F, $F0, $00, $3F, $5C, $00
	db $3D, $64, $00, $3F, $55, $00, $1E, $95, $00, $16, $55, $00, $15, $14, $00, $3C, $3C, $00, $3F, $3F, $00
	db 0

Sprite2:
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff 
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff 
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff 
    db 0

Sprite3:
    db $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55 
    db $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55 
    db $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55 
    db 0

Sprite4:
    db $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa 
    db $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa 
    db $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa 
    db 0