BEGIN{
    if(cantReg == 0)
    {
        exit 1
    }
    printf("{\n\t\"actas\": [\n")
}

{
    printf("\t\t{\n\t\t\t\"dni\": \"%s\",\n",$1)
    printf("\t\t\t\"notas\": [\n")
    for(i = 2; i+1 <= NF; i++)
    {
        printf("\t\t\t\t{\n\t\t\t\t\t\"materia\": %d,\n",$i)
        i++
        printf("\t\t\t\t\t\"nota\": %d\n",$i)
        if(i == NF)
            printf("\t\t\t\t}\n")
        else
            printf("\t\t\t\t},\n")
    }
    if(NR == cantReg)
        printf("\t\t\t]\n\t\t}\n")
    else
        printf("\t\t\t]\n\t\t},\n")
}
END{
    if(cantReg == 0)
    {
        printf("Archivos vacios")
        exit 1
    }
    printf("\t]\n}")
}