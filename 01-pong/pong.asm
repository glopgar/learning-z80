org &4000
run prog_start

PADDLE_HEIGHT equ &30 ;; define la altura de las palas
PADDLE_START_POS equ &05
PADDLE_SPEED equ &02

.prog_start

call make_screen_addr_table ; inicializa la tabla de coordenadas de pantalla
call &bc14  ;Borra la pantalla
call compute_max_y

;; ---------------------------
;; -- pintado del "campo" ----
;; ---------------------------
ld HL, &c000    ; direccion inicial pintado linea (primer pixel primera linea)
call draw_field_line
ld HL, &ff80    ; direccion inicial pintado linea (primer pixel ultima linea)
call draw_field_line
call draw_paddles


.main_loop

;; wait for vsync
ld b,&f5
.v1 in a,(c)
rra
jr nc,v1

;; ------------------------
;; --- move paddles -------
;; ------------------------
call read_matrix ;; scan the keyboard

;; check for Q key
ld a,(matrix_buffer+8)
bit 3,a
jr z, q_not_pressed
ld a, (PADDLE_1_Y)
sub PADDLE_SPEED
jr c, q_not_pressed
ld b, PADDLE_SPEED
.loop_paddle_1_up
call paddle_1_up
djnz loop_paddle_1_up
.q_not_pressed

;; check A key
ld a,(matrix_buffer+8)
bit 5,a
jr z, a_not_pressed
ld a, (PADDLE_1_Y)
ld c, a
ld a, (MAX_Y)
sub c
sub PADDLE_SPEED
jr c, a_not_pressed
ld b, PADDLE_SPEED
.loop_paddle_1_down
call paddle_1_down
djnz loop_paddle_1_down
.a_not_pressed

.move_paddle_2

;; check for P key
ld a,(matrix_buffer+3)
bit 3,a
jr z, p_not_pressed
ld a, (PADDLE_2_Y)
sub PADDLE_SPEED
jr c, p_not_pressed
ld b, PADDLE_SPEED
.loop_paddle_2_up
call paddle_2_up
djnz loop_paddle_2_up
.p_not_pressed

;; check L key
ld a,(matrix_buffer+4)
bit 4,a
jr z, l_not_pressed
ld a, (PADDLE_2_Y)
ld c, a
ld a, (MAX_Y)
sub c
sub PADDLE_SPEED
jr c, l_not_pressed
ld b, PADDLE_SPEED
.loop_paddle_2_down
call paddle_2_down
djnz loop_paddle_2_down
.l_not_pressed

jp main_loop


;; ----------------------------------------------
;; -- baja la pala 1 -------------------
;; ----------------------------------------------
.paddle_1_down
;; pintar fondo en primer pixel de la pala
ld h, &00
ld a, (PADDLE_1_Y)
ld l, a
call get_screen_address
ld a, &00
ld (hl), a
; incrementar posicion de la pala
ld a, (PADDLE_1_Y)
inc a
ld (PADDLE_1_Y), a
; pintar color en el ultimo pixel de la pala + 1
ld h, &00
ld a, (PADDLE_1_Y)
add a, PADDLE_HEIGHT
dec a
ld l, a
call get_screen_address
ld a, &f0
ld (hl), a
ret

;; ----------------------------------------------
;; -- sube un pixel la pala 1 -------------------
;; ----------------------------------------------
.paddle_1_up
; pintar fondo en el ultimo pixel de la pala
ld h, &00
ld a, (PADDLE_1_Y)
add a, PADDLE_HEIGHT
dec a
ld l, a
call get_screen_address
ld a, &00
ld (hl), a
; decrementar posicion de la pala
ld a, (PADDLE_1_Y)
dec a
ld (PADDLE_1_Y), a
; pintar color en el primer pixel de la pala
ld h, &00
ld a, (PADDLE_1_Y)
ld l, a
call get_screen_address
ld a, &f0
ld (hl), a
ret

;; ----------------------------------------------
;; -- baja un pixel la pala 2 -------------------
;; ----------------------------------------------
.paddle_2_down
;; pintar fondo en primer pixel de la pala
ld h, &4E
ld a, (PADDLE_2_Y)
ld l, a
call get_screen_address
ld a, &00
ld (hl), a
; incrementar posicion de la pala
ld a, (PADDLE_2_Y)
inc a
ld (PADDLE_2_Y), a
; pintar color en el ultimo pixel de la pala + 1
ld h, &4E
ld a, (PADDLE_2_Y)
add a, PADDLE_HEIGHT
dec a
ld l, a
call get_screen_address
ld a, &f0
ld (hl), a
ret

;; ----------------------------------------------
;; -- sube un pixel la pala 2 -------------------
;; ----------------------------------------------
.paddle_2_up
; pintar fondo en el ultimo pixel de la pala
ld h, &4E
ld a, (PADDLE_2_Y)
add a, PADDLE_HEIGHT
dec a
ld l, a
call get_screen_address
ld a, &00
ld (hl), a
; decrementar posicion de la pala
ld a, (PADDLE_2_Y)
dec a
ld (PADDLE_2_Y), a
; pintar color en el primer pixel de la pala
ld h, &4E
ld a, (PADDLE_2_Y)
ld l, a
call get_screen_address
ld a, &f0
ld (hl), a
ret




