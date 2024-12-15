; Contantes de enemigos
DEF MAX_ENEMIES             EQU 10      ; Máximo de enemigos en pantalla
DEF ENEMY_STRUCT_SIZE       EQU 4       ; Tamaño de la estructura del enemigo (X, Y, dirección, activo)
DEF ENEMY_MIN_X             EQU 8       ; Límite izquierda
DEF ENEMY_MAX_X             EQU 152     ; Límte derecha
DEF ENEMY_MIN_Y             EQU 16      ; Límite arriba
DEF ENEMY_MAX_Y             EQU 88      ; Límmite abajo
DEF ENEMY_ACTIVE_OFFSET     EQU 3     
DEF MOVE_DELAY              EQU 8

; Direcciones/Patrones de movimiento
DEF DIR_RIGHT               EQU 0       ; Originalmente a la derecha
DEF DIR_LEFT                EQU 1       ; Originalmente a la izquierda
DEF DIR_UP                  EQU 2       ; Hacia arriba
DEF DIR_DOWN                EQU 3       ; Hacia abajo
DEF DIR_DIAGONAL_RIGHT      EQU 4       ; Diagonal derecha
DEF DIR_DIAGONAL_LEFT       EQU 5       ; Diagonal izquierda

DEF ENEMY_SPEED             EQU 1       ; Velocidad de los enemigos por nivel  

DEF ENEMY_SPEED_LVL4        EQU 2       ; Velocidad+ para el 4
DEF ENEMY_SPEED_LVL5        EQU 3       ; Velocidad++ para el 5
DEF ENEMY_SPEED_LVL6        EQU 4       ; Velocidad+++ para el 6

; Constantes de niveles
DEF TOTAL_ENEMIES_LVL1      EQU 3       ; Nivel 4: Patrón diagonal
DEF TOTAL_ENEMIES_LVL2      EQU 5       ; Nivel 5: Mezcla arriba/abajo
DEF TOTAL_ENEMIES_LVL3      EQU 7       ; Nivel 6: Todas las direcciones
DEF TOTAL_ENEMIES_LVL4      EQU 8       ; Nivel 4: Patrón diagonal
DEF TOTAL_ENEMIES_LVL5      EQU 9       ; Nivel 5: Mezcla arriba/abajo
DEF TOTAL_ENEMIES_LVL6      EQU 10      ; Nivel 6: Todas las direcciones