INCLUDE "hardware.inc"

SECTION "Intro Screen Tiles", ROM0
intro_text_tiles:
    ; Tile 0: Empty/background tile (16 bytes)
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00

    ; Tile 1: P (16 bytes)
    db $FC,$FC,$C6,$C6,$C6,$C6,$FC,$FC
    db $C0,$C0,$C0,$C0,$C0,$C0,$00,$00

    ; Tile 2: R (16 bytes)
    db $FC,$FC,$C6,$C6,$C6,$C6,$FC,$FC
    db $CC,$CC,$C6,$C6,$C6,$C6,$00,$00

    ; Tile 3: E (16 bytes)
    db $FE,$FE,$C0,$C0,$C0,$C0,$FC,$FC
    db $C0,$C0,$C0,$C0,$FE,$FE,$00,$00

    ; Tile 4: S (16 bytes)
    db $FE,$FE,$C0,$C0,$C0,$C0,$FE,$FE
    db $06,$06,$06,$06,$FC,$FC,$00,$00

    ; Tile 5: B (16 bytes)
    db $FC,$FC,$C6,$C6,$C6,$C6,$FC,$FC
    db $C6,$C6,$C6,$C6,$FC,$FC,$00,$00

    ; Tile 6: T (16 bytes)
    db $FE,$FE,$18,$18,$18,$18,$18,$18
    db $18,$18,$18,$18,$18,$18,$00,$00

    ; Tile 7: O (16 bytes)
    db $7C,$7C,$C6,$C6,$C6,$C6,$C6,$C6
    db $C6,$C6,$C6,$C6,$7C,$7C,$00,$00

    ; Tile 8: A (16 bytes)
    db $7C,$7C,$C6,$C6,$C6,$C6,$FE,$FE
    db $C6,$C6,$C6,$C6,$C6,$C6,$00,$00

    ; TIle 9: C (16 bytes)
    db $7E,$7E,$C0,$C0,$C0,$C0,$C0,$C0
    db $C0,$C0,$C0,$C0,$7E,$7E,$00,$00

    ; Tile 10: :
    db $00,$00,$18,$18,$18,$18,$00,$00
    db $18,$18,$18,$18,$00,$00,$00,$00
intro_text_tiles_end:

SECTION "Game Over Screen Tiles", ROM0
game_over_tiles:
    ; Tile 0: Empty (blank) tile
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00

    ; Tile 1: G
    db $7E,$7E,$C0,$C0,$C0,$C0,$CE,$CE
    db $C6,$C6,$C6,$C6,$7E,$7E,$00,$00

    ; Tile 2: A
    db $7E,$7E,$C6,$C6,$C6,$C6,$FE,$FE
    db $C6,$C6,$C6,$C6,$C6,$C6,$00,$00

    ; Tile 3: M
    db $C6,$C6,$EE,$EE,$FE,$FE,$D6,$D6
    db $C6,$C6,$C6,$C6,$C6,$C6,$00,$00

    ; Tile 4: E
    db $FE,$FE,$C0,$C0,$C0,$C0,$FC,$FC
    db $C0,$C0,$C0,$C0,$FE,$FE,$00,$00

    ; Tile 5: O
    db $7C,$7C,$C6,$C6,$C6,$C6,$C6,$C6
    db $C6,$C6,$C6,$C6,$7C,$7C,$00,$00

    ; Tile 6: V
    db $C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6
    db $6C,$6C,$38,$38,$10,$10,$00,$00

    ; Tile 7: R
    db $FC,$FC,$C6,$C6,$C6,$C6,$FC,$FC
    db $DC,$DC,$CE,$CE,$C6,$C6,$00,$00
game_over_tiles_end:

SECTION "Counter", WRAM0
wFrameCounter: db

SECTION "Input Variables", WRAM0
wCurKeys: db
wNewKeys: db

SECTION "Game State", WRAM0
wGameState: db        ; 0 = Title, 1 = Playing, 2 = Game Over

