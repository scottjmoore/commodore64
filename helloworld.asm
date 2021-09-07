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

    lda ScrollY
    bne NoRight
    lda ScrollX
    bne NoRight

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
    bne .NoScrollingIncX
    jsr FlipBuffers
    jsr ScrollColorBufferIncX

.NoScrollingIncX:

    jmp Loop

Exit:
    jmp ($fffc)             ; Jump to code stored in 6502 reset vector

ScrollX:
    db $00
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

    lda #0                  ; Load accumulator with zero
    ldy #0                  ; Set Y register to count 256 times
    ldx #3
InitScreenLoop1:
    sta CharBuffer1,y             ; Store the accumulator in screen memory + Y register
    eor #$00
    sta CharBuffer2,y             ; Store the accumulator in screen memory + Y register
    eor #$00
    sta ColorBuffer,y             ; Store the accumulator in colour memory + Y register
    clc
    adc #1
    iny                     ; increment the Y register
    bne InitScreenLoop1           ; If != 0 go back to StartLoop
    inc InitScreenLoop1 + 2
    inc InitScreenLoop1 + 7
    inc InitScreenLoop1 + 12
    dex
    bne InitScreenLoop1

InitScreenLoop2:
    sta $0700,y             ; Store the accumulator in screen memory + Y register
    eor #$00
    sta $0b00,y             ; Store the accumulator in screen memory + Y register
    eor #$00
    sta $db00,y             ; Store the accumulator in colour memory + Y register
    clc
    adc #1
    iny                     ; increment the Y register
    cpy #232
    bne InitScreenLoop2      ; If != 232 go back to StartLoop

    lda $d011
    and #%11110000
    sta $d011
    lda $d016
    and #%11110000
    sta $d016

    rts

FlipBuffers:
    lda $d018
    eor #%00110000
    sta $d018
.Exit:
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