BEGIN{
    printf("{\n\t\"actas\": [\n")
}

{
    printf("\t\t{\n\t\t\t\"dni\": \"%s\",\n",$1)
    printf("\t\t\t\"notas\": [\n")
    for(i = 2; i+1 <= NF; i++)
    {
        printf("\t\t\t\t{\n\t\t\t\t\t\"materia\": %d,\n",$i)
        i++
        printf("\t\t\t\t\t\"nota\": %.2f\n",$i)
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
    printf("\t]\n}")
}