CharBuffer1         equ $0400
CharBuffer2         equ $0800
ColorBuffer         equ $d800

    org $0801               ; Start of BASIC program memory

    dw $080b                ; Next line pointer
    dw $000a                ; Line 10
    db $9e," 3072"          ; SYS 2064 ($0810)
    db $00,$00,$00,$00,$00  ; zero padding

    org $0c00
Start:
    jsr InitScreen

Loop:

    lda #$00
.WaitStart
    cmp $d012
    bne .WaitStart

    lda #$f6
.WaitEnd
    cmp $d012
    bne .WaitEnd

    ; lda ScrollY
    ; bne NoRight
    ; lda ScrollX
    ; bne NoRight

    lda $dc00
    and #1<<0
    bne NoUp
    lda #8
    sta ScrollingDecY
NoUp:
    lda $dc00
    and #1<<1
    bne NoDown
    lda #8
    sta ScrollingIncY
NoDown:
    lda $dc00
    and #1<<2
    bne NoLeft
    lda #8
    sta ScrollingDecX
NoLeft:
    lda $dc00
    and #1<<3
    bne NoRight
    lda #8
    sta ScrollingIncX
NoRight:
    lda $dc00
    and #1<<4
    bne NoFire
    jmp Exit
NoFire:
    lda ScrollingIncX
    beq .NoScrollingIncX

    lda ScrollX
    and #1
    bne .SkipParallax
    lda CharacterSet+(238*8)+0
    rol a
    rol CharacterSet+(238*8)+0
    lda CharacterSet+(238*8)+1
    rol a
    rol CharacterSet+(238*8)+1
    lda CharacterSet+(238*8)+2
    rol a
    rol CharacterSet+(238*8)+2
    lda CharacterSet+(238*8)+3
    rol a
    rol CharacterSet+(238*8)+3
    lda CharacterSet+(238*8)+4
    rol a
    rol CharacterSet+(238*8)+4
    lda CharacterSet+(238*8)+5
    rol a
    rol CharacterSet+(238*8)+5
    lda CharacterSet+(238*8)+6
    rol a
    rol CharacterSet+(238*8)+6
    lda CharacterSet+(238*8)+7
    rol a
    rol CharacterSet+(238*8)+7
.SkipParallax

    dec ScrollingIncX
    jsr ScrollIncX

    
    cmp #$03
    bne .ScrollCharBuffer1to2
    lda $d018
    and #%00110000
    cmp #%00010000
    beq .ScrollCharBuffer2to1
    jsr ScrollCharBuffer2to1IncX
    jmp .ScrollCharBuffer1to2
.ScrollCharBuffer2to1
    jsr ScrollCharBuffer1to2IncX
.ScrollCharBuffer1to2
    lda ScrollX
    cmp #$01
    bne .NoFlipBuffers
    jsr FlipBuffers
    jsr ScrollColorBufferIncX
.NoFlipBuffers

.NoScrollingIncX:

    jmp Loop

Exit:
    jmp ($fffc)             ; Jump to code stored in 6502 reset vector

ScrollX:
    db $01
ScrollY:
    db $00

ScrollingIncX:
    db $00
ScrollingDecX:
    db $00
ScrollingIncY:
    db $00
ScrollingDecY:
    db $00

InitScreen:
    jsr $e544               ; Clear the screen

    lda $d018
    and #%00001111
    ora #%00010000
    sta $d018

    lda #$00                ; Load accumulator with colour value for black
    sta $d020               ; Set border colour to black
    sta $d021               ; Set background colour 0 to black

    ldy #0                  ; Set Y register to count 256 times
    ldx #3
InitScreenLoop1:
    lda Screen1Char,y
    sta CharBuffer1,y             ; Store the accumulator in screen memory + Y register
    sta CharBuffer2,y             ; Store the accumulator in screen memory + Y register
    lda Screen1Color,y
    sta ColorBuffer,y             ; Store the accumulator in colour memory + Y register
    clc
    adc #1
    iny                     ; increment the Y register
    bne InitScreenLoop1           ; If != 0 go back to StartLoop
    inc InitScreenLoop1 + 2
    inc InitScreenLoop1 + 5
    inc InitScreenLoop1 + 8
    inc InitScreenLoop1 + 11
    inc InitScreenLoop1 + 14
    dex
    bne InitScreenLoop1

InitScreenLoop2:
    lda Screen1Char + $0300,y
    sta CharBuffer1 + $0300,y             ; Store the accumulator in screen memory + Y register
    sta CharBuffer2 + $0300,y             ; Store the accumulator in screen memory + Y register
    lda Screen1Color + $0300,y
    sta ColorBuffer + $0300,y             ; Store the accumulator in colour memory + Y register
    clc
    adc #1
    iny                     ; increment the Y register
    cpy #232
    bne InitScreenLoop2      ; If != 232 go back to StartLoop

    lda $d011
    and #%11110000
    ora ScrollY
    sta $d011
    lda $d016
    and #%11110000
    ora ScrollX
    sta $d016

    jsr SetCharacterSet

    rts

FlipBuffers:
    lda $d018
    eor #%00110000
    sta $d018
    rts 

ScrollIncX:
    lda $d016
    and #%11111000
    ora ScrollX
    sta $d016
    inc ScrollX
    lda ScrollX
    and #%00000111
    sta ScrollX
    rts

ScrollDecX:
    lda $d016
    and #%11111000
    ora ScrollX
    sta $d016
    dec ScrollX
    lda ScrollX
    and #%00000111
    sta ScrollX
    rts

