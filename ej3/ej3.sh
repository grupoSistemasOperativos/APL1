#!/bin/bash
#TODO falta carpetas con espacio
mostrarAyuda()
{
    if [[ ($1 == "-h") || ($1 == "-help") || ($1 == "-?") ]]
    then
        echo "Uso: $0 -Directorio [DIR] -DirectorioSalida [DIR] -Umbral [KB]"
        echo ""
        echo "Argumentos obligatorios (se pueden enviar en cualquier orden):"
        echo ""
        echo "      -Directorio         [DIR]       indica directorio donde buscar repetidos"
        echo "      -DirectorioSalida   [DIR]       indica directorio donde se va a escribir archivo de texto indicando repetidos (debe ser distinto a -Directorio)"
        echo "      -Umbral             [KB]        indica tamaño en kilobytes a partir del cual se los empieza a evaluar"
        echo "Estados Exit:"
        echo "-1 (error) si los directorios indicados fueron el mismo"
        echo "0 si no hubo archivos repetidos"
        echo "1 si hubo archivos repetidos"
        exit 0      
    fi
}

guardarEnArchivo ()
{
    path="$1"
    ruta=$(grep -o -E "(\w+\/)" <<< "$path" | tr -d '\n')    
    nombreArchivo=$(grep -o -E "\w+\.\w+" <<< $path)
    
    echo "$nombreArchivo        $ruta" >> $2
}

validarParametros()
{    
    if [ ! -d "$1" ]
    then
        echo "El directorio $1 no existe"
        exit 1
    fi
    
    if [ ! -d "$2" ]
    then
        echo "El directorio $2 no existe"
        exit 1
    fi

    if [ $3 -lt 0 ]
    then
        echo "especifique cantidad de KB mayor que 0"
        exit 1
    fi

    if [ "$1" = "$2"  ]
    then
        echo "Los directorios ingresados deben ser distintos"
        exit -1
    fi
}

asignarParametros() 
{
    if [[ $# < 6 ]]
    then 
        echo "Cantidad incorrecta de parametros"
        exit 1;
    fi

    i=1;
    while [[ $i < 6 ]]  
    do
        variable="${!i}"
        ((i++));
        valor="${!i}"
        case $variable in
        -Directorio) 
            directorio="$valor"
            #echo $variable - $valor
        ;;
        -DirectorioSalida)
            directorioSalida="$valor"
            #echo $variable - $valor
        ;;
        -Umbral)
            umbral=$valor
            #echo $variable - $valor
        ;;
        *)
            echo "Error, el nombre del parámetro no coincide con los requeridos. $variable $valor"
            exit 1
        ;;
        esac
        ((i++));
    done
}

mostrarAyuda $1
asignarParametros "$1" "$2" "$3" "$4" "$5" "$6"
validarParametros "$directorio" "$directorioSalida" "$umbral"
#echo listo
#exit

#definicion variables
array=()
hayRepetidos=0
#umbral=$2
#directorio=$1
#directorioSalida=$3
#verificar que si es dir relativo, lo pase absoluto (para ver path absoluto siempre en salida)
grep "^/" <<< "$directorio" >> /dev/null
if [ $? -eq 1 ]
then
    directorio=$(echo $PWD/$directorio)
fi
grep "^\." <<< "$directorioSalida" >> /dev/null
if [ $? -eq 0 ]
then
    unset directorioSalida
fi
#creacion de array con todos los archivos dentro de $directorio
mapfile -t array < <(echo "$(find $directorio -type f -size +${umbral}k)")
archivoSalida="$directorioSalida/"$(echo "Resultado_[$(date +%Y%m%d%H%m)].log")
#creacion de archivo en $directorioSalida
> $archivoSalida

while [[ ${#array[@]} > 1 ]]
do
    #IFS=$'\n'; echo "${array[*]}"
    #exit
    resultado=$(IFS=$'\n'; echo "$(diff -qs --from-file=${array[*]})")
    echo $resultado
    #echo $resultado
    #exit
    iguales=$(grep -e 'are identical' <<< "$resultado" )
    #echo $iguales
    if [ $? -eq 0 ]
    then
        hayRepetidos=1
        #primero=$(cut -d ' ' -f 2 <<< "$iguales" | uniq)
        #TODO encontrar regex que niege esto
        archivos=$(grep -o -P "[A-Za-z0-9 ]+\.\w+" <<< "$iguales")
        primero=$(head -1 <<< "$archivos")
        #echo "$primero"
        #primero=$(grep -o -v " are identical[ ]*| and " <<< "$iguales")
        #echo dada
        archivos=$(grep -v "$primero" <<< "$archivos")
        
        echo $(realpath "$archivos")
        exit
        guardarEnArchivo "$primero" "$archivoSalida"

        for repetido in $(cut -d ' ' -f 4 <<< "$iguales")
        do
            #echo $repetido
            guardarEnArchivo "$repetido" "$archivoSalida"
        done
        echo "" >> "$archivoSalida"
        mapfile -t array < <(grep -e 'differ' <<< "$resultado" | cut -d ' ' -f 4)
    else
        unset array[0]
        mapfile -t array < <(printf '%s\n' "${array[@]}")
        ((i--))
    fi
done
exit $hayRepetidos