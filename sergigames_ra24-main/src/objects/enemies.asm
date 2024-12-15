include "objects/constants.asm"
include "hardware.inc"
SECTION "Enemy Variables", WRAM0
wEnemyArray:        DS MAX_ENEMIES * ENEMY_STRUCT_SIZE  ; Array de enemigos
wCurrentEnemies:    DS 1                                ; Total de enemigos activos
wEnemyTimer:        DS 1                                ; Contador del movimento
wEnemyDelayShoot:   DS MAX_ENEMIES                      ; Array del delay de disparos
wShootTimer:        DS 1                                ; Contador de disparos de enemigos
wLastShootingEnemy: DS 1                                ; Último enemigo en disparar
wFailedAttempts:    DS 1                                ; COntador de disparos fallidos


DEF ENEMY_DELAY_SHOOT   EQU 60      ; 60 = 1 disparo por segundo
DEF MAX_FAILED_ATTEMPTS EQU 5       ; Númeor máximo de disparos fallidos antes de forzar un disparo
DEF RANDOM_SEED_ADDR    EQU $FFE1   ; Dirección de memoria random sin usar


SECTION "Enemy Code", ROM0

initialize_enemies::
    ; Resetea el contador de enmigos depende del nivel
    ld a, [wCurrentLevel]    
    cp 1
    jr nz, .check_level2
    ld a, TOTAL_ENEMIES_LVL1
    jr .set_enemies
.check_level2:
    ld a, [wCurrentLevel]
    cp 2
    jr nz, .check_level3
    ld a, TOTAL_ENEMIES_LVL2
    jr .set_enemies
.check_level3:
    ld a, [wCurrentLevel]
    cp 3
    jr nz, .check_level4
    ld a, TOTAL_ENEMIES_LVL3
    jr .set_enemies
.check_level4:
    ld a, [wCurrentLevel]
    cp 4
    jr nz, .check_level5
    ld a, TOTAL_ENEMIES_LVL4
    jr .set_enemies
.check_level5:
    ld a, [wCurrentLevel]
    cp 5
    jr nz, .check_level6
    ld a, TOTAL_ENEMIES_LVL5
    jr .set_enemies
.check_level6:
    ld a, TOTAL_ENEMIES_LVL6

.set_enemies:
    ld [wCurrentEnemies], a
    
    ; Resetea el contador
    xor a
    ld [wEnemyTimer], a
    ld [wShootTimer], a
    ld [wLastShootingEnemy], a
    
    ; Incializa RANDOM_SEED_ADDR
    ld a, [rDIV]
    ld [RANDOM_SEED_ADDR], a

    ; Inicializa el delay del disparo
    ld hl, wEnemyDelayShoot
    ld a, ENEMY_DELAY_SHOOT
    ld c, MAX_ENEMIES

    .delay_shoot_loop
        ld [hl+], a
        dec c
        jr nz, .delay_shoot_loop

    call clear_enemies

    ; Inicializa la formación de los enemigos depende del nivel
    ld a, [wCurrentLevel]
    cp 1
    jp z, .setup_level1
    cp 2
    jp z, .setup_level2
    cp 3
    jp z, .setup_level3
    cp 4
    jp z, .setup_level4
    cp 5
    jp z, .setup_level5
    cp 6
    jp z, .setup_level6
    jp .setup_level1        ; Nivel 1 por defecto

; Los setups de los niveles originales (1-3)
.setup_level1:
    ; Formación en fila (3 enemigos)
    ld hl, wEnemyArray
    ld b, TOTAL_ENEMIES_LVL1
    ld c, 0          
.l1_loop:
    ; X 
    ld a, 40
    add a, c
    ld [hl+], a 

    ; Y 
    ld a, 40
    ld [hl+], a

    ; Dirección
    xor a
    ld [hl+], a

    ; Estado = activo
    ld a, 1
    ld [hl+], a

    ; Espaciado
    ld a, 30
    add a, c
    ld c, a
    dec b
    jp nz, .l1_loop

    jp .init_done