ScrollIncY:
    lda $d011
    and #%11111000
    ora ScrollY
    sta $d011
    inc ScrollY
    lda ScrollY
    and #%00000111
    sta ScrollY
    rts

ScrollDecY:
    lda $d011
    and #%11111000
    ora ScrollY
    sta $d011
    dec ScrollY
    lda ScrollY
    and #%00000111
    sta ScrollY
    rts

ScrollCharBuffer1To2IncX:
    lda CharBuffer1+(0 * 40)+39
    sta CharBuffer2+(0 * 40)
    lda CharBuffer1+(1 * 40)+39
    sta CharBuffer2+(1 * 40)
    lda CharBuffer1+(2 * 40)+39
    sta CharBuffer2+(2 * 40)
    lda CharBuffer1+(3 * 40)+39
    sta CharBuffer2+(3 * 40)
    lda CharBuffer1+(4 * 40)+39
    sta CharBuffer2+(4 * 40)
    lda CharBuffer1+(5 * 40)+39
    sta CharBuffer2+(5 * 40)
    lda CharBuffer1+(6 * 40)+39
    sta CharBuffer2+(6 * 40)
    lda CharBuffer1+(7 * 40)+39
    sta CharBuffer2+(7 * 40)
    lda CharBuffer1+(8 * 40)+39
    sta CharBuffer2+(8 * 40)
    lda CharBuffer1+(9 * 40)+39
    sta CharBuffer2+(9 * 40)
    lda CharBuffer1+(10 * 40)+39
    sta CharBuffer2+(10 * 40)
    lda CharBuffer1+(11 * 40)+39
    sta CharBuffer2+(11 * 40)
    lda CharBuffer1+(12 * 40)+39
    sta CharBuffer2+(12 * 40)
    lda CharBuffer1+(13 * 40)+39
    sta CharBuffer2+(13 * 40)
    lda CharBuffer1+(14 * 40)+39
    sta CharBuffer2+(14 * 40)
    lda CharBuffer1+(15 * 40)+39
    sta CharBuffer2+(15 * 40)
    lda CharBuffer1+(16 * 40)+39
    sta CharBuffer2+(16 * 40)
    lda CharBuffer1+(17 * 40)+39
    sta CharBuffer2+(17 * 40)
    lda CharBuffer1+(18 * 40)+39
    sta CharBuffer2+(18 * 40)
    lda CharBuffer1+(19 * 40)+39
    sta CharBuffer2+(19 * 40)
    lda CharBuffer1+(20 * 40)+39
    sta CharBuffer2+(20 * 40)
    lda CharBuffer1+(21 * 40)+39
    sta CharBuffer2+(21 * 40)
    lda CharBuffer1+(22 * 40)+39
    sta CharBuffer2+(22 * 40)
    lda CharBuffer1+(23 * 40)+39
    sta CharBuffer2+(23 * 40)
    lda CharBuffer1+(24 * 40)+39
    sta CharBuffer2+(24 * 40)
    ldx #39
.CopyLines
    lda CharBuffer1+(0 * 40)-1,x
    sta CharBuffer2+(0 * 40),x
    lda CharBuffer1+(1 * 40)-1,x
    sta CharBuffer2+(1 * 40),x
    lda CharBuffer1+(2 * 40)-1,x
    sta CharBuffer2+(2 * 40),x
    lda CharBuffer1+(3 * 40)-1,x
    sta CharBuffer2+(3 * 40),x
    lda CharBuffer1+(4 * 40)-1,x
    sta CharBuffer2+(4 * 40),x
    lda CharBuffer1+(5 * 40)-1,x
    sta CharBuffer2+(5 * 40),x
    lda CharBuffer1+(6 * 40)-1,x
    sta CharBuffer2+(6 * 40),x
    lda CharBuffer1+(7 * 40)-1,x
    sta CharBuffer2+(7 * 40),x
    lda CharBuffer1+(8 * 40)-1,x
    sta CharBuffer2+(8 * 40),x
    lda CharBuffer1+(9 * 40)-1,x
    sta CharBuffer2+(9 * 40),x
    lda CharBuffer1+(10 * 40)-1,x
    sta CharBuffer2+(10 * 40),x
    lda CharBuffer1+(11 * 40)-1,x
    sta CharBuffer2+(11 * 40),x
    lda CharBuffer1+(12 * 40)-1,x
    sta CharBuffer2+(12 * 40),x
    lda CharBuffer1+(13 * 40)-1,x
    sta CharBuffer2+(13 * 40),x
    lda CharBuffer1+(14 * 40)-1,x
    sta CharBuffer2+(14 * 40),x
    lda CharBuffer1+(15 * 40)-1,x
    sta CharBuffer2+(15 * 40),x
    lda CharBuffer1+(16 * 40)-1,x
    sta CharBuffer2+(16 * 40),x
    lda CharBuffer1+(17 * 40)-1,x
    sta CharBuffer2+(17 * 40),x
    lda CharBuffer1+(18 * 40)-1,x
    sta CharBuffer2+(18 * 40),x
    lda CharBuffer1+(19 * 40)-1,x
    sta CharBuffer2+(19 * 40),x
    lda CharBuffer1+(20 * 40)-1,x
    sta CharBuffer2+(20 * 40),x
    lda CharBuffer1+(21 * 40)-1,x
    sta CharBuffer2+(21 * 40),x
    lda CharBuffer1+(22 * 40)-1,x
    sta CharBuffer2+(22 * 40),x
    lda CharBuffer1+(23 * 40)-1,x
    sta CharBuffer2+(23 * 40),x
    lda CharBuffer1+(24 * 40)-1,x
    sta CharBuffer2+(24 * 40),x
    dex
    beq .StopCopyLines
    jmp .CopyLines
