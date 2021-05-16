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
        echo "\"$1\" no es una opcion valida o es un archivo inexistente"
        exit 1
    fi

    if [[ -f "$1" && "$2" != "" ]]
    then
        echo "Error, si busca eliminar un archivo, debe enviar como parametro solo [FILE]"
        exit
    fi

    if [[ "$1" == -l && "$2" != "" ]]
    then
        echo "Error, el parametro \"-l\" debe ser enviado solo"
        exit
    fi

    if [[ "$1" == -r && "$2" == "" ]]
    then
        echo "Error, el parametro \"-r\" debe estar acompañado de un nombre de archivo"
        exit
    fi

    if [[ "$1" == -e && "$2" != "" ]]
    then
        echo "Error, el parametro \"-e\" debe ser enviado solo"
        exit
    fi
}

if [[ $# > 2 ]]
then
    echo "Error, como maximo se pueden pasar 2 parametros."
    echo "Indique -h para obtener mas informacion sobre los parametros"
    exit 1
fi

mostrarAyuda "$1"

verificarParametros "$1" "$2"

directorio=$HOME/Papelera.zip

find directorio 2> /dev/null

if [[ -f "$1" ]]
then
    zip -m $HOME/Papelera.zip "$(realpath "$1")" $> /dev/null
    if [[ $? -eq 0 ]]
    then
        echo "$1"" eliminado con exito" 
    else
        echo "Error al eliminar archivo"
    fi
fi

if [[ "$1" == -r ]]
then
    archivo=$(unzip -Z1 $HOME/Papelera.zip | grep "$2")

    if [[ $? == 1 ]]
    then
        echo "Error, el archivo \"$2\" no existe en la papelera"
        exit 1
    fi

    repetidos=$(echo $(wc -l <<< "$archivo"))
    if [[ $repetidos > 1 ]]
    then
        mapfile -t archivos < <(grep -o -P "(?<=\/)+.[^\/]*$" <<< "$archivo")
        mapfile -t rutas < <(grep -o -P "^.*(?=(\/))" <<< "$archivo")
        for ((i = 0; i < $repetidos; i++))
        do
            echo $((i+1)) - "${archivos[$i]}" $'\t\t' ${rutas[$i]}
        done
        echo "¿Qué archivo desea recuperar?:"
        read seleccion
        if [[ $seleccion > $i ]]
        then
            echo "Opcion invalida"
            exit 1
        fi
        archivo="${rutas[((seleccion-1))]}"/"${archivos[((seleccion-1))]}"
    fi

    dir=${archivo%/*}
    if [ ! -w /"$dir" ]
    then
        echo "Error, la carpeta donde el archivo existia no tiene mas acceso de escritura."
        exit 1
    fi
    
    unzip -p $HOME/Papelera.zip "$archivo" > /"$archivo" &> /dev/null
    zip -d $HOME/Papelera.zip "$archivo" &> /dev/null
    if [[ $? -eq 0 ]]
    then
        echo "$archivo"" recuperado con exito" 
    else
        echo "Error al recuperar archivo"
    fi
fi

if [[ "$1" == -e ]]
then
    zip -d $HOME/Papelera.zip "*" &> /dev/null
    echo "papelera vaciada"
fi

if [[ "$1" == -l ]]
then
    archivo=$(unzip -Z1 $HOME/Papelera.zip)
    mapfile -t archivos < <(grep -o -P "(?<=\/)+.[^\/]*$" <<< "$archivo")
    mapfile -t rutas < <(grep -o -P "^.*(?=(\/))" <<< "$archivo")

    for ((i = 0; i < ${#archivos[@]}; i++))
    do
        echo ${archivos[$i]} $'\t\t' ${rutas[$i]}
    done

    if [[ ${#archivos[@]} -eq 0 ]]
    then
        echo "papelera vacia"
    fi
fi