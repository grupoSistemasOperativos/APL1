#!/bin/bash

mostrarAyuda()
{
    if [[ ($1 == "-h") || ($1 == "-help") || ($1 == "-?") ]]
    then
        echo "Uso: $0"
        echo ""
        echo "Argumentos:"
        echo ""
        echo "      -[FILE]"$'\t'"elimina el archivo llevandolo a la papelera de reciclaje."
        echo "      -l"$'\t'"lista los archivos contenidos en la papelera de reciclaje."
        echo "      -r [FILE]"$'\t'"recupera el archivo."
        echo "      -e"$'\t'"vacia la papelera de reciclaje."
        exit 0
    fi
}

verificarParametros()
{
    if [[ -f "$1" && ! -w "$1" ]]
    then
        echo "No se puede acceder al archivo" "$1. Permiso denegado."
        exit
    fi   
    if [[ "$1" != -l && "$1" != -r && "$1" != -e && ! -f "$1" ]]
    then
        echo "Error de parametros"
        exit 1
    fi
}

mostrarAyuda "$1"

verificarParametros "$1" "$2"

directorio=$HOME/Papelera.zip

find directorio 2> /dev/null

if [[ -f "$1" ]]
then
    zip -m $HOME/Papelera.zip "$(realpath "$1")"
fi

if [[ "$1" == -r ]]
then
    archivo=$(unzip -Z1 $HOME/Papelera.zip | grep "$2")
    repetidos=$(echo $(wc -l <<< "$archivo"))
    if [[ $repetidos > 1 ]]
    then
        mapfile -t archivos < <(grep -o -P "\w+\.\w+" <<< "$archivo")
        mapfile -t rutas < <(grep -o -P "^.*(?=(\/))" <<< "$archivo")
        for ((i = 0; i < $repetidos; i++))
        do
            echo $((i+1)) - ${archivos[$i]} $'\t\t' ${rutas[$i]}
        done
        echo "¿Qué archivo desea recuperar?:"
        read seleccion
        archivo="${rutas[((seleccion-1))]}"/"${archivos[((seleccion-1))]}"
    fi

    dir=${archivo%/*}
    if [ ! -w /"$dir" ]
    then
        echo "Error, la carpeta donde el archivo existia no tiene mas acceso de escritura."
        exit 1
    fi
    
    unzip -p $HOME/Papelera.zip "$archivo" > /"$archivo"
    zip -d $HOME/Papelera.zip "$archivo"
fi

if [[ "$1" == -e ]]
then
    zip -d $HOME/Papelera.zip "*"
fi

if [[ "$1" == -l ]]
then
    archivo=$(unzip -Z1 $HOME/Papelera.zip)
    cantE=$(echo $(wc -l <<< "$archivo"))
    mapfile -t archivos < <(grep -o -P "\w+\.\w+" <<< "$archivo")
    mapfile -t rutas < <(grep -o -P "^.*(?=(\/))" <<< "$archivo")

    for ((i = 0; i < $cantE; i++))
    do
        echo ${archivos[$i]} $'\t\t' ${rutas[$i]}
    done
fi