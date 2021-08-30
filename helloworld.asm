    org $0801
    dw $080b
    dw $000a
    db $9e," 2064"
    db $00,$00,$00,$00

    org $0810
Start:
    jsr $e544

    lda #$00
    sta $d020
    sta $d021

    lda #65
    ldy #255
StartLoop:
    sta $0400,y
    dey
    bne StartLoop

    rts
