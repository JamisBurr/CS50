#include <cs50.h>
#include <stdio.h>

int main(void)
{
    //Get answer to "What's your name? "
    string answer = get_string("What's your name? ");

    //Print
    printf("Hello, %s\n", answer);
}