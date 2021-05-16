#!/bin/bash

#    ENCABEZADO
# NOMBRE DEL SCRIPT : demonio.sh
# APL : 1
# EJERCICIO N° : 4
# INTEGRANTES : Axel Kenneth Hellberg 42296528,Tomas Victorio Serravento 42038102,Carolina Luana Huergo 42562990,Axel Joel Cascasi 42200104,Agustin Ratto 42673142
# ENTREGA : Primera Entrega    
# FECHA : 28/04/2021

mostrarAyuda()
{
    if [[ ($1 == "-h") || ($1 == "-help") || ($1 == "-?") ]]
    then
        echo "Uso: $0"
        echo ""
        echo "Argumentos:"
        echo ""
        echo "      -d [DIR]"$'\t'"indica el directorio a monitorear."
        echo "      -o [DIR](opcional)"$'\t'"indica el directorio que contendrá los subdirectorios extensión."
        echo "      -s"$'\t'"Detiene al demonio. No se pasar con los demas parametros."
        exit 0
    fi
}

frenarDemonio()
{
    if [[ $1 == -s ]]
    then
        pid=$(cat .revisarCarpeta.pid 2> /dev/null) 
        
        if [ $? -ne 0 ]
        then
            echo "El demonio no se esta ejecutando"
            exit
        fi
        kill -s SIGTERM $pid
        rm .revisarCarpeta.pid
        
        echo "Finalizando demonio con pid $pid" 
        exit
    fi
}

validarParametros()
{
    if [[ "$1" != -d  ]]
    then
        echo "parametro "\"$1\"" incorrecto, verifique el help para indicaciones sobre los parametros"
        exit
    fi
    
    if [[ $# > 3 && "$3" != -o  ]]
    then
        echo "parametro "\"$3\"" incorrecto, verifique el help para indicaciones sobre los parametros"
        exit
    fi
    
    if [ ! -d "$2" ]
    then
        echo "el 2do parametro debe ser un directorio y que exista"
        exit
    fi
    
    if [[ ! -w "$2" ]]
    then
        echo "El directorio "\"$2\"" no tiene permisos de escritura."
        exit
    fi
    
    if [[ -d "$4" && ! -w "$4" ]]
    then
        echo "El directorio "\"$4\"" no tiene permisos de escritura"
    fi
    

    if [[ $# > 4 && $5 == -s ]]
    then
        echo "el parametro -s no se debe pasarse con los demas parametros"
        exit
    fi

    if [[ $# > 4 ]]
    then
        echo "Error, se estan pasando mas parametros de los permitidos"
        exit
    fi

    if [[ ! -d "$4" && "$4" != " " ]]
    then
        echo "el parametro 4 debe ser un directorio y que exista"
        exit
    fi
}

##inicio de ejecucion de demonio
mostrarAyuda $1

frenarDemonio $1

validarParametros $1 "$2" $3 "$4" $5 $6

if [ -f .revisarCarpeta.pid ]
then
    echo "Ya está en ejecucion el demonio. Puede frenarlo con el argumento -s"
    exit 1
fi

dirDestino="$4"
if [ $# -le 3 ]
then
    dirDestino=$(xdg-user-dir DOWNLOAD)
fi

dirOrigen="$2"

./.ej4.sh "$dirDestino" "$dirOrigen" &
echo $! > .revisarCarpeta.pid
exit

##fin ejecucion

