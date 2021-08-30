    org $0801
    dw $080b
    dw $000a
    db $9e," 2064"
    db $00,$00,$00,$00

    org $0810
Start:
    jsr $e544

StartLoop:
    lda #$00
    sta $d020
    sta $d021

    lda #65
    sta $0400
    sta $0401
    sta $0402

    rts