.setup_level2:
    ; Formación en V (5 enemigos)
    ld hl, wEnemyArray
    ; Primera fila (3 enemigos)
    ; Enemigo 1
    ld a, 40          ; X
    ld [hl+], a
    ld a, 30          ; Y
    ld [hl+], a
    xor a             ; Dirección
    ld [hl+], a
    ld a, 1           ; Activo
    ld [hl+], a

    ; Enemigo 2
    ld a, 70          ; X
    ld [hl+], a
    ld a, 30          ; Y
    ld [hl+], a
    xor a             
    ld [hl+], a
    ld a, 1           
    ld [hl+], a

    ; Enemigo 3
    ld a, 100         ; X
    ld [hl+], a
    ld a, 30          ; Y
    ld [hl+], a
    xor a             
    ld [hl+], a
    ld a, 1           
    ld [hl+], a

    ; Segunda fila (2 enemigos)
    ld a, 55          ; X
    ld [hl+], a
    ld a, 50          ; Y
    ld [hl+], a
    xor a             
    ld [hl+], a
    ld a, 1           
    ld [hl+], a

    ld a, 85          ; X
    ld [hl+], a
    ld a, 50          ; Y
    ld [hl+], a
    xor a             
    ld [hl+], a
    ld a, 1           
    ld [hl+], a

    jp .init_done

.setup_level3:
    ; Formación de diamante (7 enemigos)
    ld hl, wEnemyArray

    ; Enemigo de arriba
    ld a, 70          ; X
    ld [hl+], a
    ld a, 20          ; Y
    ld [hl+], a
    xor a             
    ld [hl+], a
    ld a, 1           
    ld [hl+], a

    ; Fila del medio (3 enemigos)
    ld a, 40          ; X
    ld [hl+], a
    ld a, 40          ; Y
    ld [hl+], a
    xor a             
    ld [hl+], a
    ld a, 1           
    ld [hl+], a

    ld a, 70          ; X
    ld [hl+], a
    ld a, 40          ; Y
    ld [hl+], a
    xor a             
    ld [hl+], a
    ld a, 1            
    ld [hl+], a

    ld a, 100         ; X
    ld [hl+], a
    ld a, 40          ; Y
    ld [hl+], a
    xor a             
    ld [hl+], a
    ld a, 1           
    ld [hl+], a

    ; Fila de abajo (3 enemigos)
    ld a, 40          ; X
    ld [hl+], a
    ld a, 60          ; Y
    ld [hl+], a
    xor a             
    ld [hl+], a
    ld a, 1           
    ld [hl+], a

    ld a, 70          ; X
    ld [hl+], a
    ld a, 60          ; Y
    ld [hl+], a
    xor a             
    ld [hl+], a
    ld a, 1           
    ld [hl+], a

    ld a, 100         ; X
    ld [hl+], a
    ld a, 60          ; Y
    ld [hl+], a
    xor a             
    ld [hl+], a
    ld a, 1           
    ld [hl+], a

    jp .init_done

.setup_level4:
    ; Formación diagonal (8 enemigos)
    ld hl, wEnemyArray
    ld b, TOTAL_ENEMIES_LVL4
    ld c, 0           
    
.l4_loop:
    ; X 
    ld a, 20
    add a, c
    ld [hl+], a   

    ; Y 
    ld a, 30
    add a, c
    ld [hl+], a

    ; Direciión (Alternando diagonal izquierda/derecha)
    ld a, c
    and %00000001               ; Comprueba par o impar
    add a, DIR_DIAGONAL_RIGHT   ; 4 or 5 para movimiento diagonal
    ld [hl+], a

    ; Estado
    ld a, 1
    ld [hl+], a

    ; Espaciado
    ld a, 16
    add a, c
    ld c, a
    dec b
    jp nz, .l4_loop
    jp .init_done

.setup_level5:
    ; Formación arriba/abajo (9 enemigos en filas)
    ld hl, wEnemyArray
    
    ; Primera fila (3 enemigos moviendose hacia abajo)
    ld b, 3
    ld c, 0
