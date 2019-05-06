org &4000

.start
call &bc14      ;Borra la pantalla

ld HL, &c000    ; direccion inicial pintado linea (primer pixel primera linea)
call draw_field_line
ld HL, &ff80    ; direccion inicial pintado linea (primer pixel ultima linea)
call draw_field_line
ret

.draw_field_line             
ld a, &ff        ; en A los colores a imprimir
ld b, &50        ; contador en B ancho de pantalla
.draw_field_line_loop
ld (HL), a       ;pintamos en la posicion de memoria (HL)
inc HL           ;Movemos la posicion de pantalla (derecha)
djnz draw_field_line_loop    ; restamos 1 a b y si no cero saltamos a imprimir
ret