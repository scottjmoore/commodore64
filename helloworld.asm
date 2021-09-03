    org $0801               ; Start of BASIC program memory

    dw $080b                ; Next line pointer
    dw $000a                ; Line 10
    db $9e," 2064"          ; SYS 2064 ($0810)
    db $00,$00,$00,$00,$00  ; zero padding

    struct  Sprite
        y:  db $00
        x:  dw $0000
        ptr:    dw $0000
    endstruct

Start:
    jsr InitScreen
    jsr InitInterrupts

Loop:
    lda $dc00
    and #1<<4
    bne NoFire
    jmp Exit
NoFire:
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

RasterStart     equ 49
RasterSize      equ 16
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
    lda #$03
    sta $d020
    lda #RasterStart + (RasterSize * 3)
    sta $d012
    lda #<IrqService4
    sta $0314
    lda #>IrqService4
    sta $0315
    asl $d019
    jmp $ea81
    
IrqService4:
    lda #$04
    sta $d020
    lda #RasterStart + (RasterSize * 4)
    sta $d012
    lda #<IrqService5
    sta $0314
    lda #>IrqService5
    sta $0315
    asl $d019
    jmp $ea81
    
IrqService5:
    lda #$05
    sta $d020
    lda #RasterStart + (RasterSize * 5)
    sta $d012
    lda #<IrqService6
    sta $0314
    lda #>IrqService6
    sta $0315
    asl $d019
    jmp $ea81
    
IrqService6:
    lda #$06
    sta $d020
    lda #RasterStart + (RasterSize * 6)
    sta $d012
    lda #<IrqService7
    sta $0314
    lda #>IrqService7
    sta $0315
    asl $d019
    jmp $ea81
    
IrqService7:
    lda #$07
    sta $d020
    lda #RasterStart + (RasterSize * 7)
    sta $d012
    lda #<IrqService8
    sta $0314
    lda #>IrqService8
    sta $0315
    asl $d019
    jmp $ea81
    
IrqService8:
    lda #$08
    sta $d020
    lda #RasterStart + (RasterSize * 8)
    sta $d012
    lda #<IrqService9
    sta $0314
    lda #>IrqService9
    sta $0315
    asl $d019
    jmp $ea81
    
IrqService9:
    lda #$09
    sta $d020
    lda #RasterStart + (RasterSize * 9)
    sta $d012
    lda #<IrqService10
    sta $0314
    lda #>IrqService10
    sta $0315
    asl $d019
    jmp $ea81
    
IrqService10:
    lda #$0a
    sta $d020
    lda #RasterStart + (RasterSize * 10)
    sta $d012
    lda #<IrqService11
    sta $0314
    lda #>IrqService11
    sta $0315
    asl $d019
    jmp $ea81
    
IrqService11:
    lda #$0b
    sta $d020
    lda #RasterStart + (RasterSize * 11)
    sta $d012
    lda #<IrqService12
    sta $0314
    lda #>IrqService12
    sta $0315
    asl $d019
    jmp $ea81
    
IrqService12:
    lda #$0c
    sta $d020
    lda #RasterStart + (RasterSize * 12)
    sta $d012
    lda #<IrqServiceLast
    sta $0314
    lda #>IrqServiceLast
    sta $0315
    asl $d019
    jmp $ea81
    
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
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite

SpriteList2:
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite

SpriteList3:
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite
    Sprite

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