.l5_row1:
    ; X 
    ld a, 40
    add a, c
    ld [hl+], a

    ; Y 
    ld a, 20
    ld [hl+], a

    ; Dirección (abajo)
    ld a, DIR_DOWN
    ld [hl+], a

    ; Activo
    ld a, 1
    ld [hl+], a

    ; Espaciado
    ld a, 30
    add a, c
    ld c, a
    dec b
    jr nz, .l5_row1
    
    ; Segunda fila (3 enemigos moviéndose hacia arriba)
    ld b, 3
    ld c, 0
.l5_row2:
    ; X 
    ld a, 40
    add a, c
    ld [hl+], a

    ; Y 
    ld a, 60
    ld [hl+], a

    ; Dirección (arriba)
    ld a, DIR_UP
    ld [hl+], a

    ; Activo
    ld a, 1
    ld [hl+], a

    ; Espaciado
    ld a, 30
    add a, c
    ld c, a
    dec b
    jr nz, .l5_row2
    
    ; Fila del medio (3 enemigos moviéndose hacia la izquierda/derecha)
    ld b, 3
    ld c, 0
.l5_row3:
    ; X 
    ld a, 40
    add a, c
    ld [hl+], a

    ; Y 
    ld a, 40
    ld [hl+], a

    ; Dirección (arriba)
    xor a
    ld [hl+], a

    ; Activo
    ld a, 1
    ld [hl+], a

    ; Espaciado
    ld a, 30
    add a, c
    ld c, a
    dec b
    jr nz, .l5_row3
    jp .init_done

.setup_level6:
    ; Formación mixta (10 enemigos con todos los patrones)
    ld hl, wEnemyArray
    ld b, TOTAL_ENEMIES_LVL6
    ld c, 0                     ; Contador posición
    
.l6_loop:
    ; X en zigzag
    ld a, 30
    add a, c
    ld [hl+], a
    
    ; Y alternando
    ld a, c
    and %00000011    ; 0-3 patrón
    add a, 2         ; Evitar estar muy alto
    sla a            ; Multiplicar por 16
    sla a
    sla a
    sla a
    ld [hl+], a
    
    ; Dirección 
    ld a, c
    and %00000111    ; 0-7 rango para las diferentes direcciones
    ld [hl+], a
    
    ; Activo
    ld a, 1
    ld [hl+], a
    
    ; Espaciado
    ld a, 12
    add a, c
    ld c, a
    
    dec b
    jp nz, .l6_loop
    jp .init_done
.init_done:
    call copy_enemy_tiles_to_vram
    ret


copy_enemy_tiles_to_vram:
    ; Nivel actual
    ld a, [wCurrentLevel]
    
    cp 1
    jr z, .load_ship1
    cp 2
    jr z, .load_ship2
    cp 3
    jr z, .load_ship3
    cp 4
    jr z, .load_ship4
    cp 5
    jr z, .load_ship5
    cp 6
    jr z, .load_ship6
    jr .load_ship1

.load_ship1:
    ld de, nave1
    ld bc, nave1end - nave1
    jr .do_copy

.load_ship2:
    ld de, nave2
    ld bc, nave2end - nave2
    jr .do_copy

.load_ship3:
    ld de, nave3
    ld bc, nave3end - nave3
    jr .do_copy

.load_ship4:
    ld de, nave4
    ld bc, nave4end - nave4
    jr .do_copy

.load_ship5:
    ld de, nave5
    ld bc, nave5end - nave5
    jr .do_copy

.load_ship6:
    ld de, nave6
    ld bc, nave6end - nave6

.do_copy:
    ld hl, $8020     
    call mem_copy
    ret

copy_enemies_to_oam::
    ld hl, wEnemyArray
    ld de, _OAMRAM + 44    ; Comienzo de las dirección de la OAM para los enemigos
    ld b, MAX_ENEMIES      