.StopCopyLines
    rts

ScrollCharBuffer2To1IncX:
    lda CharBuffer2+(0 * 40)+39
    sta CharBuffer1+(0 * 40)
    lda CharBuffer2+(1 * 40)+39
    sta CharBuffer1+(1 * 40)
    lda CharBuffer2+(2 * 40)+39
    sta CharBuffer1+(2 * 40)
    lda CharBuffer2+(3 * 40)+39
    sta CharBuffer1+(3 * 40)
    lda CharBuffer2+(4 * 40)+39
    sta CharBuffer1+(4 * 40)
    lda CharBuffer2+(5 * 40)+39
    sta CharBuffer1+(5 * 40)
    lda CharBuffer2+(6 * 40)+39
    sta CharBuffer1+(6 * 40)
    lda CharBuffer2+(7 * 40)+39
    sta CharBuffer1+(7 * 40)
    lda CharBuffer2+(8 * 40)+39
    sta CharBuffer1+(8 * 40)
    lda CharBuffer2+(9 * 40)+39
    sta CharBuffer1+(9 * 40)
    lda CharBuffer2+(10 * 40)+39
    sta CharBuffer1+(10 * 40)
    lda CharBuffer2+(11 * 40)+39
    sta CharBuffer1+(11 * 40)
    lda CharBuffer2+(12 * 40)+39
    sta CharBuffer1+(12 * 40)
    lda CharBuffer2+(13 * 40)+39
    sta CharBuffer1+(13 * 40)
    lda CharBuffer2+(14 * 40)+39
    sta CharBuffer1+(14 * 40)
    lda CharBuffer2+(15 * 40)+39
    sta CharBuffer1+(15 * 40)
    lda CharBuffer2+(16 * 40)+39
    sta CharBuffer1+(16 * 40)
    lda CharBuffer2+(17 * 40)+39
    sta CharBuffer1+(17 * 40)
    lda CharBuffer2+(18 * 40)+39
    sta CharBuffer1+(18 * 40)
    lda CharBuffer2+(19 * 40)+39
    sta CharBuffer1+(19 * 40)
    lda CharBuffer2+(20 * 40)+39
    sta CharBuffer1+(20 * 40)
    lda CharBuffer2+(21 * 40)+39
    sta CharBuffer1+(21 * 40)
    lda CharBuffer2+(22 * 40)+39
    sta CharBuffer1+(22 * 40)
    lda CharBuffer2+(23 * 40)+39
    sta CharBuffer1+(23 * 40)
    lda CharBuffer2+(24 * 40)+39
    sta CharBuffer1+(24 * 40)
    ldx #39
.CopyLines
    lda CharBuffer2+(0 * 40)-1,x
    sta CharBuffer1+(0 * 40),x
    lda CharBuffer2+(1 * 40)-1,x
    sta CharBuffer1+(1 * 40),x
    lda CharBuffer2+(2 * 40)-1,x
    sta CharBuffer1+(2 * 40),x
    lda CharBuffer2+(3 * 40)-1,x
    sta CharBuffer1+(3 * 40),x
    lda CharBuffer2+(4 * 40)-1,x
    sta CharBuffer1+(4 * 40),x
    lda CharBuffer2+(5 * 40)-1,x
    sta CharBuffer1+(5 * 40),x
    lda CharBuffer2+(6 * 40)-1,x
    sta CharBuffer1+(6 * 40),x
    lda CharBuffer2+(7 * 40)-1,x
    sta CharBuffer1+(7 * 40),x
    lda CharBuffer2+(8 * 40)-1,x
    sta CharBuffer1+(8 * 40),x
    lda CharBuffer2+(9 * 40)-1,x
    sta CharBuffer1+(9 * 40),x
    lda CharBuffer2+(10 * 40)-1,x
    sta CharBuffer1+(10 * 40),x
    lda CharBuffer2+(11 * 40)-1,x
    sta CharBuffer1+(11 * 40),x
    lda CharBuffer2+(12 * 40)-1,x
    sta CharBuffer1+(12 * 40),x
    lda CharBuffer2+(13 * 40)-1,x
    sta CharBuffer1+(13 * 40),x
    lda CharBuffer2+(14 * 40)-1,x
    sta CharBuffer1+(14 * 40),x
    lda CharBuffer2+(15 * 40)-1,x
    sta CharBuffer1+(15 * 40),x
    lda CharBuffer2+(16 * 40)-1,x
    sta CharBuffer1+(16 * 40),x
    lda CharBuffer2+(17 * 40)-1,x
    sta CharBuffer1+(17 * 40),x
    lda CharBuffer2+(18 * 40)-1,x
    sta CharBuffer1+(18 * 40),x
    lda CharBuffer2+(19 * 40)-1,x
    sta CharBuffer1+(19 * 40),x
    lda CharBuffer2+(20 * 40)-1,x
    sta CharBuffer1+(20 * 40),x
    lda CharBuffer2+(21 * 40)-1,x
    sta CharBuffer1+(21 * 40),x
    lda CharBuffer2+(22 * 40)-1,x
    sta CharBuffer1+(22 * 40),x
    lda CharBuffer2+(23 * 40)-1,x
    sta CharBuffer1+(23 * 40),x
    lda CharBuffer2+(24 * 40)-1,x
    sta CharBuffer1+(24 * 40),x
    dex
    beq .StopCopyLines
    jmp .CopyLines
