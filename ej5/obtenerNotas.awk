BEGIN{
    FS = ","
}

function calcularNota()
{
    total = 0;
    for(i = 1; i <= NF; i++)
    {
        if($i == "b")
        {
            total += 1
        }
        else if($i == "r")
            {
                total += 0.5        
            }   
    }
    return (total ? total*10 / (NF-1): 1)
}

{
    printf("%s",$1)
    printf(" %d",codMateria);
    nota = calcularNota()

    printf(" %.2f\n",nota)
}

END{
}