# 🧮 Hoja de Cálculo MS-DOS (Ensamblador 8086)

Un programa desarrollado en Ensamblador 8086 (16 bits) que emula las funcionalidades básicas de una hoja de cálculo para el sistema operativo MS-DOS. Permite la navegación por cuadrícula, edición de celdas, persistencia de datos en disco y cálculo de fórmulas matemáticas personalizadas.

## 🚀 Características Principales

* **Cuadrícula Extendida con Paginación:** Soporta una grilla total de 14 columnas por 48 filas. Dado que sobrepasa los límites de la pantalla estándar de texto de MS-DOS (80x25), incluye un motor de cámara que divide el área de trabajo en 4 "páginas" (matriz de 2x2) que se actualizan automáticamente al llegar a los bordes.
* **Control Dual (Teclado y Ratón):** * Navegación fluida de celda en celda utilizando las flechas del teclado.
* Soporte completo para API de ratón (interrupción `33h`) para seleccionar celdas haciendo clic directamente en la pantalla.


* **Edición en Tiempo Real:** Permite escribir y borrar (Backspace) texto directamente sobre las celdas, con un límite seguro de 9 caracteres por celda para evitar desbordamientos visuales.
* **Persistencia de Datos:** Guarda y carga automáticamente el progreso en un archivo local llamado `grilla.txt` (formateado correctamente con saltos de línea y separadores).
* **Procesamiento de Fórmulas:** Cuenta con un motor de parsing que busca funciones como `SUMA(X,Y)` en la grilla, delegando la operación matemática a una interrupción de software personalizada (`int 60h`).

## 🛠️ Requisitos del Sistema

Para compilar y ejecutar este programa, necesitarás:

* **Entorno MS-DOS:** Un sistema MS-DOS nativo o un emulador como **DOSBox**.
* **Ensamblador:** Compatible con TASM (Turbo Assembler) o MASM, utilizando el modelo de memoria `small`.
* **Manejador de Ratón:** El entorno debe tener un controlador de ratón cargado (ej. `mouse.com` en DOS puro) para que la `int 33h` funcione.
* **Dependencia de Fórmulas:** El cálculo de la instrucción `SUMA` depende de un programa residente en memoria (TSR) configurado en la **interrupción `60h**`. Si este TSR no está cargado previamente en tu entorno, las fórmulas no se resolverán (o el programa podría fallar al llamar a un vector de interrupción vacío).

## 🎮 Controles

| Acción | Tecla / Entrada |
| --- | --- |
| **Mover Cursor** | Flechas de dirección (Arriba, Abajo, Izq, Der) |
| **Selección Rápida** | Clic Izquierdo del Ratón |
| **Escribir en Celda** | Teclas alfanuméricas |
| **Borrar Texto** | `Backspace` (Retroceso) |
| **Guardar y Salir** | `ESC` |

## 📂 Estructura Principal del Código (`libs.asm`)

El programa maneja su memoria y video de manera directa para maximizar el rendimiento en arquitecturas antiguas:

* **Buffer de Datos (`gridBuffer`):** Un bloque preasignado de 7296 bytes que mantiene el estado exacto de toda la cuadrícula en memoria, incluyendo separadores verticales (`|`) y retornos de carro para una escritura directa a archivo.
* **Acceso Directo a Video (VGA):** El motor gráfico dibuja la interfaz inyectando caracteres y atributos de color (gris sobre negro) directamente en el segmento de memoria de video de texto (`0B800h`).
* **Manejo de Archivos:** Usa las interrupciones estándar de DOS (`int 21h`) para manipular `grilla.txt` de manera transparente al inicio (Carga) y al presionar la tecla de salida (Guardado).

## ⚠️ Notas de Desarrollo

* El ejecutable principal debe declarar e importar estas funciones (`public`) e implementar el ciclo de eventos (Event Loop) principal que lea el teclado (`int 16h`) e invoque las rutinas expuestas en esta librería.
* Si se compila sin el archivo `grilla.txt` existente en el mismo directorio, la función `cargarArchivo` omitirá el paso sin fallar, permitiendo iniciar desde cero con una cuadrícula en blanco generada por `inicializarBuffer`.