.copy_loop:
    ; Comprueba si el enemigo está activo
    push bc
    ld a, [hl+]        ; X
    ld b, a
    ld a, [hl+]        ; Y
    ld c, a
    inc hl             ; Skip dirección
    ld a, [hl+]        ; Estado
    and a
    jr z, .skip_enemy  ; Skip si inactivo

     ;Copia en la OAM
    ld a, c
    ld [de], a         ; Y 
    inc de
    ld a, b
    ld [de], a         ; X 
    inc de
    ld a, 2            ; Tile
    ld [de], a
    inc de
    xor a              ; Atributos
    ld [de], a
    inc de
    
    jr .continue

.skip_enemy:
    ; Limpia la OAM
    xor a
    ld [de], a
    inc de
    ld [de], a
    inc de
    ld [de], a
    inc de
    ld [de], a
    inc de

.continue:
    pop bc
    dec b
    jr nz, .copy_loop
    ret


move_enemies::
    ; Actualiza el contador
    ld a, [wEnemyTimer]
    inc a
    ld [wEnemyTimer], a
    
    ; Delay basado en el nivel
    ld a, [wCurrentLevel]
    cp 4
    jr c, .check_normal_delay   ; Niveles 1-3 delay normal
    
    ld a, [wEnemyTimer]
    cp 4                        ; Más rápido el resto
    ret nz
    jr .continue_move

.check_normal_delay:
    ld a, [wEnemyTimer]
    cp MOVE_DELAY
    ret nz

.continue_move:
    ; Reinicia el contador
    xor a
    ld [wEnemyTimer], a

    ; Mueve los enemigos
    ld hl, wEnemyArray
    ld b, MAX_ENEMIES

.move_loop:
    push bc
    push hl

    ; Comprueba si está activo
    ld bc, ENEMY_ACTIVE_OFFSET
    add hl, bc
    ld a, [hl]
    and a
    jp z, .next_enemy

    pop hl
    push hl
    
    ; Velocidad por nivel
    push hl
    ld a, [wCurrentLevel]
    cp 4
    jr c, .normal_speed
    cp 5
    jr c, .speed_4
    cp 6
    jr c, .speed_5
    ld b, ENEMY_SPEED_LVL6
    jr .got_speed
.speed_4:
    ld b, ENEMY_SPEED_LVL4
    jr .got_speed
.speed_5:
    ld b, ENEMY_SPEED_LVL5
    jr .got_speed
.normal_speed:
    ld b, ENEMY_SPEED
.got_speed:
    pop hl

    ; Dirección y patrón
    inc hl
    inc hl
    ld a, [hl]          ; Dirección
    dec hl
    dec hl
    
    cp DIR_RIGHT
    jr z, .move_right
    cp DIR_LEFT
    jr z, .move_left
    cp DIR_UP
    jr z, .move_up
    cp DIR_DOWN
    jr z, .move_down
    cp DIR_DIAGONAL_RIGHT
    jr z, .move_diagonal_right
    cp DIR_DIAGONAL_LEFT
    jr z, .move_diagonal_left
    jr .next_enemy   

.move_right:
    ; Originalmente derecha
    ld a, [hl]
    cp ENEMY_MAX_X
    jr nc, .change_dir_left
    add b                       ; Añade la velocidad
    ld [hl], a
    jr .next_enemy

.move_left:
    ; Origialmente izquierda
    ld a, [hl]
    cp ENEMY_MIN_X
    jr c, .change_dir_right
    sub b                       ; Resta velocidad
    ld [hl], a
    jr .next_enemy

.move_up:
    inc hl            ; Y
    ld a, [hl]
    cp ENEMY_MIN_Y
    jr c, .change_dir_down
    sub b
    ld [hl], a
    jr .next_enemy

.move_down:
    inc hl            ; Y
    ld a, [hl]
    cp ENEMY_MAX_Y
    jr nc, .change_dir_up
    add b
    ld [hl], a
    jr .next_enemy

