#include <cs50.h>
#include <ctype.h>
#include <math.h>
#include <string.h>
#include <stdio.h>

int main(void)
{

    // Program Directions
    printf("Write a sentance to grade your writing!\n");

    // Prompt User
    string text = get_string("Text: ");

    // String Length
    int i = strlen(text);
    int letters = 0;
    int words = 0;
    int sentences = 0;

    // Counting Loops
    for (int x = 0; x < i; x++)
    {


        // Counting Letters
        char c = text[x];

        if (isalpha(c) != 0)
        {
            letters++;
        }

        // Counting Words
        if (c == ' ')
        {
            words++;
        }

        // Counting Sentences
        if (c == '!' || c == '?' || c == '.')
        {
            sentences++;
        }

    }

    // Last word addition
    words++;

    // Calculate
    float l = ((float)letters / (float)words) * 100;
    float s = ((float)sentences / (float)words) * 100;
    float subindex = 0.0588 * l - 0.296 * s - 15.8;
    int index = round(subindex);

    if (index > 16)
    {
        printf("Grade 16+\n");
    }
    else if (index < 1)
    {
        printf("Before Grade 1\n");
    }
    else
    {
        printf("Grade %i\n", index);
    }

}