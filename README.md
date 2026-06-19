# 🧮 Hoja de Cálculo MS-DOS (Ensamblador 8086)

Un programa desarrollado en Ensamblador 8086 (16 bits) que emula las funcionalidades básicas de una hoja de cálculo para el sistema operativo MS-DOS. Permite la navegación por cuadrícula, edición de celdas, persistencia de datos en disco y cálculo de múltiples fórmulas matemáticas.

## 🚀 Características Principales

* **Cuadrícula Extendida:** Soporta una grilla total de 14 columnas por 48 filas, dividida en 4 "páginas" (matriz de 2x2) que se actualizan automáticamente al mover el cursor hacia los bordes.


* **Control Dual:** Permite la navegación de celda en celda utilizando las flechas de dirección del teclado. También incluye soporte para la interrupción `33h` del ratón, lo que permite seleccionar celdas directamente con un clic.


* **Edición en Tiempo Real:** Permite escribir caracteres en las celdas con un límite seguro de 9 letras por celda. También soporta el borrado carácter por carácter mediante la tecla de retroceso (Backspace).


* **Persistencia de Datos:** Guarda y carga automáticamente el estado de la hoja en un archivo local llamado `grilla.txt`.


* **Motor de Fórmulas Avanzado:** Al presionar la tecla de salida, el programa escanea la grilla para procesar automáticamente fórmulas escritas. Actualmente soporta las operaciones matemáticas `SUM(X,Y)`, `RES(X,Y)`, `MUL(X,Y)` y `MAX(X,Y)`. Exclusivamente, la función `MAX(X,Y)` es capaz de analizar y comparar tanto números enteros como caracteres ASCII.


* **Cierre Controlado:** Al finalizar y guardar el programa, este limpia la pantalla de MS-DOS e imprime en consola el mensaje "Salida de programa exitosa".



## 🛠️ Requisitos del Sistema y Dependencias (TSR)

Para compilar y ejecutar este programa en su totalidad, incluyendo las operaciones matemáticas, se necesitan los siguientes componentes:

* **Manejador de Ratón:** El entorno (MS-DOS nativo o DOSBox) debe tener un controlador de ratón activo para que la selección gráfica funcione.


* **Programa Residente (TSR):** La operación de suma (`SUM(X,Y)`) delega su procesamiento a un programa Terminate and Stay Resident (TSR) personalizado. Este TSR captura e instala una rutina de servicio de interrupción (ISR) en el vector `60h` utilizando la interrupción de MS-DOS `21h`.


* **Lógica del TSR:** Una vez cargada en la memoria, la rutina interceptada se encarga de sumar directamente el valor del registro AX al registro BX.


* **Compilación del TSR:** El código del programa residente usa la directiva de modelo `tiny` para crear un archivo `.COM`. Para compilarlo e instalarlo, deben ejecutarse los comandos `tasm tsr2.asm` seguido de `tlink /t tsr2.obj` en la terminal antes de abrir la hoja de cálculo.



## 🎮 Controles

* **Flechas de dirección:** Desplazan el cursor hacia Arriba, Abajo, Izquierda o Derecha en la grilla.


* **Clic Izquierdo:** Posiciona instantáneamente el cursor en una celda visible en pantalla.


* **Teclado alfanumérico:** Ingresa caracteres de texto o números dentro de la celda seleccionada.


* **`Backspace` (Código ASCII 8):** Borra el último carácter introducido en la celda activa.


* **`ESC` (Código ASCII 27):** Invoca el procesamiento de todas las fórmulas, guarda los datos en el archivo de texto y finaliza el programa cerrando el proceso.



## 📂 Arquitectura Interna del Código

* **Módulo Principal:** Se encarga de inicializar los segmentos de datos (`@data`), invocar la carga inicial, dibujar la interfaz de usuario por primera vez y gestionar el bucle infinito que escucha los eventos del teclado y el ratón.


* **Librería de Funciones:** Alberga la lógica fuerte de escritura directa en la memoria de video VGA (`0B800h`), la manipulación de archivos (`int 21h`), el formateo de cadenas numéricas hacia código ASCII y la lógica de análisis (parsing) que reemplaza las fórmulas por sus resultados.


* **Módulo TSR (`int.asm`):** Contiene el script instalador que reescribe el vector de interrupciones llamando a `2560h` y finalmente deja el segmento de la subrutina de suma protegido en la memoria mediante la función `3100h` de MS-DOS.
