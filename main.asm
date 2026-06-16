.8086 
.model small
.stack 100h

.data

mensajeSalida db 'Salida de programa exitosa',0dh,0ah,'$'

.code

extrn inicializarBufer:proc
extrn cargarArchivo:proc
extrn dibujarInterfaz:proc
extrn actualizarCursor:proc
extrn procesarRaton:proc
extrn escribirCaracter:proc
extrn borrarCaracter:proc
extrn manejarFlechas:proc
extrn guardarArchivo:proc
extrn limpiarPantalla:proc
extrn procesarFormulas:proc
extrn imprimirReg:proc

main proc
    mov ax, @data
    mov ds, ax
    mov es, ax

    call inicializarBufer
    call cargarArchivo
    call limpiarPantalla            
    call dibujarInterfaz

; Inicializar mouse
    mov ax, 0000h
    int 33h
    mov ax, 0001h
    int 33h
    call actualizarCursor

cicloPrincipal:
    mov ax, 0003h
    int 33h
    test bx, 1              
    jnz clicRaton
    
    mov ah, 01h
    int 16h
    jnz leerTecla
    jmp cicloPrincipal

clicRaton:
    call procesarRaton
    jmp cicloPrincipal

leerTecla:
    mov ah, 00h             
    int 16h
    
    cmp al, 27
    je salirPrograma
    cmp al, 8
    je borrarTeclado
    cmp al, 0
    je esFlecha
    cmp al, 0E0h
    je esFlecha
    
    cmp al, 32
    jl cicloPrincipal
    
    call escribirCaracter
    jmp cicloPrincipal

esFlecha:
    call manejarFlechas
    jmp cicloPrincipal

borrarTeclado:
    call borrarCaracter
    jmp cicloPrincipal

salirPrograma:
    mov ax, 0002h
    int 33h
    
    call procesarFormulas
    call guardarArchivo
    call limpiarPantalla

    lea bx, mensajeSalida
    call imprimirReg          
    
    mov ax, 4C00h
    int 21h
main endp
end main