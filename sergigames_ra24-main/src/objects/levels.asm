include "hardware.inc"
include "objects/constants.asm"

DEF MAX_LEVEL EQU 6         ; Total de niveles

SECTION "Level Variables", WRAM0
wCurrentLevel:    DS 1      ; Nivell actual
wLevelComplete:   DS 1      ; 1 = completado, 0 = no completado

SECTION "Win Screen Tiles", ROM0
win_screen_tiles:
    ; Tile 0: Vacío
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    
    ; Tile 1: Y
    db $C6,$C6,$C6,$C6,$6C,$6C,$38,$38
    db $18,$18,$18,$18,$18,$18,$00,$00
    
    ; Tile 2: O
    db $7C,$7C,$C6,$C6,$C6,$C6,$C6,$C6
    db $C6,$C6,$C6,$C6,$7C,$7C,$00,$00
    
    ; Tile 3: U
    db $C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6
    db $C6,$C6,$C6,$C6,$7C,$7C,$00,$00
    
    ; Tile 4: W
    db $C6,$C6,$C6,$C6,$C6,$C6,$D6,$D6
    db $FE,$FE,$EE,$EE,$C6,$C6,$00,$00
    
    ; Tile 5: I
    db $7E,$7E,$18,$18,$18,$18,$18,$18
    db $18,$18,$18,$18,$7E,$7E,$00,$00
    
    ; Tile 6: N
    db $C6,$C6,$E6,$E6,$F6,$F6,$DE,$DE
    db $CE,$CE,$C6,$C6,$C6,$C6,$00,$00
    
    ; Tile 7: ! 
    db $18,$18,$18,$18,$18,$18,$18,$18
    db $18,$18,$00,$00,$18,$18,$00,$00
    
    ; Tile 8: P
    db $FC,$FC,$C6,$C6,$C6,$C6,$FC,$FC
    db $C0,$C0,$C0,$C0,$C0,$C0,$00,$00
    
    ; Tile 9: R
    db $FC,$FC,$C6,$C6,$C6,$C6,$FC,$FC
    db $CC,$CC,$C6,$C6,$C6,$C6,$00,$00
    
    ; Tile 10: E
    db $FE,$FE,$C0,$C0,$C0,$C0,$FC,$FC
    db $C0,$C0,$C0,$C0,$FE,$FE,$00,$00
    
    ; Tile 11: S
    db $7C,$7C,$C6,$C6,$C0,$C0,$7C,$7C
    db $06,$06,$C6,$C6,$7C,$7C,$00,$00
    
    ; Tile 12: B
    db $FC,$FC,$C6,$C6,$C6,$C6,$FC,$FC
    db $C6,$C6,$C6,$C6,$FC,$FC,$00,$00
    
    ; Tile 13: T
    db $FE,$FE,$18,$18,$18,$18,$18,$18
    db $18,$18,$18,$18,$18,$18,$00,$00
    
    ; Tile 14: C
    db $7C,$7C,$C6,$C6,$C0,$C0,$C0,$C0
    db $C0,$C0,$C6,$C6,$7C,$7C,$00,$00

    ; Tile 15: :
    db $00,$00,$18,$18,$18,$18,$00,$00
    db $18,$18,$18,$18,$00,$00,$00,$00
win_screen_tiles_end:

SECTION "Level Code", ROM0

initialize_level_system::
    ld a, 1                     ; Nivel 1
    ld [wCurrentLevel], a
    xor a
    ld [wLevelComplete], a
    ret

check_level_complete::
    ld a, [wCurrentEnemies]
    and a                       ; Comprueba si enemigos == 0
    ret nz                      ; Vuelve si no lo está
    
    ; Nivel completado
    ld a, 1
    ld [wLevelComplete], a
    ret

advance_level::
    ld a, [wCurrentLevel]
    inc a
    cp MAX_LEVEL + 1
    jr z, .game_complete

    ; Empeiza el siguiente nivel
    ld [wCurrentLevel], a
    xor a
    ld [wLevelComplete], a
    call initialize_enemies
    ret