SECTION "Ball Data", WRAM0
wBallMomentumX: db
wBallMomentumY: db

SECTION "Main", ROM0[$0150]

main:
    call show_intro_screen
    
    call switch_screen_off
    
    ld hl, $9800 + (32 * 8) + 2
    ld b, 16

.clear_text
    ld [hl], 0
    inc hl
    dec b
    jr nz, .clear_text

    ld a, 1            
    ld [wGameState], a  ; 1 = jugando

    ; Copia los tiles para el fondo
    ld de, tilesfondo
    ld hl, $9000
    ld bc, tilesfondoend - tilesfondo
    call mem_copy

    ; Copia el tilemap
    ld de, mapafondo
    ld hl, $9800
    ld bc, mapafondoend - mapafondo
    call mem_copy

    call inicializarNave
    call initializeBullet
    call initialize_level_system
    call initialize_enemies
    
    call InitHUD
    call clear_oam
    call setup_screen

    ; Inicializar las paletas
    ld a, %11100100
    ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a

    xor a
    ld [wFrameCounter], a
    ld [wCurKeys], a
    ld [wNewKeys], a

game_loop:
    ; Comprueba el estado
    ld a, [wGameState]
    cp 2                            
    jp z, show_game_over_screen     ; Si es 2, es game over

    call update_keys
    call updateNave
    call UpdateBulletLogic
    call move_enemies
    call enemies_shoots
    call check_bullet_enemy_collisions
    call check_bullet_player_collisions
    call check_level_complete

    ; Comprueba si el nivel se ha completado
    call check_level_complete
    ld a, [wLevelComplete]
    and a
    call nz, advance_level

    call UpdateHUDLogic
    call wait_vblank_start
    call UpdatePlayer_UpdateSprite     ; Si no se pone primero, el jugador se congela
    call copy_enemies_to_oam            
    call UpdateBulletSprites           
    call UpdateHUDGraphics
    
    jp game_loop

show_intro_screen:
    call switch_screen_off

    ld de, intro_text_tiles
    ld hl, $9000          
    ld bc, intro_text_tiles_end - intro_text_tiles
    call mem_copy

    ; Escribe "PRESS B TO START" 
    ld hl, $9800 + (32 * 8) + 2  

    ld [hl], 1        ; P
    inc hl
    ld [hl], 2        ; R
    inc hl
    ld [hl], 3        ; E
    inc hl
    ld [hl], 4        ; S
    inc hl
    ld [hl], 4        ; S
    inc hl
    
    ld [hl], 0
    inc hl
    
    ld [hl], 5        ; B
    inc hl
    
    ld [hl], 0
    inc hl
    
    ld [hl], 6        ; T
    inc hl
    ld [hl], 7        ; O
    inc hl
    
    ld [hl], 0
    inc hl
    
    ld [hl], 4        ; S
    inc hl
    ld [hl], 6        ; T
    inc hl
    ld [hl], 8        ; A
    inc hl
    ld [hl], 2        ; R
    inc hl
    ld [hl], 6        ; T

    ; Paleta
    ld a, %11100100
    ld [rBGP], a

    ; Enciende la pantalla sólo con el fondo activado
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a

.wait_for_start:
    call wait_vblank_start
    call update_keys
    
    ld a, [wNewKeys]
    and PADF_B
    jr z, .wait_for_start
    
    ret

show_game_over_screen::
    call switch_screen_off
    
    ld de, game_over_tiles
    ld hl, $9000
    ld bc, game_over_tiles_end - game_over_tiles
    call mem_copy

    ld de, intro_text_tiles
    ld hl, $9080                                        ; $9000 + (8 tiles * 16 bytes por tile)
    ld bc, intro_text_tiles_end - intro_text_tiles
    call mem_copy

    ; Limpia el tilemap
    ld hl, $9800
    ld bc, 32*32        ; Tamaño del fondo
