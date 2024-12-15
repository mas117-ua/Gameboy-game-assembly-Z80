INCLUDE "objects/constants.asm"

SECTION "Collision Enemies Code", ROM0

check_bullet_enemy_collisions::
    ; Para cada enemigo
    ld hl, wEnemyArray
    ld b, MAX_ENEMIES
.enemy_loop:
    push bc
    push hl
    ; Comprueba si el enemigo está activo
    ld bc, ENEMY_ACTIVE_OFFSET
    add hl, bc         
    ld a, [hl]
    and a
    jr z, .next_enemy  ; Skip si inactivo

    ; Posición del enemigo
    pop hl
    push hl
    ld a, [hl+]       ; X
    ld d, a           ; X en D
    ld a, [hl]        ; Y
    ld e, a           ; Y en E

    ld c, 0           ; Contador de balas
.bullet_loop:
    push bc
    push de

    ; Comprueba si está activa
    ld hl, wBulletActive
    ld b, 0
    add hl, bc
    ld a, [hl]
    and a
    jr z, .next_bullet

    ; Comprueba si la bala la dispara el jugador o el enemigo
    ld hl, wBulletDirection
    ld b, 0
    add hl, bc
    ld a, [hl]
    and a
    jr nz, .next_bullet ; Si es 1 = up_to_down, la dispara el enemigo y pasamos a la siguiente

    ld hl, wBulletPosX
    ld b, 0
    add hl, bc
    ld a, [hl]        ; A = Bala X

    ; Compara
    sub d             ; Bala X - Enemigo X
    add 5
    cp 16            
    jr nc, .next_bullet

    ld hl, wBulletPosY
    ld b, 0
    add hl, bc
    ld a, [hl]        ; A = Bala Y

    ; Compara
    sub e             ; Bala Y - Enemigo Y
    add 10
    cp 16             
    jr nc, .next_bullet

    ; Se detecta colisión
    pop de
    pop bc

    ; Desactiva la bala
    ld hl, wBulletActive
    ld b, 0
    add hl, bc
    xor a
    ld [hl], a

    ; Desactiva el enemigo
    pop hl
    push hl
    ld bc, ENEMY_ACTIVE_OFFSET
    add hl, bc
    xor a
    ld [hl], a

    ; wScore +5
    ld hl, wScore
    ld a, [hl]      
    add 5            
    ld [hl], a     
    ld a, 1
    ld [wScoreChanged], a  

    ; Enemigos -1
    ld a, [wCurrentEnemies]
    dec a
    ld [wCurrentEnemies], a

    ; Comprueba si no quedan más
    and a              
    jr nz, .next_enemy
    ld a, 1
    ld [wLevelComplete], a  

    jr .next_enemy

.next_bullet:
    pop de
    pop bc
    inc c
    ld a, c
    cp 10                       ; Máximo de balas
    jr nz, .bullet_loop

.next_enemy:
    pop hl                      ; Restaura el puntero de los enmigos
    ld bc, ENEMY_STRUCT_SIZE
    add hl, bc                  ; Apunta al siguiente enemigo
    pop bc                      ; Restaura el contador de enemigos
    dec b
    jp nz, .enemy_loop
    ret