.game_complete:
    jp show_win_screen 

show_win_screen::
    call switch_screen_off
    
    ld de, win_screen_tiles
    ld hl, $9000
    ld bc, win_screen_tiles_end - win_screen_tiles
    call mem_copy

    ; Limpia el tilemap
    ld hl, $9800
    ld bc, 32*32
.clear_loop:
    ld a, 0            
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jr nz, .clear_loop

    ; Escirbe "YOU WIN!" 
    ld hl, $9800 + (32 * 8) + 6  
    
    ld [hl], 1        ; Y
    inc hl
    ld [hl], 2        ; O
    inc hl
    ld [hl], 3        ; U
    inc hl
    ld [hl], 0        ; Espacio
    inc hl
    ld [hl], 4        ; W
    inc hl
    ld [hl], 5        ; I
    inc hl
    ld [hl], 6        ; N
    inc hl
    ld [hl], 7        ; !

    ld hl, $9800 + (32 * 10) + 5  ; 2 líneas por debajo de "YOU WIN!"

    ; Escirbe "SCORE:wScore"
    ld [hl], 11     ; S (intro tile 4)
    inc hl
    ld [hl], 14     ; C (intro tile 9)
    inc hl
    ld [hl], 2      ; O (intro tile 7)
    inc hl
    ld [hl], 9      ; R (intro tile 2)
    inc hl
    ld [hl], 10     ; E (intro tile 3)
    inc hl
    ld [hl], 15     ; :

    ; Escirbe wScore
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

    ; Escirbe "PRESS B TO CONTINUE"
    ld hl, $9800 + (32 * 12) + 1
    
    ld [hl], 8       ; P
    inc hl
    ld [hl], 9       ; R
    inc hl
    ld [hl], 10      ; E
    inc hl
    ld [hl], 11      ; S
    inc hl
    ld [hl], 11      ; S
    inc hl
    
    ; Espacio
    ld [hl], 0        
    inc hl
    
    ; Escirbe "B"
    ld [hl], 12      ; B
    inc hl
    
    ld [hl], 0        
    inc hl
    
    ; Escirbe "TO"
    ld [hl], 13      ; T
    inc hl
    ld [hl], 2       ; O
    inc hl
    
    ld [hl], 0        
    inc hl
    
    ; Escirbe "CONTINUE"
    ld [hl], 14      ; C
    inc hl
    ld [hl], 2       ; O
    inc hl
    ld [hl], 6       ; N
    inc hl
    ld [hl], 13      ; T
    inc hl
    ld [hl], 5       ; I
    inc hl
    ld [hl], 6       ; N
    inc hl
    ld [hl], 3       ; U
    inc hl
    ld [hl], 10      ; E

    ; Enciende la pantalla
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a
    
.wait_for_continue:
    call wait_vblank_start
    call update_keys
    
    ld a, [wNewKeys]
    and PADF_B
    jr z, .wait_for_continue

    call switch_screen_off      ; Recarga si se presiona B
    
    ld de, intro_text_tiles
    ld hl, $9000          
    ld bc, intro_text_tiles_end - intro_text_tiles
    call mem_copy

    ; Limpia el tilemap
    ld hl, $9800
    ld bc, 32*32
.clear_before_main:
    xor a
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jr nz, .clear_before_main

    ; Escirbe "PRESS B TO START" 
    ld hl, $9800 + (32 * 8) + 2  

    ; Escirbe "PRESS"
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
    
    ; Escirbe "B"
    ld [hl], 5        ; B
    inc hl
    
    ld [hl], 0
    inc hl
    
    ; Escirbe "TO"
    ld [hl], 6        ; T
    inc hl
    ld [hl], 7        ; O
    inc hl
    
    
    ld [hl], 0
    inc hl
    
    ; Escirbe "START"
    ld [hl], 4        ; S
    inc hl
    ld [hl], 6        ; T
    inc hl
    ld [hl], 8        ; A
    inc hl
    ld [hl], 2        ; R
    inc hl
    ld [hl], 6        ; T

    ; Enciende la pantalla
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a

    jp main