#!/bin/bash
#TODO falta carpetas con espacio
mostrarAyuda()
{
    if [[ ($1 == "-h") || ($1 == "-help") || ($1 == "-?") ]]
    then
        echo "Uso: $0 -Directorio [DIR] -DirectorioSalida [DIR] -Umbral [KB]"
        echo ""
        echo "Argumentos obligatorios:"
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
mostrarAyuda $1

#definicion variables
array=()
umbral=$2
directorio=$1
directorioSalida=$3
hayRepetidos=0

#verificar que si es dir relativo, lo pase absoluto
grep "^/" <<< "$directorio"
if [ $? -eq 1 ]
then
    directorio=$(echo $PWD/$directorio)
fi

#creacion array con todos los archivos dentro de $directorio
mapfile -t array < <( find $directorio -type f -size +${umbral}k )

#echo "${#array[@]}"
salidaArchivo=$(echo $directorioSalida$(echo "Resultado_[$(date +%Y%m%d%H%m)].log"))
#echo $salidaArchivo
> $salidaArchivo
#exit
#mkdir $PWD/carpeta_abierta archivo.log 2> /dev/null
while [[ ${#array[@]} > 1 ]]
do
    resultado="$(echo "$(diff -qs --from-file=${array[*]})")"
    echo "$resultado"
    echo ""
    #echo "contador: $i"
    iguales=$(grep -e 'are identical' <<< "$resultado" )
    #echo "$i $?"
    if [ $? -eq 0 ]
    then
        hayRepetidos=1
        #echo $resultado
        #iguales=$(cut -d ' ' -f 2,4 <<< $iguales)
        #echo "$iguales"
        primero=$(cut -d ' ' -f 2 <<< $iguales | head -1)
        #echo "1 $primero"
        ruta=$(grep -o -E "(\w+\/)" <<< $primero | tr -d '\n')    

        nombreArchivo=$(grep -o -E "\w+\.\w+" <<< $primero)
        #echo "3 $ruta"
        echo "$nombreArchivo    $ruta" >> $salidaArchivo

        for repetido in $(cut -d ' ' -f 4 <<< $iguales)
        do
            ruta=$(grep -o -E "(\w+\/)" <<< $repetido | tr -d '\n')
            nombreArchivo=$(grep -o -E "\w+\.\w+" <<< $repetido)
            echo "$nombreArchivo    $ruta" >> $salidaArchivo

            #exit 1
        done
        echo "" >> $salidaArchivo
        mapfile -t array < <(grep -e 'differ' <<< "$resultado" | cut -d ' ' -f 4)
        #i=-1
        echo "OK"
        #echo "array ${#array[@]} "
        #exit 0
    else
        #echo "${#array[@]} $i"
        echo "eliminado ${array[0]} porque es distinto"
        echo ""
        unset array[0]
        mapfile -t array < <(printf '%s\n' "${array[@]}")
        #echo ${#array[@]}
        #exit
        #if [ $i -gt 0 ]
        #then
            ((i--))
        #fi
        #echo $i
    fi
    #resultado="$(diff -qs --from-file=${array[*]} )"
    #echo "$iguales"
done
exit $hayRepetidos