.clear_loop:
    xor a               
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jr nz, .clear_loop

    ; Escribe "GAME OVER"
    ld hl, $9800 + (32 * 8) + 5 
    
    ; Escribe "GAME"
    ld [hl], 1        ; G
    inc hl
    ld [hl], 2        ; A
    inc hl
    ld [hl], 3        ; M
    inc hl
    ld [hl], 4        ; E
    inc hl
    
    ; Espacio
    inc hl
    
    ; Escribe "OVER"
    ld [hl], 5        ; O
    inc hl
    ld [hl], 6        ; V
    inc hl
    ld [hl], 4        ; E
    inc hl
    ld [hl], 7        ; R

    ; Escribe "PRESS B TO START"
    ld hl, $9800 + (32 * 10) + 2  ; 2 líneas por debajo de "GAME OVER"
    
    ; Escribe "PRESS" 
    ld [hl], 8+1      ; P (intro tile 1)
    inc hl
    ld [hl], 8+2      ; R (intro tile 2)
    inc hl
    ld [hl], 8+3      ; E (intro tile 3)
    inc hl
    ld [hl], 8+4      ; S (intro tile 4)
    inc hl
    ld [hl], 8+4      ; S (intro tile 4)
    inc hl
    
    ; Espacio
    ld [hl], 8+0      ; Tile vacío
    inc hl
    
    ; Escribe "B"
    ld [hl], 8+5      ; B (intro tile 5)
    inc hl
    
    ld [hl], 8+0     
    inc hl
    
    ; Escribe "TO"
    ld [hl], 8+6      ; T (intro tile 6)
    inc hl
    ld [hl], 8+7      ; O (intro tile 7)
    inc hl
    
    ld [hl], 8+0     
    inc hl
    
    ; Escribe "START"
    ld [hl], 8+4      ; S (intro tile 4)
    inc hl
    ld [hl], 8+6      ; T (intro tile 6)
    inc hl
    ld [hl], 8+8      ; A (intro tile 8)
    inc hl
    ld [hl], 8+2      ; R (intro tile 2)
    inc hl
    ld [hl], 8+6      ; T (intro tile 6)

    ; Escribe "SCORE:wScore"
    ld hl, $9800 + (32 * 12) + 5  ; 2 líneas por debajo de "PRESS B TO START"

    ; Escribe "SCORE"
    ld [hl], 8+4        ; S (intro tile 4)
    inc hl
    ld [hl], 8+9        ; C (intro tile 9)
    inc hl
    ld [hl], 8+7        ; O (intro tile 7)
    inc hl
    ld [hl], 8+2        ; R (intro tile 2)
    inc hl
    ld [hl], 8+3        ; E (intro tile 3)
    inc hl
    ld [hl], 8+10       ; :

    ; Escribe wScore
    ld d, h
    ld e, l
    ld hl, wScoreBuffer
    inc de
    ld a, [hl+]
    ld [de], a

    inc de
    ld a, [hl+]
    ld [de], a

    inc de
    ld a, [hl]
    ld [de], a
    
    ; Enciende la pantalla
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a
    
    ld a, 2
    ld [wGameState], a      ; Estado = Game Over
    
.wait_for_restart:
    call wait_vblank_start
    call update_keys
    
    ; Comprueba si el botón B se está presionando
    ld a, [wNewKeys]
    and PADF_B
    jr z, .wait_for_restart     ; Si no, vuelve a comprobar

    call switch_screen_off    
    
    ; Limpia la pantalla
    ld hl, $9800 + (32 * 8) + 5  ; Posición de "GAME OVER"
    ld b, 9                      ; Tamaño
.clear_game_over
    xor a                       
    ld [hl+], a
    dec b
    jr nz, .clear_game_over
    
    ld hl, $9800 + (32 * 10) + 2  ; Posición de "PRESS B TO START"
    ld b, 16                      
.clear_press_b
    xor a                         
    ld [hl+], a
    dec b
    jr nz, .clear_press_b

    ld hl, $9800 + (32 * 12) + 5  ; Posición de "Score:wScore"
    ld b, 9                      
