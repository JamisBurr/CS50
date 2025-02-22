#include <ctype.h>
#include <cs50.h>
#include <stdio.h>
#include <string.h>

// Points assigned to each letter of the alphabet
int POINTS[] = {1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10};

int compute_score(string word);

int main(void)
{

    string word[2];
    // Get input words from both players
    word[0] = get_string("Player 1: ");
    word[1] = get_string("Player 2: ");

    // Score both words
    int score1 = compute_score(word[0]);
    int score2 = compute_score(word[1]);

    // Print the winner
    if (score1 > score2)
    {
        printf("Player 1 wins!\n");
    }
    if (score2 > score1)
    {
        printf("Player 2 wins!\n");
    }
    else if (score1 == score2)
    {
        printf("Tie!\n");
    }

}

int compute_score(string word)
{
    int score = 0;

    // Compute and return score for string
    for (int i = 0; i < strlen(word); i++)
    {
        if (islower(word[i]))
        {
            score += POINTS[word[i] - 'a'];
        }
        else if (isupper(word[i]))
        {
            score += POINTS[word[i] - 'A'];
        }
    }
    return score;
}
