.8086
.model small
.stack 100h

.data
    nombreArchivo db 'grilla.txt', 0
    buferArchivo dw ?
    
    buferInterfaz db 7296 dup(' ')

    celdaActualX db 1
    celdaActualY db 1
    paginaX db 0
    paginaY db 0
    letrasCelda db 0
    caracterTeclado db 0

.code

public inicializarBufer
public cargarArchivo
public limpiarPantalla
public dibujarInterfaz
public actualizarCursor
public procesarMouse
public escribirCaracter
public manejarFlechas
public borrarCaracter
public procesarFormulas
public resolverReferencia
public guardarArchivo
public imprimirReg
public regAAscii

; ==========================================
; Armado de cuadriculas
; ==========================================

inicializarBufer proc
    mov cx, 48 ; CX
    mov di, 0
formatearFila:
    push cx
    mov cx, 150 ; CX
    mov dx, 0
formatearCol:
    mov ax, dx
    mov bl, 10
    div bl
    cmp ah, 0
    je ponerLinea
    mov al, ' '
    jmp guardarCaracter
ponerLinea:
    mov al, '|'
guardarCaracter:
    mov buferInterfaz[di], al
    inc di
    inc dx
    loop formatearCol
    
    mov byte ptr buferInterfaz[di], 13
    mov byte ptr buferInterfaz[di+1], 10
    add di, 2
    
    pop cx
    loop formatearFila
    ret
inicializarBufer endp

; ==========================================
; Carga
; ==========================================

cargarArchivo proc
    push ax
    push bx
    push cx
    push dx
    mov ah, 3Dh
    mov al, 0 ; read only
    lea dx, nombreArchivo
    int 21h
    jc finCargar ; Si no existe salta
    mov buferArchivo, ax
    mov ah, 3Fh
    mov bx, buferArchivo
    mov cx, 7296
    lea dx, buferInterfaz
    int 21h
    mov ah, 3Eh
    mov bx, buferArchivo
    int 21h
finCargar:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
cargarArchivo endp

; ==========================================
; CLS
; ==========================================

limpiarPantalla proc
    push ax
    push es
    push cx
    push di
    
    mov ax, 3
    int 10h
    
    mov ax, 0b800h
    mov es, ax
    mov cx, 2000 ; CX
    mov ax, 0720h
    mov di, 0
    cld
    rep stosw
    
    pop di
    pop cx
    pop es
    pop ax
    ret
limpiarPantalla endp

; ==========================================
; GRÁFICOS
; ==========================================

dibujarInterfaz proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, 0B800h
    mov es, ax
    
    mov di, 0
    mov dx, 0
dibCabecera:
    mov ax, dx
    mov bl, 10
    div bl
    cmp ah, 0
    jne espacioCab
    mov al, '|'
    jmp impCab
espacioCab:
    mov al, ' '
impCab:
    mov ah, 07h
    mov es:[di], ax
    add di, 2
    inc dx
    cmp dx, 80
    jl dibCabecera

    mov di, 22
    mov al, 'A'
    cmp paginaX, 1
    jne iniciarLetras
    mov al, 'H'
iniciarLetras:
    mov cx, 7 ; CX
dibujarCols:
    mov byte ptr es:[di], al
    mov byte ptr es:[di+1], 0Eh
    add di, 20
    inc al
    loop dibujarCols

    mov di, 160
    
    mov al, paginaY
    mov bl, 24
    mul bl
    
    inc ax
    mov bl, al
    push bx
    dec ax
    
    mov bx, 152
    mul bx
    mov si, ax
    
    mov cx, 24 ; CX
dibujarFila:
    push cx
    mov cx, 80 ; CX
    mov dx, 0
dibujarColumna:
    mov bx, dx
    cmp paginaX, 1
    jne noSalto
    cmp dx, 10
    jl noSalto
    add bx, 70
noSalto:
    mov al, buferInterfaz[si+bx]
    mov ah, 07h
    mov es:[di], ax
    add di, 2
    inc dx
    loop dibujarColumna
    
    add si, 152
    pop cx
    loop dibujarFila

    pop bx
    mov di, 160
    mov cx, 24 ; CX
dibujarFilas:
    mov al, bl
    aam
    add ax, 3030h
    
    mov byte ptr es:[di+2], ah
    mov byte ptr es:[di+3], 0Eh
    mov byte ptr es:[di+4], al
    mov byte ptr es:[di+5], 0Eh

    add di, 160
    inc bl
    loop dibujarFilas

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
dibujarInterfaz endp

; ==========================================
; Cursor
; ==========================================