.StopCopyLines
    rts

ScrollColorBufferIncX:
    lda ColorBuffer+(0 * 40)+39
    pha 
    ldx #39
.CopyLine0
    lda ColorBuffer+(0 * 40)-1,x
    sta ColorBuffer+(0 * 40),x
    dex 
    bne .CopyLine0
    pla 
    sta ColorBuffer+(0*40)

    lda ColorBuffer+(1 * 40)+39
    pha 
    ldx #39
.CopyLine1
    lda ColorBuffer+(1 * 40)-1,x
    sta ColorBuffer+(1 * 40),x
    dex 
    bne .CopyLine1
    pla 
    sta ColorBuffer+(1*40)

    lda ColorBuffer+(2 * 40)+39
    pha 
    ldx #39
.CopyLine2
    lda ColorBuffer+(2 * 40)-1,x
    sta ColorBuffer+(2 * 40),x
    dex 
    bne .CopyLine2
    pla 
    sta ColorBuffer+(2*40)

    lda ColorBuffer+(3 * 40)+39
    pha 
    ldx #39
.CopyLine3
    lda ColorBuffer+(3 * 40)-1,x
    sta ColorBuffer+(3 * 40),x
    dex 
    bne .CopyLine3
    pla 
    sta ColorBuffer+(3 *40)

    lda ColorBuffer+(4 * 40)+39
    pha 
    ldx #39
.CopyLine4
    lda ColorBuffer+(4 * 40)-1,x
    sta ColorBuffer+(4 * 40),x
    dex 
    bne .CopyLine4
    pla 
    sta ColorBuffer+(4*40)

    lda ColorBuffer+(5 * 40)+39
    pha 
    ldx #39
.CopyLine5
    lda ColorBuffer+(5 * 40)-1,x
    sta ColorBuffer+(5 * 40),x
    dex 
    bne .CopyLine5
    pla 
    sta ColorBuffer+(5*40)
    
    lda ColorBuffer+(6 * 40)+39
    pha 
    ldx #39
.CopyLine6
    lda ColorBuffer+(6 * 40)-1,x
    sta ColorBuffer+(6 * 40),x
    dex 
    bne .CopyLine6
    pla 
    sta ColorBuffer+(6*40)
    
    lda ColorBuffer+(7 * 40)+39
    pha 
    ldx #39
.CopyLine7
    lda ColorBuffer+(7 * 40)-1,x
    sta ColorBuffer+(7 * 40),x
    dex 
    bne .CopyLine7
    pla 
    sta ColorBuffer+(7*40)
    
    lda ColorBuffer+(8 * 40)+39
    pha 
    ldx #39
.CopyLine8
    lda ColorBuffer+(8 * 40)-1,x
    sta ColorBuffer+(8 * 40),x
    dex 
    bne .CopyLine8
    pla 
    sta ColorBuffer+(8*40)
    
    lda ColorBuffer+(9 * 40)+39
    pha 
    ldx #39
.CopyLine9
    lda ColorBuffer+(9 * 40)-1,x
    sta ColorBuffer+(9 * 40),x
    dex 
    bne .CopyLine9
    pla 
    sta ColorBuffer+(9*40)
    
    lda ColorBuffer+(10 * 40)+39
    pha 
    ldx #39
.CopyLine10
    lda ColorBuffer+(10 * 40)-1,x
    sta ColorBuffer+(10 * 40),x
    dex 
    bne .CopyLine10
    pla 
    sta ColorBuffer+(10*40)
    
    lda ColorBuffer+(11 * 40)+39
    pha 
    ldx #39
.CopyLine11
    lda ColorBuffer+(11 * 40)-1,x
    sta ColorBuffer+(11 * 40),x
    dex 
    bne .CopyLine11
    pla 
    sta ColorBuffer+(11*40)
    
    lda ColorBuffer+(12 * 40)+39
    pha 
    ldx #39
.CopyLine12
    lda ColorBuffer+(12 * 40)-1,x
    sta ColorBuffer+(12 * 40),x
    dex 
    bne .CopyLine12
    pla 
    sta ColorBuffer+(12*40)
    
    lda ColorBuffer+(13 * 40)+39
    pha 
    ldx #39
.CopyLine13
    lda ColorBuffer+(13 * 40)-1,x
    sta ColorBuffer+(13 * 40),x
    dex 
    bne .CopyLine13
    pla 
    sta ColorBuffer+(13*40)
    
    lda ColorBuffer+(14 * 40)+39
    pha 
    ldx #39
.CopyLine14
    lda ColorBuffer+(14 * 40)-1,x
    sta ColorBuffer+(14 * 40),x
    dex 
    bne .CopyLine14
    pla 
    sta ColorBuffer+(14*40)
    
    lda ColorBuffer+(15 * 40)+39
    pha 
    ldx #39
.CopyLine15
    lda ColorBuffer+(15 * 40)-1,x
    sta ColorBuffer+(15 * 40),x
    dex 
    bne .CopyLine15
    pla 
    sta ColorBuffer+(15*40)
    
    lda ColorBuffer+(16 * 40)+39
    pha 
    ldx #39
