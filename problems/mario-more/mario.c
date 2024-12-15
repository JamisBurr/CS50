#include <cs50.h>
#include <stdio.h>

int main(void)
{
    int height;

    //Only accept values of 1-8
    do
    {
        height = get_int("Pyramid Height: ");
    }

    while (height > 8 || height < 1);

    for (int i = 0; i < height; i++)
    {

        int spaces = height - (i + 1);

        //Loop to print spaces
        for (int j = 0; j < spaces; j++)
        {
            printf(" ");
        }

        int hashes = i + 1;

        //Loop to print 1st half of hashes
        for (int x = 0; x < hashes; x++)
        {
            printf("#");
        }

        //Print Pit/Gap
        printf("  ");

        //Loop to print 2nd half of hashes
        for (int a = 0; a < hashes; a++)
        {
            printf("#");
        }

        //New line
        printf("\n");
    }

}