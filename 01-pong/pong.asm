org &4000

.start
call make_screen_addr_table ; inicializa la tabla de coordenadas de pantalla
call &bc14      ;Borra la pantalla

;; ---------------------------
;; -- pintado del "campo" ----
;; ---------------------------
ld HL, &c000    ; direccion inicial pintado linea (primer pixel primera linea)
call draw_field_line
ld HL, &ff80    ; direccion inicial pintado linea (primer pixel ultima linea)
call draw_field_line

;; -----------------------------------
;; -- pintado inicial de las palas ---
;; -----------------------------------
ld a, &15 ; posicion inicial de la pala eje Y
ld b, &20   ; altura de la pala en pixeles (longitud del bucle)
ld h, &00   ; la pala siempre empieza en X=0
ld l, a     ; cargamos en l la coordenada Y inicial
.next_paddle_line
push hl     ; guardamos HL para incrementarlo mas tarde
call get_screen_address ; obtenemos en HL la direccion de memoria 
ld a, &f0   ; color de los pixeles a pintar
ld (hl), a  ; pintamos los pixeles en la direccion HL
pop hl      ; recuperamos las coordenadas X, Y en HL
inc l       ; incrementamos las Y
djnz next_paddle_line   ; volvemos a dibujar

ret



;; ----------------------------------
;; --- dibuja una linea del campo ---
;; ----------------------------------
.draw_field_line             
ld a, &ff        ; en A los colores a imprimir
ld b, &50        ; contador en B ancho de pantalla
.draw_field_line_loop
ld (HL), a       ;pintamos en la posicion de memoria (HL)
inc HL           ;Movemos la posicion de pantalla (derecha)
djnz draw_field_line_loop    ; restamos 1 a b y si no cero saltamos a imprimir
ret


;; --------------------------------------
;; -- tabla de direcciones de pantalla --
;; -- from: http://cpctech.cpc-live.com/docs/scraddr.html
;; -------------------------------------- 
.make_screen_addr_table
ld b,200						;; number of lines
ld ix,screen_addr_table			;; start of table
ld hl,&c000						;; base memory address of screen
.mst1
;; HL = current memory address for the start of the scan line
ld (ix+0),l						;; write to table
ld (ix+1),h
inc ix							;; update position in table (ready for next entry)
inc ix
call &BC26				;; calculate memory address
djnz mst1						;; loop
ret

;; ---------------------------------------------------------------------------------
;; -- subrutina para obtener la direccion de pantalla a partir de coordenadas X, Y
;; -- from: http://cpctech.cpc-live.com/docs/scraddr.html
;; ---------------------------------------------------------------------------------
;; input conditions:
;; H = x byte coordinate (0-79)
;; L = y coordinate (0-199)
;; output conditions:
;; HL = screen address
.get_screen_address

push bc
ld c,h				;; store H coordinate for later
ld h,0				;; H used to hold X coordinate, need to zero this out
                    ;; because we want HL to contain the Y coordinate
add hl,hl				;; each element of the look-up table is 2 bytes
					;; convert y position to a byte offset from the start
					;; of the look up table
ld de,screen_addr_table
add hl,de				;; add start of lookup table to get address of element
					;; in lookup table
ld a,(hl)
inc hl
ld h,(hl)
ld l,a				;; read element from lookup table (memory address of the start
					;; of the line defined by the y coordinate)
ld b,0
add hl,bc				;; add on X byte coordinate
;; HL = final memory address
pop bc
ret

;; reservamos 400 bytes para la tabla de direcciones de memoria (200 lineas * 16bits)
.screen_addr_table
defs 200*2		