actualizarCursor proc
    push ax
    push bx
    push dx
    
    mov al, celdaActualX
    cmp paginaX, 1
    jne calcularCx
    sub al, 7
calcularCx:
    mov bl, 10
    mul bl
    inc ax
    mov dl, al
    
    mov al, celdaActualY
    cmp paginaY, 1
    jne establecerCy
    sub al, 24
establecerCy:
    mov dh, al
    
    mov ah, 02h
    mov bh, 0
    int 10h
    mov letrasCelda, 0
    
    pop dx
    pop bx
    pop ax
    ret
actualizarCursor endp

; ==========================================
; Mouse
; ==========================================

procesarMouse proc
    push ax
    push bx
    push cx
    push dx

    mov ax, 0002h
    int 33h

    mov ax, cx
    mov cl, 3
    shr ax, cl
    mov bl, 10
    div bl
    cmp al, 1
    jge verificarMaxX
    mov al, 1
verificarMaxX:
    cmp al, 7
    jle establecerX
    mov al, 7
establecerX:
    cmp paginaX, 1
    jne guardarX
    add al, 7
guardarX:
    mov celdaActualX, al

    pop dx
    push dx
    mov ax, dx
    mov cl, 3
    shr ax, cl
    cmp al, 1
    jge verificarMaxY
    mov al, 1
verificarMaxY:
    cmp al, 24
    jle establecerY
    mov al, 24
establecerY:
    cmp paginaY, 1
    jne guardarY
    add al, 24
guardarY:
    mov celdaActualY, al

    call actualizarCursor

    mov ax, 0001h
    int 33h

    mov cx, 0AFFFh ; CX
pausaClic:
    loop pausaClic

    pop dx
    pop cx
    pop bx
    pop ax
    ret
procesarMouse endp

; ==========================================
; Escritura
; ==========================================

escribirCaracter proc
    cmp letrasCelda, 9
    jge finEscritura

    push ax
    push bx
    push si

    mov caracterTeclado, al
    mov ah, 0Eh
    mov bh, 0
    int 10h

    mov al, celdaActualY
    dec al
    xor ah, ah ; Limpia la basura de AH
    mov bx, 152
    mul bx
    mov si, ax
    
    mov al, celdaActualX
    mov bl, 10
    mul bl
    inc ax ; Suma 1 para no borrar el |
    add si, ax

    mov al, letrasCelda
    cbw
    add si, ax

    mov al, caracterTeclado
    mov buferInterfaz[si], al
    inc letrasCelda

    pop si
    pop bx
    pop ax
finEscritura:
    ret
escribirCaracter endp

; ==========================================
; Navegación
; ==========================================

manejarFlechas proc
    cmp ah, 48h
    je mArriba
    cmp ah, 50h
    je mAbajo
    cmp ah, 4Bh
    je mIzquierda
    cmp ah, 4Dh
    je mDerecha
    ret

mArriba:
    cmp celdaActualY, 1
    jle finMov
    dec celdaActualY
    call verificarPagina
    jmp mover

mAbajo:
    cmp celdaActualY, 48
    jge finMov
    inc celdaActualY
    call verificarPagina
    jmp mover

mIzquierda:
    cmp celdaActualX, 1
    jle finMov
    dec celdaActualX
    call verificarPagina
    jmp mover

mDerecha:
    cmp celdaActualX, 14
    jge finMov
    inc celdaActualX
    call verificarPagina
    jmp mover

mover:
    call actualizarCursor
finMov:
    ret
manejarFlechas endp

verificarPagina proc
    push ax
    push bx
    mov bl, 0

    mov al, celdaActualY
    cmp al, 24
    jg pyUno
pyCero:
    cmp paginaY, 0
    je verificarPx
    mov paginaY, 0
    mov bl, 1
    jmp verificarPx
pyUno:
    cmp paginaY, 1
    je verificarPx
    mov paginaY, 1
    mov bl, 1

verificarPx:
    mov al, celdaActualX
    cmp al, 7
    jg pxUno
pxCero:
    cmp paginaX, 0
    je finVerificar
    mov paginaX, 0
    mov bl, 1
    jmp finVerificar
pxUno:
    cmp paginaX, 1
    je finVerificar
    mov paginaX, 1
    mov bl, 1

finVerificar:
    cmp bl, 1
    jne salirVp
    call limpiarPantalla
    call dibujarInterfaz
salirVp:
    pop bx
    pop ax
    ret
verificarPagina endp

; ==========================================
; Borrado
; ==========================================

