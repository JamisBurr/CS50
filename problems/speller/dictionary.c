// Implements a dictionary's functionality

#include <ctype.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <strings.h>

#include "dictionary.h"

// Represents a node in a hash table
typedef struct node
{
    char word[LENGTH + 1];
    struct node *next;
}
node;

// TODO

// Choose number of containers
const unsigned int N = 10000;

// Initialize positive hash value
unsigned int h_value;

// Initialize hash table word count
unsigned int w_count;

// Hash table
node *table[N];

// Returns true if word is in dictionary, else false
bool check(const char *word)
{
    // TODO: Hash word to get hash value
    h_value = hash(word);

    // Access to hash table
    node *cursor = table[h_value];

    // Linked List
    while (cursor != NULL)
    {
        // Check for matching word
        if (strcasecmp(word, cursor -> word) == 0)
        {
            return true;
        }

        // Move cursor
        cursor = cursor -> next;
    }
    return false;
}

// Hashes word to a number
unsigned int hash(const char *word)
{
    // TODO

    // Improve this hash function
    unsigned long hash = 9999;
    int chr;
    while ((chr = toupper(*word++)))
    {
        hash = ((hash << 5) + hash) + chr;
    }
    return hash % N;
}

// Loads dictionary into memory, returning true if successful, else false
bool load(const char *dictionary)
{
    // TODO

    // Open dictionary
    FILE *file = fopen(dictionary, "r");

    // Failed to open
    if (file == NULL)
    {
        return false;
    }

    // Size of word
    char word[LENGTH + 1];

    // Scan dictionary until EOF
    while (fscanf(file, "%s", word) != EOF)
    {
        // Memory allocation for new node
        node *n = malloc(sizeof(node));

        // If NULL, return false
        if (n == NULL)
        {
            return false;
        }

        // Pointer Copy
        strcpy(n -> word, word);

        // Hash word into value
        h_value = hash(word);

        // New pointer
        n -> next = table[h_value];

        // Head to new pointer
        table[h_value] = n;

        // Increment word count
        w_count++;
    }

    // Close
    fclose(file);

    // If dictionary is loaded
    return true;
}

// Returns number of words in dictionary if loaded, else 0 if not yet loaded
unsigned int size(void)
{
    // TODO

    // Check for words
    if (w_count > 0)
    {
        // Return word count
        return w_count;
    }
    return 0;
}

// Unloads dictionary from memory, returning true if successful, else false
bool unload(void)
{
    // TODO

    // Move through containers
    for (int i = 0; i < N; i++)
    {
        node *cursor = table[i];

        while (cursor)
        {
            node *temp = cursor;
            cursor = cursor -> next;
            free(temp);
        }

        if (i == N - 1 && cursor == NULL)
        {
            return true;
        }
    }
    return false;
}
