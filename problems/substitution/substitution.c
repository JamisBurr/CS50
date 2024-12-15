#include <cs50.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
bool is_valid_key(string s);



int main(int argc, string argv[])

{
    if (argc != 2)
    {
        printf("Command: ./substitution key\n");
        return 1;

    }

    if (!is_valid_key(argv[1]))
    {
        printf("Your key must contain 26 characters.\n");
        return 1;
    }

    string s = get_string("plaintext: ");
    string diff = argv [1];

    for (int i = 'A'; i <= 'Z'; i++)
    {
        // Letter - Letter ('T' - 'A')
        diff[i - 'A'] = toupper(diff[i - 'A']) - i;
    }

    printf("ciphertext: ");

    for (int i = 0, len = strlen(s); i < len; i++)
    {
        if (isalpha(s[i]))
        {
            s[i] = s[i] + diff[s[i] - (isupper(s[i]) ? 'A' : 'a')];
        }

        printf("%c", s[i]);
    }

    printf("\n");
}


bool is_valid_key(string s)
{
    int len = strlen(s);

    if (len != 26)
    {
        return false;
    }

    int freq [26] = { 0 };

    for (int i = 0; i < len; i++)
    {
        if (!isalpha(s[i]))
        {
            return false;
        }

        int index = toupper(s[i]) - 'A';

        if (freq[index] > 0)
        {
            return false;
        }

        freq[index]++;

    }
    return true;
}