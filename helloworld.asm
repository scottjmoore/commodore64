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
    lda #-1
    sta ScrollingDecY
NoUp:
    lda $dc00
    and #1<<1
    bne NoDown
    lda #-1
    sta ScrollingIncY
NoDown:
    lda $dc00
    and #1<<2
    bne NoLeft
    lda #-1
    sta ScrollingDecX
NoLeft:
    lda $dc00
    and #1<<3
    bne NoRight
    lda #-1
    sta ScrollingIncX
NoRight:
    lda $dc00
    and #1<<4
    bne NoFire
    jmp Exit
NoFire:
    lda #$0f
    sta $d020
    lda ScrollingIncX
    beq NoScrollingIncX
    jsr ScrollIncX
    cmp #$01
    bne NoScrollingIncX
    jsr ScrollBufferIncX
NoScrollingIncX:
    lda #$00
    sta $d020

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
    ora #32
    sta $d018
    
    lda #$00                ; Load accumulator with colour value for black
    sta $d020               ; Set border colour to black
    sta $d021               ; Set background colour 0 to black

    lda #7                  ; Load accumulator with zero
    ldy #0                  ; Set Y register to count 256 times
    ldx #3
InitScreenLoop1:
    sta $0400,y             ; Store the accumulator in screen memory + Y register
    eor #$00
    sta $0801,y             ; Store the accumulator in screen memory + Y register
    eor #$00
    ; sta $d800,y             ; Store the accumulator in colour memory + Y register
    clc 
    adc #1
    iny                     ; increment the Y register
    bne InitScreenLoop1           ; If != 0 go back to StartLoop
    inc InitScreenLoop1 + 2
    inc InitScreenLoop1 + 7
    ; inc InitScreenLoop1 + 12
    dex 
    bne InitScreenLoop1
    
InitScreenLoop2:
    sta $0700,y             ; Store the accumulator in screen memory + Y register
    eor #$00
    sta $0b01,y             ; Store the accumulator in screen memory + Y register
    eor #$00
    ; sta $db00,y             ; Store the accumulator in colour memory + Y register
    clc 
    adc #1
    iny                     ; increment the Y register
    cpy #232
    bne InitScreenLoop2      ; If != 232 go back to StartLoop

    lda $d011
    and #%11110111
    sta $d011
    lda $d016
    and #%11110111
    sta $d016

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
    sta ScrollingIncX
    rts 

ScrollBufferIncX:
    lda $0800+(0 * 40)+39
    pha 
    lda $0800+(1 * 40)+39
    pha 
    lda $0800+(2 * 40)+39
    pha 
    lda $0800+(3 * 40)+39
    pha 
    lda $0800+(4 * 40)+39
    pha 
    lda $0800+(5 * 40)+39
    pha 
    lda $0800+(6 * 40)+39
    pha 
    lda $0800+(7 * 40)+39
    pha 
    lda $0800+(8 * 40)+39
    pha 
    lda $0800+(9 * 40)+39
    pha 
    lda $0800+(10 * 40)+39
    pha 
    lda $0800+(11 * 40)+39
    pha 
    lda $0800+(12 * 40)+39
    pha 
    lda $0800+(13 * 40)+39
    pha 
    lda $0800+(14 * 40)+39
    pha 
    lda $0800+(15 * 40)+39
    pha 
    lda $0800+(16 * 40)+39
    pha 
    lda $0800+(17 * 40)+39
    pha 
    lda $0800+(18 * 40)+39
    pha 
    lda $0800+(19 * 40)+39
    pha 
    lda $0800+(20 * 40)+39
    pha 
    lda $0800+(21 * 40)+39
    pha 
    lda $0800+(22 * 40)+39
    pha 
    lda $0800+(23 * 40)+39
    pha 
    lda $0800+(24 * 40)+39
    pha 
    ldx #39
