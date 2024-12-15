include "src/hardware.inc"

SECTION "VariablesNave", WRAM0
posicionNaveX:  DS 1 ; Variable de 1 byte para la posición X
posicionNaveY:  DS 1 ; Variable de 1 byte para la posición Y
naveStatus:     DS 1 ; 0 = muerto, 1 = vivo

SECTION "Player", ROM0

inicializarNave::
    xor a
    ; Inicializar la posición de la nave en coordenadas específicas
    ld a, 80
    ld [posicionNaveX], a
    ld a, 115
    ld [posicionNaveY], a
    ld a, 1
    ld [naveStatus], a

    ; Copiar tiles a VRAM (esto debe hacerse durante VBLANK o con la pantalla apagada)
    ld de, nave6
    ld hl, $8000
    ld bc, nave6end - nave6
    call mem_copy
    ret

; Actualiza la lógica de la nave (posiciones, disparos, etc.)
; Esta función puede llamarse en cualquier momento
updateNave::
    call updateNave_HandleInput
    ret

; Maneja la entrada del jugador y actualiza las posiciones
updateNave_HandleInput:
    ld a, [wCurKeys]
    and PADF_LEFT
    call nz, MoveLeft
    
    ld a, [wCurKeys]
    and PADF_RIGHT
    call nz, MoveRight
    
    ld a, [wCurKeys]
    and PADF_A
    call nz, TryShoot
    ret

; Actualiza el sprite en OAM (DEBE llamarse durante VBLANK)
UpdatePlayer_UpdateSprite::
    ld a, [posicionNaveX]
    add 8                   ;  +8 de offset por el hardware
    ld b, a

    ld a, [posicionNaveY]
    add 16                  ; +16 de offset por el hardware
    ld c, a

    ; Actualiza OAM
    ld hl, _OAMRAM

    ; Y 
    ld a, c
    ld [hl+], a

    ; X 
    ld a, b
    ld [hl+], a

    ; Tile
    xor a
    ld [hl+], a

    ; Atributos
    ld [hl], a
    ret

TryShoot:
    ld a, [wCurKeys]
    and PADF_A
    ret z
    jp FireBullet

MoveLeft:
    ld a, [posicionNaveX]
    cp 0                    ; Límite izquierda
    ret z
    sub 1
    ld [posicionNaveX], a
    ret

MoveRight:
    ld a, [posicionNaveX]
    cp 152                  ; Límite derecha
    ret z
    add 1
    ld [posicionNaveX], a
    ret