.clear_score_screen
    xor a 
    ld [hl+], a
    dec b
    jr nz, .clear_score_screen
    
    ; Resetea el estado
    xor a
    ld [wGameState], a
    
    ; Resetea el score
    xor a
    ld [wScore], a
    ld a, 1
    ld [wScoreChanged], a
    
    ; Reset las vidas
    ld a, 3
    ld [wLives], a
    ld a, 1
    ld [wLivesChanged], a
    
    call inicializarNave
    call initializeBullet
    call initialize_level_system
    call initialize_enemies
    call InitHUD
    call clear_oam

    ; 1 = jugando
    ld a, 1
    ld [wGameState], a

    ; Encender pantalla con objetos y fondo
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    ; Paletas
    ld a, %11100100
    ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a

    xor a
    ld [wFrameCounter], a
    ld [wCurKeys], a
    ld [wNewKeys], a

    jp game_loop        ; Jump directly to game loop

wait_vblank_start:
    .loop
        ld a, [rLY]
        cp 144
        jr nz, .loop
    ret

switch_screen_off:
    call wait_vblank_start
    ld hl, rLCDC
    res 7, [hl]
    ret

setup_screen:
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a
    ret

mem_copy:
    .loop
        ld a, [de]
        ld [hl+], a
        inc de
        dec bc
        ld a, b
        or a, c
        jr nz, .loop
    ret

clear_oam:
    xor a
    ld b, 160
    ld hl, _OAMRAM
    .loop
        ld [hl+], a
        dec b
        jr nz, .loop
    ret

update_keys:
	; Escribe la mitad del controllador (Botones A y B)
	ld a, P1F_GET_BTN	; P1F_GET_BTN = P1F_4 = %00010000 -> Carga los botones
	call one_nibble
	ld b, a 			; 11110000 -> 7-4 = 1, 3-0 = botones no presionados

	; Escribe la otra mitad (Direcciones)
	ld a, P1F_GET_DPAD	; P1F_GET_DPAD = P1F_5 = %00100000 -> Carga las direcciones
	call one_nibble
	swap a 				; A3-0 = direcciones no presionadas; A7-4 = 1
	xor b 				; A = botones presionados + direcciones
	ld b, a 			; B = botones presionados + direcciones

	; Carga los controladores
	ld a, P1F_GET_NONE	; P1F_GET_NONE = OR(P1F_4, P1F_5) = OR(%00010000, %00100000) -> No carga ninguno
	ldh [rP1], a

	; Combina con las wCurKeys previas para crear las wNewKeys
	ld a, [wCurKeys]	; wCurKeys -> Teclas que estaban presionadas anteriormente (Estado actual de los botones)
	xor b 				; A = teclas que han cambiado de estado
	and b 				; A = teclas que han cambiado a presionadas
	ld [wNewKeys], a	; wNewKeys -> Teclas recién presionadas (Estado nuevo de los botones)
	ld a, b
	ld [wCurKeys], a	; wCurKeys = estado actualizado de las teclas

	ret

; Lee el estado de los botones y los guarda en A
; 1 nibble = 4 bits = 1/2 byte
; rP1 (P1/JOYP) -> Guarda el estado de los botones de la consola
; 	-> Bits 0-3: indica el estado de los botones (A, B, Select, Start, Derecha, Izquierda, Arriba, Abajo)
; 	-> Bits 4,5: indica en grupo de botones que se quiere leer, direcciones (Derecha, Izquierda, Arriba, Abajo) o botones (A, B, Select, Start)
one_nibble:
	ldh [rP1], a 	; rP1 = $FF00 -> Actualiza la matriz de teclas
	call my_ret 	; Quema 10 ciclos llamando a un ret (Pausa)
	ldh a, [rP1] 	; Ignorar para que la matriz de teclas se estabilice
	ldh a, [rP1]
	ldh a, [rP1] 	; Lee
	or a, $F0 		; 11110000 -> 7-4 = 1, 3-0 = teclas no presionadas
	ret

my_ret:
    ret