.CopyLines
    lda $0800+(0 * 40)-1,x
    sta $0800+(0 * 40),x
    lda $0800+(1 * 40)-1,x
    sta $0800+(1 * 40),x
    lda $0800+(2 * 40)-1,x
    sta $0800+(2 * 40),x
    lda $0800+(3 * 40)-1,x
    sta $0800+(3 * 40),x
    lda $0800+(4 * 40)-1,x
    sta $0800+(4 * 40),x
    lda $0800+(5 * 40)-1,x
    sta $0800+(5 * 40),x
    lda $0800+(6 * 40)-1,x
    sta $0800+(6 * 40),x
    lda $0800+(7 * 40)-1,x
    sta $0800+(7 * 40),x
    lda $0800+(8 * 40)-1,x
    sta $0800+(8 * 40),x
    lda $0800+(9 * 40)-1,x
    sta $0800+(9 * 40),x
    lda $0800+(10 * 40)-1,x
    sta $0800+(10 * 40),x
    lda $0800+(11 * 40)-1,x
    sta $0800+(11 * 40),x
    lda $0800+(12 * 40)-1,x
    sta $0800+(12 * 40),x
    lda $0800+(13 * 40)-1,x
    sta $0800+(13 * 40),x
    lda $0800+(14 * 40)-1,x
    sta $0800+(14 * 40),x
    lda $0800+(15 * 40)-1,x
    sta $0800+(15 * 40),x
    lda $0800+(16 * 40)-1,x
    sta $0800+(16 * 40),x
    lda $0800+(17 * 40)-1,x
    sta $0800+(17 * 40),x
    lda $0800+(18 * 40)-1,x
    sta $0800+(18 * 40),x
    lda $0800+(19 * 40)-1,x
    sta $0800+(19 * 40),x
    lda $0800+(20 * 40)-1,x
    sta $0800+(20 * 40),x
    lda $0800+(21 * 40)-1,x
    sta $0800+(21 * 40),x
    lda $0800+(22 * 40)-1,x
    sta $0800+(22 * 40),x
    lda $0800+(23 * 40)-1,x
    sta $0800+(23 * 40),x
    lda $0800+(24 * 40)-1,x
    sta $0800+(24 * 40),x
    dex 
    beq .StopCopyLines
    jmp .CopyLines
.StopCopyLines
    pla 
    sta $0800+(24*40)
    pla 
    sta $0800+(23*40)
    pla 
    sta $0800+(22*40)
    pla 
    sta $0800+(21*40)
    pla 
    sta $0800+(20*40)
    pla 
    sta $0800+(19*40)
    pla 
    sta $0800+(18*40)
    pla 
    sta $0800+(17*40)
    pla 
    sta $0800+(16*40)
    pla 
    sta $0800+(15*40)
    pla 
    sta $0800+(14*40)
    pla 
    sta $0800+(13*40)
    pla 
    sta $0800+(12*40)
    pla 
    sta $0800+(11*40)
    pla 
    sta $0800+(10*40)
    pla 
    sta $0800+(9*40)
    pla 
    sta $0800+(8*40)
    pla 
    sta $0800+(7*40)
    pla 
    sta $0800+(6*40)
    pla 
    sta $0800+(5*40)
    pla 
    sta $0800+(4*40)
    pla 
    sta $0800+(3*40)
    pla 
    sta $0800+(2*40)
    pla 
    sta $0800+(1*40)
    pla 
    sta $0800+(0*40)
    rts 

ScrollIncY:
    inc ScrollY
    lda #%00000111
    and ScrollY
    sta ScrollY
    sta ScrollingIncY
    lda $d011
    and #%11111000
    ora ScrollY
    sta $d011
    rts 

ScrollDecX:
    dec ScrollX
    lda #%00000111
    and ScrollX
    sta ScrollX
    sta ScrollingDecX
    lda $d016
    and #%11111000
    ora ScrollX
    sta $d016
    rts 

ScrollDecY:
    dec ScrollY
    lda #%00000111
    and ScrollY
    sta ScrollY
    sta ScrollingDecY
    lda $d011
    and #%11111000
    ora ScrollY
    sta $d011
    rts

; ScrollBufferIncX:
;     lda #$0f
;     sta $d020

;     lda ScrollX
;     beq .Exit
;     cmp #$04
;     bcc .Scroll
;     jmp .Exit
; .Scroll
;     adc #$03
;     sta .Screen2Hi + 1
;     adc #$04
;     sta .Screen1Hi + 1

;     lda $d018
;     and #%00010000
;     beq .ScrollScreen2
; .Screen1Hi
;     lda #$04
;     sta .ScrollLoad + 2
;     sta .ScrollStore + 2
;     jmp .ScrollScreen1
; .ScrollScreen2
; .Screen2Hi
;     lda #$08
;     sta .ScrollLoad + 2
;     sta .ScrollStore + 2
; .ScrollScreen1
;     ldy #254
; .ScrollLoop
; .ScrollLoad
;     lda $0800,y
; .ScrollStore
;     sta $0802,y
;     dey 
;     bne .ScrollLoop

; .Exit    
;     lda #$00
;     sta $d020
;     rts 