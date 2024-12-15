include "hardware.inc"

SECTION "BulletVariables", WRAM0
wBulletActive: ds 10        ; Array del estado de 10 balas (1 = activa, 0 = inactiva)
wBulletPosX: ds 10          ; Array de la posición X de cada bala
wBulletPosY: ds 10          ; Array de la posición Y de cada bala
wShootDelay: ds 1           ; COntador para el delay de los disparos
wBulletDirection: DS 10     ; 0 = down_to_up, 1 = up_to_down

SECTION "Bullet", ROM0

initializeBullet::
    ld de, bala_vertical          
    ld hl, $8010                  
    ld bc, bala_vertical_end - bala_vertical
    call mem_copy                 

    ; Inicializar las balas como inactivas
    ld b, 10                      
    ld hl, wBulletActive
.clearLoop:
    xor a
    ld [hl+], a                
    ld [hl+], a                  ; PosX
    ld [hl+], a                  ; PosY
    dec b
    jr nz, .clearLoop

    ; Inicializa el delay
    xor a
    ld [wShootDelay], a         ; Empieza sin delay
    ret

; Puede llamarse en cualquier momento - maneja la lógica de disparo
FireBullet::
    ; Comprueba el delay
    ld a, [wShootDelay]
    and a                      
    jr z, .canShoot            
    ret                       

.canShoot:
    ; Comprueba si se han apretado el botón A
    ld a, [wNewKeys]
    and PADF_A                  
    ret z                       
    
    ld a, 30                    ; 0.5 seugndos 60 FPS
    ld [wShootDelay], a
    
    ; Busca una bala inactiva
    ld c, 0                     ; Use C as counter
    ld hl, wBulletActive        
.findFreeBullet:
    ld a, [hl]                  
    and a                       
    jr z, .foundFree           
    inc hl                      
    inc c                       
    ld a, c
    cp 10
    ret z                      ; No se ha encontrado ninguna
    jr .findFreeBullet

.foundFree:
    ; Activa la bala
    ld a, 1
    ld [hl], a             

    ; 0 = down_to_up -> Dispara el jugador 
    ld hl, wBulletDirection
    ld b, 0
    add hl, bc
    xor a
    ld [hl], a


    ld hl, wBulletPosX
    ld b, 0
    add hl, bc                  ; X
    ld a, [posicionNaveX]
    add 8
    ld [hl], a                 

    ld hl, wBulletPosY
    ld b, 0
    add hl, bc                  ; Y 
    ld a, [posicionNaveY]
    add 11
    ld [hl], a                 
    ret

; Actualiza la lógica de las balas (puede llamarse en cualquier momento)
UpdateBulletLogic::
    ; Actualiza el delay
    ld a, [wShootDelay]
    and a                      
    jr z, .updateBullets     
    dec a                     
    ld [wShootDelay], a        

.updateBullets:
    ld c, 0                   ; Índice de la bala
.updateLoop:
    push bc                   

    ; Comprueba si está activa
    ld hl, wBulletActive
    ld b, 0
    add hl, bc
    ld a, [hl]
    and a
    jr z, .nextBullet        ; Skip si está inactiva

    ; Comprueba si la bala la dispara el jugador (0) o el enemigo (1)
    ld hl, wBulletDirection
    ld b, 0
    add hl, bc
    ld a, [hl]
    and a
    jr nz, .move_down      ; Skip si la dispara el enemigo

.move_up
    ld hl, wBulletPosY
    ld b, 0
    add hl, bc
    ld a, [hl]
    sub 2                    ; Mueve arriba
    ld [hl], a               ; Y
    
    ; Comrueba si la pantalla está apagada
    cp 16                    
    jr c, .deactivateBullet
    jr .nextBullet

.move_down
    ld hl, wBulletPosY
    ld b, 0
    add hl, bc
    ld a, [hl]
    add 2                    ; Mueve abajo
    ld [hl], a               ; Y

    ; Comrueba si la pantalla está apagada
    cp 144                
    jr nc, .deactivateBullet
    jr .nextBullet

.deactivateBullet:
    ; Desactiva la bala
    ld hl, wBulletActive
    ld b, 0
    add hl, bc
    xor a
    ld [hl], a

.nextBullet:
    pop bc                 
    inc c
    ld a, c
    cp 10                  
    jr nz, .updateLoop
    ret

; Actualiza los sprites de las balas en OAM (DEBE llamarse durante VBLANK)
UpdateBulletSprites::
    
    ; OAM:
    ; _OAMRAM + 0  (4 bytes):  Sprite del jugador
    ; _OAMRAM + 4  (40 bytes): Todas las balas (10 balas * 4 bytes)
    ; _OAMRAM + 44: Comienzo de los sprites de los enemigos

    ; Limpia los de las balas
    ld hl, _OAMRAM + 4         
    ld b, 40                    ; 40 bytes (10 balas * 4 bytes)
    xor a
.clear_all_bullets:
    ld [hl+], a                
    dec b
    jr nz, .clear_all_bullets

    ld c, 0                     ; ïnidce de balas
.updateLoop:
    push bc

    ; Comprueba si está activa
    ld hl, wBulletActive
    ld b, 0
    add hl, bc
    ld a, [hl]
    and a
    jr z, .nextBullet           ; Skip si inactiva

    ld hl, wBulletPosX
    ld b, 0
    add hl, bc
    ld d, [hl]                  ; X en D
    
    ld hl, wBulletPosY
    ld b, 0
    add hl, bc
    ld e, [hl]                  ; Y en E

    ; Calcula posición en la OAM
    push bc
    ld a, c
    add a, a                    ; *4 para la OAM 
    add a, a
    ld c, a
    ld b, 0
    ld hl, _OAMRAM + 4          ; La bala empieza después del jugador
    add hl, bc                  ; Añade el offset

    ; Escribe la información de la bala
    ld a, e                     ; Y 
    ld [hl+], a
    ld a, d                     ; X 
    ld [hl+], a
    ld a, $01                   ; Tile 
    ld [hl+], a
    xor a                       ; Atributos
    ld [hl], a
    
    pop bc

.nextBullet:
    pop bc
    inc c
    ld a, c
    cp 10                       ; Comprueba si no quedan balas
    jr nz, .updateLoop
    ret