.move_diagonal_right:
    ld a, [hl]        ; X 
    cp ENEMY_MAX_X
    jr nc, .change_diagonal_left
    add b
    ld [hl+], a       ; Actualiza X
    ld a, [hl]        ; Y 
    add b
    cp ENEMY_MAX_Y
    jr nc, .change_diagonal_left
    ld [hl], a        ; Actualiza Y
    jr .next_enemy

.move_diagonal_left:
    ld a, [hl]        ; X 
    cp ENEMY_MIN_X
    jr c, .change_diagonal_right
    sub b
    ld [hl+], a       ; Actualiza X
    ld a, [hl]        ; Y 
    sub b
    cp ENEMY_MIN_Y
    jr c, .change_diagonal_right
    ld [hl], a        ; Actualiza Y
    jr .next_enemy

.change_dir_left:
    inc hl
    inc hl
    ld a, DIR_LEFT
    ld [hl], a
    jr .next_enemy

.change_dir_right:
    inc hl
    inc hl
    ld a, DIR_RIGHT
    ld [hl], a
    jr .next_enemy

.change_dir_up:
    inc hl
    inc hl
    ld a, DIR_UP
    ld [hl], a
    jr .next_enemy

.change_dir_down:
    inc hl
    inc hl
    ld a, DIR_DOWN
    ld [hl], a
    jr .next_enemy

.change_diagonal_left:
    inc hl
    inc hl
    ld a, DIR_DIAGONAL_LEFT
    ld [hl], a
    jr .next_enemy

.change_diagonal_right:
    inc hl
    inc hl
    ld a, DIR_DIAGONAL_RIGHT
    ld [hl], a

.next_enemy:
    pop hl
    ld de, ENEMY_STRUCT_SIZE
    add hl, de
    pop bc
    dec b
    jp nz, .move_loop
    ret

clear_enemies:
    ld hl, wEnemyArray
    ld b, MAX_ENEMIES
.clear_loop:
    xor a
    ld [hl+], a        ; X
    ld [hl+], a        ; Y
    ld [hl+], a        ; Dirección
    ld [hl+], a        ; Estado
    dec b
    jr nz, .clear_loop
    ret


enemies_shoots::
    ld a, [wCurrentEnemies]
    and a
    ret z               ; Si no hay enemigos, vuelve

    ; Comprueba el tiempo entre disparos
    ld a, [wShootTimer]
    and a
    jr z, .try_shoot
    dec a
    ld [wShootTimer], a
    ret

.try_shoot:
    ; Resetea el contador para el siguiente disparo
    ld a, ENEMY_DELAY_SHOOT
    ld [wShootTimer], a

    ld a, [wCurrentEnemies]
    ld b, a          

    xor a
    ld [wFailedAttempts], a

.find_shooter:
    ; Genera un index random de enemigo
    call generate_random
    and %00000111           ; Rango 0-7
    cp b                    
    jr nc, .find_shooter    ; Si es muy alto, reintenta

    sla a              ; × 2
    sla a              ; × 4
    
    push af

    ; Comprueba si está activo
    ld hl, wEnemyArray
    ld b, 0
    ld c, a
    add hl, bc         
    
    ; Doble check de si está activo
    push hl           
    ld bc, 3          
    add hl, bc
    ld a, [hl]        
    pop hl         
    
    and a
    jr z, .retry_find   ; Si no está activo, prueba otra vez

    pop af
    push af
    
    jr .shoot_with_enemy   ; Si está activo, dispara

.retry_find:
    pop af            
    ; Intentos fallidos +1
    ld a, [wFailedAttempts]
    inc a
    ld [wFailedAttempts], a
    cp MAX_FAILED_ATTEMPTS
    jr z, .force_find_active   ; Si son muchos, fuérzalo
    jr .find_shooter

.force_find_active:
    ; Comprobar hasta encontrar uno activo
    ld hl, wEnemyArray
    ld b, MAX_ENEMIES
    ld c, 0                     ; Índice de enemigos actual * 4

