INCLUDE "objects/constants.asm"

SECTION "Collision Player Code", ROM0

check_bullet_player_collisions::
    ld hl, posicionNaveX
    ld d, [hl]              ; D = naveX
    ld hl, posicionNaveY
    ld e, [hl]              ; E = naveY
    ld bc, 0                ; Contaodr de balas

    .bullet_loop:       
        ; Comprueba si la bala está activa
        ld hl, wBulletActive
        add hl, bc
        ld a, [hl]
        and a
        jr z, .next_bullet

        ; Comprueba si la bala la dispara el jugador o el enemigo
        ld hl, wBulletDirection
        add hl, bc
        ld a, [hl]
        and a
        jr z, .next_bullet      ; Si es 0 = down_to_up, la dispara el jugador y pasamos a la siguiente
        
        ld hl, wBulletPosX
        add hl, bc
        ld a, [hl]          ; A = Bala X
        
        sub d               ; Bala X - Enemigo X
        cp 16             
        jr nc, .next_bullet
        
        ld hl, wBulletPosY
        add hl, bc
        ld a, [hl]          ; A = Bala Y
        
        sub e               ; Bala Y - Enemigo Y
        sub 12              ; Ajustar
        cp 16              
        jr nc, .next_bullet
        
        ; Desactiva la bala
        ld hl, wBulletActive
        ld b, 0
        add hl, bc
        xor a
        ld [hl], a

        call lose_a_life

    .next_bullet:
        inc c
        ld a, c
        cp 10               ; Máximo de balas
        jr nz, .bullet_loop

    ret
    