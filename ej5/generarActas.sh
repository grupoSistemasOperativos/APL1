#!/bin/bash

#    ENCABEZADO
# NOMBRE DEL SCRIPT : generarActas.sh
# APL : 1
# EJERCICIO N° : 5
# INTEGRANTES : Axel Kenneth Hellberg 42296528,Tomas Victorio Serravento 42038102,Carolina Luana Huergo 42562990,Axel Joel Cascasi 42200104,Agustin Ratto 42673142
# ENTREGA : Primera Entrega    
# FECHA : 28/04/2021
#
#

mostrarAyuda()
{
    if [[ ($1 == "-h") || ($1 == "-help") || ($1 == "-?") ]]
    then
        echo "Uso: $0"
        echo ""
        echo "Argumentos:"
        echo ""
        echo "      --notas [DIR]"$'\t'"directorio en el que se encuentran los archivos CSV."
        echo "      --salida [FILE]"$'\t'"ruta del archivo JSON a generar (incluyendo su nombre)."
        exit 0
    fi
}

verificarParametros()
{

    if [[ "$1" != --notas || "$3" != --salida ]]
    then
        echo "El 1er o 3er parametro son incorrectos"
        exit
    fi

    if [[ ! -d "$2" ]]
    then
        echo "El directorio de los CSV no existe"
        exit 1
    fi

    extension=$(grep -o -P "(?<=\w\.)\w+" <<< "$4")
    ruta=$(grep -o -P "^.*(?=(\/))" <<< "$4")
    
    if [[ "$extension" != json || ! -d "$ruta" ]]
    then
        echo "Error en 2do parametro: La ruta no existe o el archivo no tiene extension .json"
        exit 1
    fi

    if [[ ! -w "$ruta" ]]
    then
        echo "La ruta "\"$ruta\"" no tiene permisos de escritura"
        exit 1
    fi

    if [[ ! -r "$2"  ]]
    then
        echo "La ruta" "\"$2\"" "no tiene permiso de lectura"
        exit 1
    fi

    if [[ $# > 4 ]]
    then 
        echo "Cantidad de parametros incorrecta"
    fi
}
mostrarAyuda "$1"

verificarParametros "$1" "$2" "$3" "$4" 

directorioSalida="$4"

> temp.txt
declare array
IFS=$'\n';for archivoCsv in $(find "$2" -type f)
do
    codMateria=$(grep -o -P "[0-9]+(?=_)(?=_[0-9]+.[0-9A-Za-z]+)" <<< "$archivoCsv")
    awk -v codMateria=$codMateria -f obtenerNotas.awk "$archivoCsv" >> temp.txt
done

mapfile -t registros < <(sort -u --key=1,2 < temp.txt)

> temp.txt
for(( i = 0,j = 0; i < ${#registros[@]};))
{
    echo -n "${registros[$i]}" >> temp.txt
    dniPri=$(cut -d ' ' -f 1 <<< "${registros[$i]}")
    ((i++))
    dni=$(cut -d ' ' -f 1 <<< "${registros[$i]}")
    while [[ $dniPri == $dni && $i < ${#registros[@]} ]];
    do
        ((j++))        
        echo -n " $(cut -d ' ' -f 2,3 <<< "${registros[$i]}")" >> temp.txt
        ((i++))
        dni=$(cut -d ' ' -f 1 <<< "${registros[$i]}")
    done
    echo "" >> temp.txt
    ((j++))
}

awk -v cantReg=$(wc -l < temp.txt) -f escribirActas.awk temp.txt > "$directorioSalida"
rm temp.txt
exit 0