#!/bin/bash

#    ENCABEZADO
# NOMBRE DEL SCRIPT : buscarRepetidos.sh
# APL : 1
# EJERCICIO N° : 3
# INTEGRANTES : Axel Kenneth Hellberg 42296528,Tomas Victorio Serravento 42038102,Carolina Luana Huergo 42562990,Axel Joel Cascasi 42200104,Agustin Ratto 42673142
# ENTREGA : Primera Entrega    
# FECHA : 28/04/2021
#
#

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
    nombreArchivo=$(grep -o -P "(?<=\/).[^\/]*$" <<< "$path")
    ruta=$(grep -o -P ".*(?=\/)" <<< "$path")
    
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
        ;;
        -DirectorioSalida)
            directorioSalida="$valor"
        ;;
        -Umbral)
            umbral=$valor
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

#definicion variables
array=()
hayRepetidos=0

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
    resultado=$(IFS=$'\n'; echo "$(diff -qs --from-file=${array[*]})")
    iguales=$(grep -o -P "((?<=^Files ).*(?= and ))|(?<= and ).*(?= are identical$)" <<< "$resultado")

    if [ $? -eq 0 ]
    then
        hayRepetidos=1
        IFS=$'\n';for archivo in $(sort -r <<< "$iguales" | uniq)
        do
            guardarEnArchivo "$archivo" "$archivoSalida"
        done
        echo "" >> "$archivoSalida"
        mapfile -t array < <(grep -o -P "(?<= and ).*(?= differ$)" <<< "$resultado")
    else
        unset array[0]
        mapfile -t array < <(printf '%s\n' "${array[@]}")
        ((i--))
    fi
done
exit $hayRepetidos