borrarCaracter proc
    push ax
    push bx
    push si

    cmp letrasCelda, 0
    je finBorrado

    mov ah, 0Eh
    mov al, 8
    mov bh, 0
    int 10h
    mov al, ' '
    int 10h
    mov al, 8
    int 10h

    dec letrasCelda
    
    mov al, celdaActualY
    dec al
    xor ah, ah ;Limpia la basura de AH
    mov bx, 152
    mul bx
    mov si, ax
    
    mov al, celdaActualX
    mov bl, 10
    mul bl
    inc ax ;Suma 1 para alinear el cursor
    add si, ax

    mov al, letrasCelda
    cbw
    add si, ax
    mov buferInterfaz[si], ' '

finBorrado:
    pop si
    pop bx
    pop ax
    ret
borrarCaracter endp

; ==========================================
; Referencia casillas
; ==========================================

resolverReferencia proc
    push bx
    push cx
    push dx
    push di

    mov al, buferInterfaz[si]
    sub al, 'A'
    inc al
    cbw
    mov cx, 10
    mul cx
    inc ax
    mov di, ax

    inc si
    mov cx, 0
leerFilaRef:
    mov al, buferInterfaz[si]
    cmp al, '0'
    jl finFilaRef
    cmp al, '9'
    jg finFilaRef

    sub al, 30h
    cbw
    push ax
    mov ax, cx
    mov bx, 10
    mul bx
    pop bx
    add ax, bx
    mov cx, ax

    inc si
    jmp leerFilaRef

finFilaRef:
    dec cx
    mov ax, cx
    mov cx, 152
    mul cx
    add di, ax

    mov cx, 0
leerValorRef:
    mov al, buferInterfaz[di]
    cmp al, '0'
    jl finValorRef
    cmp al, '9'
    jg finValorRef

    sub al, 30h
    cbw
    push ax
    mov ax, cx
    mov bx, 10
    mul bx
    pop bx
    add ax, bx
    mov cx, ax

    inc di
    jmp leerValorRef

finValorRef:
    mov ax, cx

    pop di
    pop dx
    pop cx
    pop bx
    ret
resolverReferencia endp

; ==========================================
; Formulas
; ==========================================

procesarFormulas proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov si, 0
buscarInicio:
    cmp si, 7290
    jb comprobarSuma
    jmp finProcesar

comprobarSuma:
    cmp buferInterfaz[si], 'S'
    jne comprobarRes
    cmp buferInterfaz[si+1], 'U'
    jne comprobarRes
    cmp buferInterfaz[si+2], 'M'
    jne comprobarRes
    cmp buferInterfaz[si+3], '('
    jne comprobarRes

    mov di, si
    add si, 4
    jmp extraerNumeros

comprobarRes:
    cmp buferInterfaz[si], 'R'
    jne comprobarMul
    cmp buferInterfaz[si+1], 'E'
    jne comprobarMul
    cmp buferInterfaz[si+2], 'S'
    jne comprobarMul
    cmp buferInterfaz[si+3], '('
    jne comprobarMul

    mov di, si
    add si, 4
    jmp extraerNumeros

comprobarMul:
    cmp buferInterfaz[si], 'M'
    jne saltoSiguiente
    cmp buferInterfaz[si+1], 'U'
    jne comprobarMax
    cmp buferInterfaz[si+2], 'L'
    jne saltoSiguiente
    cmp buferInterfaz[si+3], '('
    jne saltoSiguiente

    mov di, si
    add si, 4
    jmp extraerNumeros

comprobarMax:
    cmp buferInterfaz[si+1], 'A'
    jne saltoSiguiente
    cmp buferInterfaz[si+2], 'X'
    jne saltoSiguiente
    cmp buferInterfaz[si+3], '('
    jne saltoSiguiente

    mov di, si
    add si, 4

    mov al, buferInterfaz[si]
    cmp al, '0'
    jl comprobarLetraMax
    cmp al, '9'
    jg comprobarLetraMax
    jmp extraerNumeros

comprobarLetraMax:
    mov al, buferInterfaz[si+1]
    cmp al, ','
    je esLetraMax
    jmp extraerNumeros

esLetraMax:
    mov bl, buferInterfaz[si]
    inc si
    cmp buferInterfaz[si], ','
    jne saltoError
    inc si
    mov bh, buferInterfaz[si]
    inc si
    cmp buferInterfaz[si], ')'
    jne saltoError

    cmp bl, bh
    jge guardarLetraMax
    mov bl, bh

guardarLetraMax:
    mov buferInterfaz[di], bl
    inc di
    mov bp, si
    jmp limpiarRestos