.check_next:
    push hl
    push bc
    ld b, 0
    add hl, bc                  ; Apunta al enemigo actual
    
    ; Comprobar estado
    push hl
    ld bc, 3
    add hl, bc
    ld a, [hl]                  
    pop hl
    
    pop bc
    pop hl
    
    and a
    jr nz, .found_active
    
    ; Muévelo
    ld a, c
    add 4
    ld c, a
    dec b
    jr nz, .check_next
    ret                     ; Si no hay activos, vuelve

.found_active:
    ld a, c             ; Índice de enemigos actual * 4
    push af             

.shoot_with_enemy:    
    ; Guardar este enemigo como el último es disparar
    pop af           
    ld [wLastShootingEnemy], a

    ; Posición
    ld hl, wEnemyArray
    ld b, 0
    ld c, a
    add hl, bc       

    ; Comprueba si está activo antes de disparar
    push hl
    ld bc, 3
    add hl, bc
    ld a, [hl]
    pop hl
    and a
    ret z            ; Vuelve si está inactivo

    ; Encuentra una bala inactiva
    ld bc, 0                ; C contador
    push hl             
    ld hl, wBulletActive

.find_free_bullet:
    ld a, [hl]        ; Comprueba el estado de la bala
    and a
    jr z, .bullet_found
    inc hl
    inc c
    ld a, c
    cp 10
    jr z, .no_free_bullets
    jr .find_free_bullet

.bullet_found:
    ld a, 1
    ld [hl], a        ; Bala activa

    ; Dirección (1 = bala enemiga)
    ld hl, wBulletDirection
    add hl, bc
    ld a, 1
    ld [hl], a      

    ; Recuparar puntero al enemigo 
    pop hl            

    push hl             
    ld d, h
    ld e, l             ; DE = puntero a la estructura del enemigo
    ld hl, wBulletPosX
    add hl, bc
    ld a, [de]          ; X del enemigo
    ld [hl], a          ; X de la bala

    inc de            
    ld hl, wBulletPosY
    add hl, bc
    ld a, [de]          ; Y del enemigo
    add 7               ; Offset de la posición
    ld [hl], a          ; Y de la bala
    
    pop hl              ; Limpia el stack
    jr .end

.no_free_bullets:
    pop hl              ; Limpia el stack

.end:
    ; Hacer RANDOM_SEED_ADDR más random
    ld a, [wEnemyTimer]
    ld b, a
    ld a, [RANDOM_SEED_ADDR]
    add b
    ld [RANDOM_SEED_ADDR], a
    ret


generate_random:
    ld a, [RANDOM_SEED_ADDR]
    ld b, a

    ; Rotar a la izquierda
    rlca
    
    ; XOR con el original y el contador
    xor b
    ld b, a
    ld a, [wEnemyTimer]
    xor b
    
    ld [RANDOM_SEED_ADDR], a
    
    ret
    
; Input: A = índice del enemigo
desactivate_enemy::
    push hl
    push bc
    push de
    
    ld c, a            ; Guarda el ínidice del enemigo
    
    ; Calcular la dirección del enemigo
    ld hl, wEnemyArray
    ld d, 0
    ld e, ENEMY_STRUCT_SIZE
    
; Multiplica el índice por ENEMY_STRUCT_SIZE
.multiply_loop:        
    ld a, c
    and a             
    jr z, .done_multiply
    add hl, de        
    dec c
    jr .multiply_loop
    
.done_multiply:
    ld bc, ENEMY_ACTIVE_OFFSET
    add hl, bc
    
    ; Desactiva el enemigo
    xor a
    ld [hl], a
    
    ; Enemigos -1
    ld a, [wCurrentEnemies]
    dec a
    ld [wCurrentEnemies], a
    
    ; Comprueba si el nivel está completo
    and a           
    jr nz, .not_complete
    ld a, 1
    ld [wLevelComplete], a

.not_complete:
    pop de
    pop bc
    pop hl
    ret

; Devuelve: HL = BC * A
multiply::
    ld hl, 0
    and a
    ret z
.loop:
    add hl, bc
    dec a
    jr nz, .loop
    ret