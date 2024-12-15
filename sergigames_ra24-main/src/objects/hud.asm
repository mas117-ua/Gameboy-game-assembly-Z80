INCLUDE "hardware.inc"    

DEF HUD_TILE_START EQU $80  ; 0 (Comienzo)

SECTION "HUD Variables", WRAM0
DEF FIRST_FREE_OAM_SLOT EQU 12 * 4  ; 1 sprite -> 4 bytes

wScore: ds 1          ; 1 byte para score (255 puntos)
wLives: db            ; 1 byte para las vidas
wScoreChanged: db     ; 1 = necesita actualización, 0 = no la necesita
wLivesChanged: db     ; 1 = necesita actualización, 0 = no la necesita
wScoreBuffer: ds 3    ; Guarda los tiles del Score
wLivesBuffer: ds 3    ; Cuarda los tiles de las vidas

SECTION "HUD Tiles", ROM0

hud_tiles:
    ; Número 0
    db $7E,$7E,$C6,$C6,$C6,$C6,$C6,$C6
    db $C6,$C6,$C6,$C6,$7E,$7E,$00,$00

    ; Número 1
    db $18,$18,$38,$38,$18,$18,$18,$18
    db $18,$18,$18,$18,$3C,$3C,$00,$00

    ; Número 2
    db $7E,$7E,$C6,$C6,$06,$06,$1C,$1C
    db $70,$70,$C0,$C0,$FE,$FE,$00,$00

    ; Número 3
    db $7E,$7E,$C6,$C6,$06,$06,$1C,$1C
    db $06,$06,$C6,$C6,$7E,$7E,$00,$00

    ; Número 4
    db $C6,$C6,$C6,$C6,$C6,$C6,$FE,$FE
    db $06,$06,$06,$06,$06,$06,$00,$00

    ; Número 5
    db $FE,$FE,$C0,$C0,$C0,$C0,$FC,$FC
    db $06,$06,$C6,$C6,$7C,$7C,$00,$00

    ; Número 6
    db $7E,$7E,$C0,$C0,$C0,$C0,$FC,$FC
    db $C6,$C6,$C6,$C6,$7C,$7C,$00,$00

    ; Número 7
    db $FE,$FE,$C6,$C6,$06,$06,$0C,$0C
    db $18,$18,$18,$18,$18,$18,$00,$00

    ; Número 8
    db $7C,$7C,$C6,$C6,$C6,$C6,$7C,$7C
    db $C6,$C6,$C6,$C6,$7C,$7C,$00,$00

    ; Número 9
    db $7C,$7C,$C6,$C6,$C6,$C6,$7E,$7E
    db $06,$06,$C6,$C6,$7C,$7C,$00,$00

    ; Corazón
    db $66,$66,$FF,$FF,$FF,$7E,$7E,$3C
    db $3C,$18,$18,$00,$00,$00,$00,$00

    ; S 
    db $7E,$7C,$FF,$FE,$C0,$C0,$7E,$7C  
    db $03,$02,$FF,$FE,$7E,$7C,$00,$00 

    ; C
    db $7E,$7C,$FF,$FE,$C0,$C0,$C0,$C0  
    db $C0,$C0,$FF,$FE,$7E,$7C,$00,$00  

    ; O
    db $7E,$7C,$FF,$FE,$C3,$C2,$C3,$C2 
    db $C3,$C2,$FF,$FE,$7E,$7C,$00,$00

    db $FF,$FE,$C3,$C2,$C3,$C2,$FF,$FE 
    db $CC,$CC,$C6,$C6,$C3,$C2,$00,$00

    ; E
    db $FF,$FE,$C0,$C0,$C0,$C0,$FF,$FE  
    db $C0,$C0,$FF,$FE,$FF,$FE,$00,$00  

    ; : 
    db $00,$00,$38,$38,$38,$38,$00,$00  
    db $38,$38,$38,$38,$00,$00,$00,$00 

    ; Espacio
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
hud_tiles_end:

DEF EMPTY_TILE     EQU $00                  
DEF NUMBER_START   EQU HUD_TILE_START       ; Primer número (0)
DEF HEART_TILE    EQU HUD_TILE_START + 10   ; Después de los números 
DEF LETTER_S      EQU HUD_TILE_START + 11   ; Después del corazón
DEF LETTER_C      EQU HUD_TILE_START + 12
DEF LETTER_O      EQU HUD_TILE_START + 13
DEF LETTER_R      EQU HUD_TILE_START + 14
DEF LETTER_E      EQU HUD_TILE_START + 15
DEF LETTER_COLON  EQU HUD_TILE_START + 16
DEF LETTER_SPACE  EQU HUD_TILE_START + 17

SECTION "HUD Functions", ROM0

InitHUD::
    ld de, hud_tiles
    ld hl, _VRAM8000 + (HUD_TILE_START * 16)  
    ld bc, hud_tiles_end - hud_tiles
