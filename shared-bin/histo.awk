#!/usr/bin/awk -f

BEGIN{
    if (!width) width=10000
}
{
    bin=int($1/width)-1;
    hist[bin]++
}
END{
    for (h in hist)
        printf "%2.2f\t%i \n", h*width, hist[h]
}
   
