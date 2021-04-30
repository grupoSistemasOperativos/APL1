#!/bin/bash

moverArchivos()
{
    dirDestino="$1"
    dirOrigen="$2"
    IFS=$'\n';for archivo in $(find "${dirOrigen}" -type f)
    do  
        extension=$(grep -o -P "(?<=\w\.)\w+" <<< "$archivo")

        extension=${extension^^}
        mkdir "$dirDestino"/$extension 2> /dev/null
        mv --backup=numbered "$archivo" "${dirDestino}/$extension"
    done
}

while [ 1 -eq 1 ]
do  
    sleep 1
    moverArchivos "$1" "$2"
done

exit 0