saltoSiguiente:
    jmp siguienteCaracter

saltoError:
    jmp errorFormato

extraerNumeros:
    mov cx, 0
analizarA:
    mov al, buferInterfaz[si]
    cmp al, ','
    je finAnalizarA
    cmp al, 'A'
    jge esRefA

    cmp al, '0'
    jl saltoError
    cmp al, '9'
    jg saltoError

    sub al, 30h
    cbw
    push ax
    
    mov ax, cx
    mov bx, 10
    mul bx
    pop bx
    add ax, bx
    mov cx, ax
    
    inc si
    jmp analizarA

esRefA:
    call resolverReferencia
    mov cx, ax
buscarComaA:
    mov al, buferInterfaz[si]
    cmp al, ','
    je finAnalizarA
    inc si
    jmp buscarComaA

finAnalizarA:
    inc si

    mov bp, 0
analizarB:
    mov al, buferInterfaz[si]
    cmp al, ')'
    je finAnalizarB
    cmp al, 'A'
    jge esRefB

    cmp al, '0'
    jl saltoError
    cmp al, '9'
    jg saltoError

    sub al, 30h
    cbw
    push ax
    
    mov ax, bp
    mov bx, 10
    mul bx
    pop bx
    add ax, bx
    mov bp, ax
    
    inc si
    jmp analizarB

esRefB:
    call resolverReferencia
    mov bp, ax
buscarParenB:
    mov al, buferInterfaz[si]
    cmp al, ')'
    je finAnalizarB
    inc si
    jmp buscarParenB

finAnalizarB:
    mov al, buferInterfaz[di]
    cmp al, 'S'
    je hacerSuma
    cmp al, 'R'
    je hacerRes
    cmp al, 'M'
    je decidirMulOMax
    jmp errorFormato

decidirMulOMax:
    mov al, buferInterfaz[di+1]
    cmp al, 'U'
    je hacerMul
    cmp al, 'A'
    je hacerMaxNum
    jmp errorFormato

hacerSuma:
    mov ax, cx
    mov bx, bp
    int 60h
    jmp limpiarYGuardar

hacerRes:
    mov ax, cx
    mov bx, bp
    sub ax, bx
    mov bx, ax
    jmp limpiarYGuardar

hacerMul:
    mov ax, cx
    mov bx, bp
    mul bx
    mov bx, ax
    jmp limpiarYGuardar

hacerMaxNum:
    mov ax, cx
    cmp ax, bp
    jge maxEsCX
    mov ax, bp
maxEsCX:
    mov bx, ax
    jmp limpiarYGuardar

limpiarYGuardar:
    push si
    push di
    
    mov dl, bl
    lea bx, buferInterfaz[di]
    call regAAscii

    pop di
    pop bp

    add di, 3

limpiarRestos:
    cmp di, bp
    jg reemplazoExitoso
    mov buferInterfaz[di], ' '
    inc di
    jmp limpiarRestos

reemplazoExitoso:
    mov si, di
    dec si
    jmp siguienteCaracter

errorFormato:
    mov si, di
siguienteCaracter:
    inc si
    jmp buscarInicio

finProcesar:
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
procesarFormulas endp

; ==========================================
; Guardado
; ==========================================

guardarArchivo proc
    push ax
    push bx
    push cx
    push dx
    
    mov ah, 3Ch
    mov cx, 0
    lea dx, nombreArchivo
    int 21h
    jc finGuardado

    mov buferArchivo, ax
    mov ah, 40h
    mov bx, buferArchivo
    mov cx, 7296
    lea dx, buferInterfaz
    int 21h
    jc finGuardado
    
    mov ah, 3Eh
    mov bx, buferArchivo
    int 21h
    
finGuardado:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
guardarArchivo endp

; ==========================================
; Imprimir
; ==========================================

imprimirReg proc
    push dx
    push ax

    mov dx, bx
    mov ah, 9
    int 21h

    pop ax
    pop dx
    ret
imprimirReg endp

; ==========================================
; R2A
; ==========================================

regAAscii proc
    push ax
    push dx

    add bx, 2
    xor ax, ax
    mov al, dl
    mov dl, 10

    div dl
    add ah, 30h
    mov byte ptr [bx], ah

    xor ah, ah
    dec bx
    div dl
    add ah, 30h
    mov byte ptr [bx], ah

    xor ah, ah
    dec bx
    div dl
    add ah, 30h
    mov byte ptr [bx], ah

    pop dx
    pop ax
    ret
regAAscii endp

end