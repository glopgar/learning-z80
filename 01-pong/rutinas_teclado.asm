; -----------------------------------------------------------------------------
; |Rutinas para detección de teclado leyendo diréctamente el hardware del CPC |
; |Raúl Simarro (Artaburu) 2006 |
; -----------------------------------------------------------------------------

;_______________________________________________________________________________
; Ejemplo
;_______________________________________________________________________________

ORG &4000

xor a
ld (salir),a

_bucle_teclado
call detecta_teclas_hardware
ld a,(salir)
cp 1 ;termina al pulsar esc
jp nz,_bucle_teclado

ret
salir db 0
;______________________________________________________________________________
detecta_teclas_hardware ; cada vez que se quieran detectar
di ; las teclas pulsadas se debe
call comprobacion_teclas_pulsadas ; ejecutar esta rutina
ei

ld a,(teclado)
;_________________________________________________
; movimientos extras
;_________________________________________________
;cp %00000101
;jr z,arriba_derecha
;cp %00000110
;jr z,arriba_izquierda
;cp %0001001
;jr z,arriba_corto_derecha
;cp %00001010
;jr z,arriba_corto_izquierda
;_________________________________________________

cp %00000100
jp z, tecla_arriba

cp %00001000
jp z, tecla_abajo

cp %00000010
jp z, tecla_izquierda

cp %00000001
jp z, tecla_derecha
ret



comprobacion_teclas_pulsadas
xor a
ld (teclado),a ;Reinicia a 0 la vble teclado


ld hl,tecla_izquierda_x+1
ld a,(HL)
ld (linea_a_buscar+1),a ;cambia la línea a explorar
XOR A
call detecta_teclado_x ; esta rutina lee la línea del teclado correspondiente
DEC hl ; pero sólo nos interesa una de las teclas.
and (HL) ;para filtrar por el bit de la tecla (puede haber varias pulsadas)
CP (hl) ;comprueba si el byte coincide
call z,tecla_izquierda_pulsada

ld hl,tecla_derecha_x+1
ld a,(HL)
ld (linea_a_buscar+1),a
XOR A
call detecta_teclado_x
DEC hl
and (HL)
CP (hl)
call z,tecla_derecha_pulsada

ld hl,tecla_arriba_x+1
ld a,(HL)
ld (linea_a_buscar+1),a
XOR A
call detecta_teclado_x
DEC hl
and (HL)
CP (hl)
call z,tecla_arriba_pulsada

ld hl,tecla_abajo_x+1
ld a,(HL)
ld (linea_a_buscar+1),a
XOR A
call detecta_teclado_x
DEC hl
and (HL)
CP (hl)
call z,tecla_abajo_pulsada



; Comprueba si se ha pulsado ESC
ld a,8
ld (linea_a_buscar+1),a
XOR A
di
call detecta_teclado_x
ei
cp 4
jp z, esc_pulsado
ret


esc_pulsado
ld a,1
ld (salir),a
ret

tecla_izquierda_pulsada
ld a,(teclado)
or %00000001
ld (teclado),a
ret
tecla_derecha_pulsada
ld a,(teclado)
or %00000010
ld (teclado),a
ret
tecla_arriba_pulsada
ld a,(teclado)
or %00000100
ld (teclado),a
ret
tecla_abajo_pulsada
ld a,(teclado)
or %00001000
ld (teclado),a
ret

detecta_teclado_x ;Tomado de las rutinas básicas que aparecen
;en los documentos de Kevin Thacker

ld bc,&f7*256+%10000010
out (c),c ;PPI A OUT. RESET.

ld bc,&f400+14 ;Registro 14 del PSG (Puerta A)
out (c),c ;(contains keyboard line data)

ld b,&f6 ;PSG control
ld c,%11000000 ;Select Register 14 for use
out (c),C ;send

ld c,0 ;PSG inactive
out (c),c ;send

ld b,&f7 ;8255 PPI control
ld c,%10010010 ;Port A and Port C (upper) - Operating mode 0
;Port A input, Port C (upper) output.

;Port B and Port C (lower) - Operating mode 0
;Port B input, Port C (lower) output

out (c),c ;send control byte

;;READ KEYBOARD LINE

ld b,&F6 ;PSG control + keyboard line wanted
ld a,%01000000 ;PSG control - read

; >> linea a buscar <<
linea_a_buscar
; >> linea a buscar <<
or 1 ;keyboard line 1 ;Cambio esta línea para explorar distintas
;líneas del teclado.
out (c),a ;send it
ld b,&F4 ;Port to get PSG port A (register 14) data
in a,(c) ;Keyboard data from keyboard line 9
cpl
ret



teclado db 0 ;Este byte indicará qué teclas han sido pulsadas
;después de un ciclo de exploración
linea db 0
bte db 0
tecla_0 dw &0204
;teclado_usable ; teclas del cursor, cada tecla está definida por su bit y su línea.
tecla_izquierda_x dw &0002 ; bit 0, línea 2
tecla_derecha_x dw &0101 ; bit 1, línea 1
tecla_arriba_x dw &0001 ; bit 0, línea 1
tecla_abajo_x dw &0004 ; bit 0, línea 4




tecla_arriba
;operaciones
ld a,65
call &bb5a ; como ejemplo, imprime la letra A,
; &BB5A es la rutina del firmware que escribe un caracter en pantalla.
ret
tecla_abajo
;operaciones
ld a,66
call &bb5a ; como ejemplo, imprime la letra B
ret
tecla_izquierda
;operaciones
ld a,67
call &bb5a ; como ejemplo, imprime la letra C
ret
tecla_derecha
;operaciones
ld a,68
call &bb5a ; como ejemplo, imprime la letra D
ret