.CopyLine16
    lda ColorBuffer+(16 * 40)-1,x
    sta ColorBuffer+(16 * 40),x
    dex 
    bne .CopyLine16
    pla 
    sta ColorBuffer+(16*40)
    
    lda ColorBuffer+(17 * 40)+39
    pha 
    ldx #39
.CopyLine17
    lda ColorBuffer+(17 * 40)-1,x
    sta ColorBuffer+(17 * 40),x
    dex 
    bne .CopyLine17
    pla 
    sta ColorBuffer+(17*40)
    
    lda ColorBuffer+(18 * 40)+39
    pha 
    ldx #39
.CopyLine18
    lda ColorBuffer+(18 * 40)-1,x
    sta ColorBuffer+(18 * 40),x
    dex 
    bne .CopyLine18
    pla 
    sta ColorBuffer+(18*40)
    
    lda ColorBuffer+(19 * 40)+39
    pha 
    ldx #39
.CopyLine19
    lda ColorBuffer+(19 * 40)-1,x
    sta ColorBuffer+(19 * 40),x
    dex 
    bne .CopyLine19
    pla 
    sta ColorBuffer+(19*40)
    
    lda ColorBuffer+(20 * 40)+39
    pha 
    ldx #39
.CopyLine20
    lda ColorBuffer+(20 * 40)-1,x
    sta ColorBuffer+(20 * 40),x
    dex 
    bne .CopyLine20
    pla 
    sta ColorBuffer+(20*40)
    
    lda ColorBuffer+(21 * 40)+39
    pha 
    ldx #39
.CopyLine21
    lda ColorBuffer+(21 * 40)-1,x
    sta ColorBuffer+(21 * 40),x
    dex 
    bne .CopyLine21
    pla 
    sta ColorBuffer+(21*40)
    
    lda ColorBuffer+(22 * 40)+39
    pha 
    ldx #39
.CopyLine22
    lda ColorBuffer+(22 * 40)-1,x
    sta ColorBuffer+(22 * 40),x
    dex 
    bne .CopyLine22
    pla 
    sta ColorBuffer+(22*40)
    
    lda ColorBuffer+(23 * 40)+39
    pha 
    ldx #39
.CopyLine23
    lda ColorBuffer+(23 * 40)-1,x
    sta ColorBuffer+(23 * 40),x
    dex 
    bne .CopyLine23
    pla 
    sta ColorBuffer+(23*40)
    
    lda ColorBuffer+(24 * 40)+39
    pha 
    ldx #39
.CopyLine24
    lda ColorBuffer+(24 * 40)-1,x
    sta ColorBuffer+(24 * 40),x
    dex 
    bne .CopyLine24
    pla 
    sta ColorBuffer+(24*40)
    
.Exit
    rts 

SetCharacterSet:
    lda $d018
    and #%11110001
    ora #(CharacterSet / 2048) << 1
    sta $d018
    rts 

    org $2000