;; -----------------------------------
;; -- pintado inicial de las palas ---
;; -----------------------------------
.draw_paddles
ld b, PADDLE_HEIGHT   ; altura de la pala en pixeles (longitud del bucle)
ld a, (PADDLE_1_Y) ; posicion inicial de las palas eje Y
ld l, a     ; cargamos en l la coordenada Y inicial

.next_paddle_line
ld h, &00   ; la pala siempre empieza en X=0
push hl     ; guardamos HL para incrementarlo mas tarde
call get_screen_address ; obtenemos en HL la direccion de memoria 
ld a, &f0   ; color de los pixeles a pintar
ld (hl), a  ; pintamos los pixeles en la direccion HL
pop hl      ; recuperamos las coordenadas X, Y en HL
ld h, &4E
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


;; -----------------------------------------------------------------------
;; -- tabla precalculada de direcciones de pantalla ----------------------
;; -- from: http://cpctech.cpc-live.com/docs/scraddr.html ----------------
;; -----------------------------------------------------------------------
.make_screen_addr_table
ld b,200						;; numero de lineas
ld ix,screen_addr_table			;; comienzo de la tabla
ld hl,&c000						;; direccion inicial de pantalla
.mst1
;; HL = direccion de comienzo de pantalla, para la linea en que nos encontremos
ld (ix+0),l		;; escribimos en la tabla el contenido de HL 
ld (ix+1),h
inc ix			;; avanzamos 2 bytes ix
inc ix
call &BC26		;; calcula la direccion de comienzo de la siguiente linea
djnz mst1		;; loop
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
ld c,h				;; guardamos el registro H (coordenada X), para mas tarde...
ld h,0				;; ...y lo ponemos a 0
                    ;; Ahora HL contiene solo la coordenada Y
add hl,hl			;; Cada elemento de la tabla de 
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



;; -----------------------------------------------------------------
;; ------- Rutina para escanear el teclado -------------------------
;; ------- http://cpctech.cpc-live.com/source/keyboard.asm ---------
;; -----------------------------------------------------------------

;; This example shows the correct method to read the keyboard and
;; joysticks on the CPC, CPC+ and KC Compact.
;;
;; This source is compatible with the CPC+.
;;
;; The following is assumed before executing of this algorithm:
;; - I/O port A of the PSG is set to input,
;; - PPI Port A is set to output
;;

;;--------------------------------------------------------------------------------
;; example code showing how to use read_matrix.

;; NOTE: Consult the 'matrix' table in the
;; document 'Scanning the Keyboard & Joysticks' to find the keyboard line
;; and bit for the keys you want to check.
;; http://cpctech.cpc-live.com/docs/keyboard.html
;;--------------------------------------------------------------------------------

.read_matrix 
ld hl,matrix_buffer        ; buffer to store matrix data

ld bc,&f40e                ; write PSG register index (14) to PPI port A (databus to PSG)
out (c),c

ld b,&f6
in a,(C)
and &30
ld c,A

or &C0                     ;; bit 7=bit 6=1 (PSG operation : write register index)
out (c),a                  ; set PSG operation -> select PSG register 14

;; at this point PSG will have register 14 selected.
;; any read/write operation to the PSG will act on this register.

out (c),c                  ;; bit 7=bit 6=0 (PSG operation: inactive)

inc b
ld a,&92
out (c),a                  ;; write PPI control: port A: input, port B: input, port C upper: output
                           ;; port C lower: output
push bc
set 6,c                    ;; bit 7=0, bit 6=1 (PSG operation: read register data)

.scan_key 
ld b,&f6 
out (c),c                 ;; set matrix line & set PSG operation

ld b,&f4                  ;PPI port A (databus to/from PSG)
in a,(c)                  ;get matrix line data from PSG register 14

cpl                       ;;invert data: 1->0, 0->1
                          ;;if a key/joystick button is pressed bit will be "1"
                          ;;keys that are not pressed will be "0"

ld (hl),a                 ;;write line data to buffer
inc hl                    ;;update position in buffer
inc c                     ;;update line

ld a,c
and &0f
cp &0a                    ;scanned all rows?
jr nz,scan_key            ;no loop and get next row

;; scanned all rows
pop bc

ld a,&82                  ;;write PPI Control: Port A: Output, Port B: Input, Port C upper: output, Port C lower: output.
out (c),a

dec b
out (c),c                 ;;set PSG operation: bit7=0, bit 6=0 (PSG operation: inactive)
ret

.compute_max_y
ld a, &C8
sub PADDLE_HEIGHT
ld (MAX_Y), a
ret	

;; This buffer has one byte per keyboard line. 
;; Each byte defines a single keyboard line, which defines 
;; the state for up to 8 keys.
;;
;; A bit in a byte will be '1' if the corresponding key 
;; is pressed, '0' if the key is not pressed.
.matrix_buffer
defs 10

;; reservamos 400 bytes para la tabla de direcciones de memoria (200 lineas * 16bits)
.screen_addr_table
defs 200*2		

PADDLE_1_Y defb PADDLE_START_POS
PADDLE_2_Y defb PADDLE_START_POS
MAX_Y defb &00