.copyTiles:
    ld a, [de]             
    ld [hl+], a            
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .copyTiles

    ; Escribe "SCORE:wScore" 
    ld hl, $9A0A
    ld a, LETTER_S          
    ld [hl+], a             ; 9A0A
    ld a, LETTER_C          
    ld [hl+], a             ; 9A0B
    ld a, LETTER_O          
    ld [hl+], a             ; 9A0C
    ld a, LETTER_R          
    ld [hl+], a             ; 9A0D
    ld a, LETTER_E          
    ld [hl+], a             ; 9A0E
    ld a, LETTER_COLON      
    ld [hl+], a             ; 9A0F
    ld a, NUMBER_START
    ld [hl+], a             ; 9A10
    ld [hl+], a             ; 9A11
    ld [hl], a              ; 9A12
    
    ; Dibuja los corazones
    ld hl, $9A01          
    ld a, HEART_TILE      
    ld [hl+], a           
    ld [hl+], a           
    ld [hl], a            
    
    ; Inicializa variables
    xor a
    ld [wScore], a
    ld a, 3
    ld [wLives], a
    ld a, 1
    ld [wScoreChanged], a
    xor a
    ld [wLivesChanged], a
    ret

UpdateHUDLogic::
    ld a, [wScoreChanged]
    and a
    jr z, .checkLives       ; Si el score no cambia, comprueba las vidas

    call convert_score      ; Convierte wScore en tiles en wScoreBuffer
    
.checkLives:
    ld a, [wLivesChanged]
    and a
    ret z
    
    ; Comvierte los corazones en tiles
    ld a, [wLives]
    ld b, a
    ld hl, wLivesBuffer
.livesLoop:
    ld a, b
    and a
    jr z, .emptyHearts
    ld a, HEART_TILE
    ld [hl+], a
    dec b
    jr .livesLoop
.emptyHearts:
    ld a, EMPTY_TILE
    ld [hl+], a
    ret

UpdateHUDGraphics::
    ld a, [wScoreChanged]
    and a
    jr z, .updateLives
    
    call print_score
    
    xor a
    ld hl, wScoreChanged
    ld [hl], a
    
.updateLives:
    ld a, [wLivesChanged]
    and a
    ret z
    
    ld hl, $9A01          
    ld de, wLivesBuffer
    ld b, 3             
.livesDisplayLoop:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, .livesDisplayLoop
    
    xor a
    ld [wLivesChanged], a
    ret


; Entrada: HL = Dirección de la variable de 1 byte que contiene el puntaje (255 puntos)
; Salida: scoreBuffer = 6 bytes (3 para dígitos, 3 para tiles)
convert_score:
    ld a, [wScore]

    ; Calcula las centenas
    ld b, 100                   ; Coloca 100 en B para dividir.
    call div_a_by_b                        
    add $80
    ld [wScoreBuffer], a        ; Almacena el dígito de las centenas en wScoreBuffer.
    ld a, b
    
    ; Calcula las decenas
    ld b, 10                    ; Coloca 10 en B para dividir.
    call div_a_by_b                    
    add $80
    ld [wScoreBuffer + 1], a    ; Almacena el dígito de las decenas en wScoreBuffer + 1.
    ld a, b
    
    ; Calcula las unidades
    ld b, 1
    call div_a_by_b
    ; xor a
    add $80
    ld [wScoreBuffer + 2], a    ; Almacena el dígito de las unidades en wScoreBuffer + 2.
    
    ret                         ; Regresa de la función.


; A -> Dividendo (Low wScore)
; D -> Dividendo (High wScore)
; B -> Divisor (1, 10 ,100)
; C -> Resultado
div_a_by_b:
    ld c, 0                     ; C = Resultado

    .div_loop
        cp b                    ; A - B            
        jr c, .div_end          ; Si A > B está acabada
        inc c                   ; Sino C++
        sub b                   ; A -= B
        jr .div_loop

    .div_end
        ld b, a                 ; B = A
        ld a, c                 ; A = C = Resultado
    
    ret


; Entrada: wScoreBuffer = Variable de 6 bytes (3 dígitos, 3 tiles)
; Salida: El puntaje se imprime en la pantalla
print_score:
    ld hl, wScoreBuffer ; Cargar la dirección de wScoreBuffer
    
    ; Imprimir el dígito y tile de las centenas
    ld a, [hl+]     ; Cargar el dígito de las centenas
    ld de, $9A10    ; Establecer la posición de impresión para las centenas
    ld [de], a      ; Escribir el tile en la VRAM
    
    ; Imprimir el dígito y tile de las decenas    
    ld a, [hl+]     ; Cargar el dígito de las decenas
    inc de          ; DE = $9A11
    ld [de], a      ; Escribir el tile en la VRAM

    ; Imprimir el dígito y tile de las unidades
    ld a, [hl]      ; Cargar el dígito de las unidades
    inc de          ; DE = $9A12
    ld [de], a      ; Escribir el tile en la VRAM
    
    ret         


lose_a_life:
    ; Vidas -1
    ld a, [wLives]
    dec a
    ld [wLives], a    
    
    and a
    jp z, show_game_over_screen    ; Si las vidas son 0, game over
    
    ld b, a           
    ld hl, $9A01      
    ld a, b           
    add l             
    ld l, a           
    
    ld a, EMPTY_TILE
    ld [hl], a
    
    ld a, 1
    ld [wLivesChanged], a
    ret