CharacterSet:
	db	$00, $00, $00, $00, $00, $00, $00, $00
	db	$3C, $42, $42, $7E, $42, $42, $42, $00
	db	$7C, $42, $42, $7C, $42, $42, $7C, $00
	db	$3C, $42, $40, $40, $40, $42, $3C, $00
	db	$78, $44, $42, $42, $42, $44, $78, $00
	db	$7E, $40, $40, $78, $40, $40, $7E, $00
	db	$7E, $40, $40, $78, $40, $40, $40, $00
	db	$3C, $42, $40, $4E, $42, $42, $3C, $00
	db	$42, $42, $42, $7E, $42, $42, $42, $00
	db	$7C, $10, $10, $10, $10, $10, $7C, $00
	db	$3E, $09, $09, $09, $09, $48, $30, $00
	db	$44, $48, $50, $60, $50, $48, $44, $00
	db	$40, $40, $40, $40, $40, $40, $7E, $00
	db	$63, $55, $49, $41, $41, $41, $41, $00
	db	$42, $62, $52, $4A, $46, $42, $42, $00
	db	$3C, $42, $42, $42, $42, $42, $3C, $00
	db	$7C, $42, $42, $7C, $40, $40, $40, $00
	db	$3C, $42, $42, $42, $4A, $46, $3C, $00
	db	$7C, $42, $42, $7C, $48, $44, $42, $00
	db	$3C, $42, $40, $3C, $02, $42, $3C, $00
	db	$7F, $09, $09, $09, $09, $09, $09, $00
	db	$42, $42, $42, $42, $42, $42, $3C, $00
	db	$42, $42, $42, $42, $42, $24, $18, $00
	db	$41, $41, $41, $41, $49, $55, $63, $00
	db	$41, $22, $14, $09, $14, $22, $41, $00
	db	$66, $66, $66, $3C, $18, $18, $18, $00
	db	$7E, $02, $04, $09, $10, $20, $7E, $00
	db	$3C, $20, $20, $20, $20, $20, $3C, $00
	db	$0C, $12, $20, $7C, $20, $42, $FC, $00
	db	$3C, $04, $04, $04, $04, $04, $3C, $00
	db	$09, $1C, $3E, $7F, $09, $09, $09, $09
	db	$10, $30, $70, $FF, $70, $30, $10, $00
	db	$00, $00, $00, $00, $00, $00, $00, $00
	db	$09, $09, $09, $09, $00, $00, $09, $00
	db	$22, $22, $22, $44, $00, $00, $00, $00
	db	$22, $22, $7F, $22, $7F, $22, $22, $00
	db	$09, $3E, $40, $3C, $02, $7C, $09, $00
	db	$61, $62, $04, $09, $10, $23, $43, $00
	db	$3C, $42, $34, $28, $47, $42, $3F, $00
	db	$02, $04, $09, $00, $00, $00, $00, $00
	db	$0C, $10, $20, $20, $20, $10, $0C, $00
	db	$30, $09, $04, $04, $04, $09, $30, $00
	db	$00, $22, $14, $7F, $14, $22, $00, $00
	db	$00, $09, $09, $3E, $09, $09, $00, $00
	db	$00, $00, $00, $00, $00, $09, $09, $10
	db	$00, $00, $00, $7E, $00, $00, $00, $00
	db	$00, $00, $00, $00, $00, $18, $18, $00
	db	$00, $02, $04, $09, $10, $20, $40, $00
	db	$3C, $46, $4A, $52, $62, $42, $3C, $00
	db	$09, $18, $28, $09, $09, $09, $7E, $00
	db	$3C, $42, $02, $0C, $30, $40, $7E, $00
	db	$3C, $42, $02, $1C, $02, $42, $3C, $00
	db	$0C, $14, $24, $44, $7F, $04, $04, $00
	db	$7E, $40, $7C, $02, $02, $42, $3C, $00
	db	$3C, $42, $40, $7C, $42, $42, $3C, $00
	db	$7E, $42, $04, $09, $10, $10, $10, $00
	db	$3C, $42, $42, $3C, $42, $42, $3C, $00
	db	$3C, $42, $42, $3E, $02, $42, $3C, $00
	db	$00, $00, $09, $00, $00, $09, $00, $00
	db	$00, $00, $09, $00, $00, $09, $09, $10
	db	$04, $09, $10, $20, $10, $09, $04, $00
	db	$00, $00, $7E, $00, $7E, $00, $00, $00
	db	$10, $09, $04, $02, $04, $09, $10, $00
	db	$3C, $42, $02, $04, $09, $00, $09, $00
	db	$00, $00, $00, $FF, $FF, $00, $00, $00
	db	$09, $1C, $3E, $7F, $7F, $1C, $3E, $00
	db	$18, $18, $18, $18, $18, $18, $18, $18
	db	$00, $00, $00, $FF, $FF, $C3, $66, $3C
	db	$00, $00, $FF, $FF, $00, $00, $00, $00
	db	$00, $FF, $FF, $00, $00, $00, $00, $00
	db	$00, $00, $00, $00, $FF, $FF, $00, $00
	db	$30, $30, $30, $30, $30, $30, $30, $30
	db	$0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
	db	$00, $00, $00, $E0, $F0, $38, $18, $18
	db	$18, $18, $1C, $0F, $07, $00, $00, $00
	db	$18, $18, $38, $F0, $E0, $00, $00, $00
	db	$C0, $C0, $C0, $C0, $C0, $C0, $FF, $FF
	db	$C0, $E0, $70, $38, $1C, $0E, $07, $03
	db	$03, $07, $0E, $1C, $38, $70, $E0, $C0
	db	$FF, $FF, $C0, $C0, $C0, $C0, $C0, $C0
	db	$FF, $FF, $03, $03, $03, $03, $03, $03
	db	$00, $3C, $7E, $7E, $7E, $7E, $3C, $00
	db	$00, $00, $00, $00, $00, $FF, $FF, $00
	db	$36, $7F, $7F, $7F, $3E, $1C, $09, $00
	db	$60, $60, $60, $60, $60, $60, $60, $60
	db	$00, $00, $00, $07, $0F, $1C, $18, $18
	db	$C3, $E7, $7E, $3C, $3C, $7E, $E7, $C3
	db	$00, $3C, $7E, $66, $66, $7E, $3C, $00
	db	$18, $18, $66, $66, $18, $18, $3C, $00
	db	$06, $06, $06, $06, $06, $06, $06, $06
	db	$09, $1C, $3E, $7F, $3E, $1C, $09, $00
	db	$18, $18, $18, $FF, $FF, $18, $18, $18
	db	$C0, $C0, $30, $30, $C0, $C0, $30, $30
	db	$18, $18, $18, $18, $18, $18, $18, $18
	db	$00, $00, $03, $3E, $76, $36, $36, $00
	db	$FF, $7F, $3F, $1F, $0F, $07, $03, $01
	db	$00, $00, $00, $00, $00, $00, $00, $00
	db	$F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
	db	$00, $00, $00, $00, $FF, $FF, $FF, $FF
	db	$FF, $00, $00, $00, $00, $00, $00, $00
	db	$00, $00, $00, $00, $00, $00, $00, $FF
	db	$C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0
	db	$CC, $CC, $33, $33, $CC, $CC, $33, $33
	db	$03, $03, $03, $03, $03, $03, $03, $03
	db	$00, $00, $00, $00, $CC, $CC, $33, $33
	db	$FF, $FE, $FC, $F8, $F0, $E0, $C0, $80
	db	$03, $03, $03, $03, $03, $03, $03, $03
	db	$60, $60, $60, $7F, $7F, $60, $60, $60
	db	$00, $00, $00, $00, $0F, $0F, $0F, $0F
	db	$18, $18, $18, $1F, $1F, $00, $00, $00
	db	$00, $00, $00, $F8, $F8, $18, $18, $18
	db	$00, $00, $00, $00, $00, $00, $FF, $FF
	db	$00, $00, $00, $1F, $1F, $18, $18, $18
	db	$18, $18, $18, $FF, $FF, $00, $00, $00
	db	$00, $00, $00, $FF, $FF, $18, $18, $18
	db	$06, $06, $06, $FE, $FE, $06, $06, $06
	db	$C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0
	db	$E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
	db	$07, $07, $07, $07, $07, $07, $07, $07
	db	$FF, $FF, $00, $00, $00, $00, $00, $00
	db	$FF, $FF, $FF, $00, $00, $00, $00, $00
	db	$00, $00, $00, $00, $00, $FF, $FF, $FF
	db	$03, $03, $03, $03, $03, $03, $FF, $FF
	db	$00, $00, $00, $00, $F0, $F0, $F0, $F0
	db	$0F, $0F, $0F, $0F, $00, $00, $00, $00
	db	$18, $18, $18, $F8, $F8, $00, $00, $00
	db	$F0, $F0, $F0, $F0, $00, $00, $00, $00
	db	$F0, $F0, $F0, $F0, $0F, $0F, $0F, $0F
	db	$C3, $99, $91, $91, $9F, $99, $C3, $FF
	db	$FF, $FF, $38, $6C, $C6, $83, $FF, $FF
	db	$FF, $38, $6C, $C6, $83, $FF, $FF, $00
	db	$38, $6C, $C6, $83, $FF, $FF, $00, $00
	db	$6C, $C6, $83, $FF, $FF, $00, $00, $00
	db	$C6, $83, $FF, $FF, $00, $00, $00, $00
	db	$83, $FF, $FF, $00, $00, $00, $00, $00
	db	$FF, $FF, $00, $00, $00, $00, $00, $00
	db	$FF, $00, $00, $00, $00, $00, $00, $00
	db	$00, $FF, $FF, $38, $6C, $C6, $83, $FF
	db	$00, $00, $FF, $FF, $38, $6C, $C6, $83
	db	$00, $00, $00, $FF, $FF, $38, $6C, $C6
	db	$00, $00, $00, $00, $FF, $FF, $38, $6C
	db	$00, $00, $00, $00, $00, $FF, $FF, $38
	db	$00, $00, $00, $00, $00, $00, $FF, $FF
	db	$00, $00, $00, $00, $00, $00, $00, $FF
	db	$00, $00, $00, $00, $81, $FF, $81, $81
	db	$C3, $99, $99, $99, $99, $C3, $F1, $FF
	db	$83, $99, $99, $83, $87, $93, $99, $FF
	db	$C3, $99, $9F, $C3, $F9, $99, $C3, $FF
	db	$81, $E7, $E7, $E7, $E7, $E7, $E7, $FF
	db	$99, $99, $99, $99, $99, $99, $C3, $FF
	db	$99, $99, $99, $99, $99, $C3, $E7, $FF
	db	$9C, $9C, $9C, $94, $80, $88, $9C, $FF
	db	$99, $99, $C3, $E7, $C3, $99, $99, $FF
	db	$99, $99, $99, $C3, $E7, $E7, $E7, $FF
	db	$81, $F9, $F3, $E7, $CF, $9F, $81, $FF
	db	$C3, $CF, $CF, $CF, $CF, $CF, $C3, $FF
	db	$F3, $ED, $CF, $83, $CF, $9D, $03, $FF
	db	$C3, $F3, $F3, $F3, $F3, $F3, $C3, $FF
	db	$FF, $E7, $C3, $81, $E7, $E7, $E7, $E7
	db	$FF, $EF, $CF, $80, $80, $CF, $EF, $FF
	db	$81, $FF, $81, $81, $81, $FF, $81, $81
	db	$E7, $E7, $E7, $E7, $FF, $FF, $E7, $FF
	db	$99, $99, $99, $FF, $FF, $FF, $FF, $FF
	db	$99, $99, $00, $99, $00, $99, $99, $FF
	db	$E7, $C1, $9F, $C3, $F9, $83, $E7, $FF
	db	$9D, $99, $F3, $E7, $CF, $99, $B9, $FF
	db	$C3, $99, $C3, $C7, $98, $99, $C0, $FF
	db	$F9, $F3, $E7, $FF, $FF, $FF, $FF, $FF
	db	$F3, $E7, $CF, $CF, $CF, $E7, $F3, $FF
	db	$CF, $E7, $F3, $F3, $F3, $E7, $CF, $FF
	db	$FF, $00, $00, $00, $00, $00, $00, $00
	db	$FF, $E7, $E7, $81, $E7, $E7, $FF, $FF
	db	$FF, $FF, $FF, $FF, $FF, $E7, $E7, $CF
	db	$00, $00, $00, $FF, $FF, $18, $24, $42
	db	$FF, $FF, $FF, $FF, $FF, $E7, $E7, $FF
	db	$81, $FF, $FF, $00, $00, $00, $00, $00
	db	$C3, $99, $91, $89, $99, $99, $C3, $FF
	db	$E7, $E7, $C7, $E7, $E7, $E7, $81, $FF
	db	$C3, $99, $F9, $F3, $CF, $9F, $81, $FF
	db	$C3, $99, $F9, $E3, $F9, $99, $C3, $FF
	db	$F9, $F1, $E1, $99, $80, $F9, $F9, $FF
	db	$81, $9F, $83, $F9, $F9, $99, $C3, $FF
	db	$C3, $99, $9F, $83, $99, $99, $C3, $FF
	db	$81, $99, $F3, $E7, $E7, $E7, $E7, $FF
	db	$C3, $99, $99, $C3, $99, $99, $C3, $FF
	db	$C3, $99, $99, $C1, $F9, $99, $C3, $FF
	db	$04, $04, $FC, $04, $04, $04, $FC, $04
	db	$FF, $FF, $E7, $FF, $FF, $E7, $E7, $CF
	db	$F1, $E7, $CF, $9F, $CF, $E7, $F1, $FF
	db	$20, $20, $3F, $20, $20, $20, $3F, $20
	db	$8F, $E7, $F3, $F9, $F3, $E7, $8F, $FF
	db	$C3, $99, $F9, $F3, $E7, $FF, $E7, $FF
	db	$00, $00, $FF, $FF, $18, $24, $42, $81
	db	$F7, $E3, $C1, $80, $80, $E3, $C1, $FF
	db	$FF, $18, $24, $42, $81, $FF, $FF, $00
	db	$00, $00, $00, $00, $FF, $FF, $18, $24
	db	$00, $00, $00, $00, $00, $FF, $FF, $18
	db	$00, $00, $00, $00, $00, $00, $FF, $FF
	db	$00, $FF, $FF, $18, $24, $42, $81, $FF
	db	$FF, $FF, $18, $24, $42, $81, $FF, $FF
	db	$24, $42, $81, $FF, $FF, $00, $00, $00
	db	$FF, $FF, $FF, $1F, $0F, $C7, $E7, $E7
	db	$E7, $E7, $E3, $F0, $F8, $FF, $FF, $FF
	db	$E7, $E7, $C7, $0F, $1F, $FF, $FF, $FF
	db	$3F, $3F, $3F, $3F, $3F, $3F, $00, $00
	db	$3F, $1F, $8F, $C7, $E3, $F1, $F8, $FC
	db	$FC, $F8, $F1, $E3, $C7, $8F, $1F, $3F
	db	$00, $00, $3F, $3F, $3F, $3F, $3F, $3F
	db	$00, $00, $FC, $FC, $FC, $FC, $FC, $FC
	db	$FF, $C3, $81, $81, $81, $81, $C3, $FF
	db	$FF, $FF, $18, $24, $42, $81, $FF, $FF
	db	$C9, $80, $80, $80, $C1, $E3, $F7, $FF
	db	$00, $00, $00, $00, $00, $00, $00, $FF
	db	$FF, $FF, $FF, $F8, $F0, $E3, $E7, $E7
	db	$FF, $FF, $00, $00, $00, $00, $00, $00
	db	$FF, $C3, $81, $99, $99, $81, $C3, $FF
	db	$E7, $E7, $99, $99, $E7, $E7, $C3, $FF
	db	$42, $81, $FF, $FF, $00, $00, $00, $00
	db	$F7, $E3, $C1, $80, $C1, $E3, $F7, $FF
	db	$E7, $E7, $E7, $00, $00, $E7, $E7, $E7
	db	$3F, $3F, $CF, $CF, $3F, $3F, $CF, $CF
	db	$18, $24, $42, $81, $FF, $FF, $00, $00
	db	$FF, $FF, $FC, $C1, $89, $C9, $C9, $FF
	db	$00, $80, $C0, $E0, $F0, $F8, $FC, $FE
	db	$3C, $7E, $7F, $7C, $3E, $7F, $3F, $66
	db	$0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
	db	$FF, $FF, $FF, $FF, $00, $00, $00, $00
	db	$00, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
	db	$3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F
	db	$33, $33, $CC, $CC, $33, $33, $CC, $CC
	db	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	db	$FF, $FF, $FF, $FF, $33, $33, $CC, $CC
	db	$00, $01, $03, $07, $0F, $1F, $3F, $7F
	db	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	db	$E7, $E7, $E7, $E0, $E0, $E7, $E7, $E7
	db	$FF, $FF, $FF, $FF, $F0, $F0, $F0, $F0
	db	$E7, $E7, $E7, $E0, $E0, $FF, $FF, $FF
	db	$A2, $01, $22, $14, $A0, $05, $A8, $45
	db	$AA, $55, $AA, $55, $AA, $55, $AA, $55
	db	$FF, $FF, $FF, $E0, $E0, $E7, $E7, $E7
	db	$E7, $E7, $E7, $00, $00, $FF, $FF, $FF
	db	$FF, $FF, $FF, $00, $00, $E7, $E7, $E7
	db	$E7, $E7, $E7, $07, $07, $E7, $E7, $E7
	db	$3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F
	db	$1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F
	db	$F8, $F8, $F8, $F8, $F8, $F8, $F8, $F8
	db	$00, $00, $FF, $FF, $FF, $FF, $FF, $FF
	db	$00, $00, $00, $FF, $FF, $FF, $FF, $FF
	db	$FF, $FF, $FF, $FF, $FF, $00, $00, $00
	db	$FC, $FC, $FC, $FC, $FC, $FC, $00, $00
	db	$FF, $FF, $FF, $FF, $0F, $0F, $0F, $0F
	db	$F0, $F0, $F0, $F0, $FF, $FF, $FF, $FF
	db	$E7, $E7, $E7, $07, $07, $FF, $FF, $FF
	db	$AA, $55, $AA, $55, $AA, $55, $AA, $55
	db	$AA, $55, $AA, $55, $AA, $55, $AA, $55

Screen1Char:
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE
	db	$C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE
	db	$C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE
	db	$C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE
	db	$C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $BD, $BA, $EE, $EE, $EE
	db	$C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE, $EE


Screen1Color:
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db	$04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09
	db	$01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db	$0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db	$0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $03, $03, $09, $09, $09
	db	$0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db	$09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09