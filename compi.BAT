keyb sp
tasm int.asm
tlink /t int.obj
int.com
tasm /zi main
tasm /zi libs
tlink /v main libs
main