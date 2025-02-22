#include <cs50.h>
#include <stdio.h>
#include <string.h>

// Max number of candidates
#define MAX 9

// preferences[i][j] is number of voters who prefer i over j
int preferences[MAX][MAX];

// locked[i][j] means i is locked in over j
bool locked[MAX][MAX];

// Each pair has a winner, loser
typedef struct
{
    int winner;
    int loser;
}
pair;

// Array of candidates
string candidates[MAX];
pair pairs[MAX * (MAX - 1) / 2];

int pair_count;
int candidate_count;

// Function prototypes
bool vote(int rank, string name, int ranks[]);
void record_preferences(int ranks[]);
void add_pairs(void);
void merge_sort(int i, int j, pair origin[], pair temp[]);
void sort_pairs(void);
void lock_pairs(void);
void print_winner(void);


int main(int argc, string argv[])
{
    // Check for invalid usage
    if (argc < 2)
    {
        printf("Usage: tideman [candidate ...]\n");
        return 1;
    }

    // Populate array of candidates
    candidate_count = argc - 1;
    if (candidate_count > MAX)
    {
        printf("Maximum number of candidates is %i\n", MAX);
        return 2;
    }
    for (int i = 0; i < candidate_count; i++)
    {
        candidates[i] = argv[i + 1];
    }

    // Clear graph of locked in pairs
    for (int i = 0; i < candidate_count; i++)
    {
        for (int j = 0; j < candidate_count; j++)
        {
            locked[i][j] = false;
        }
    }

    pair_count = 0;
    int voter_count = get_int("Number of voters: ");

    // Query for votes
    for (int i = 0; i < voter_count; i++)
    {
        // ranks[i] is voter's ith preference
        int ranks[candidate_count];

        // Query for each rank
        for (int j = 0; j < candidate_count; j++)
        {
            string name = get_string("Rank %i: ", j + 1);

            if (!vote(j, name, ranks))
            {
                printf("Invalid vote.\n");
                return 3;
            }
        }

        record_preferences(ranks);

        printf("\n");
    }

    add_pairs();
    sort_pairs();
    lock_pairs();
    print_winner();
    return 0;
}

// Update ranks given a new vote
bool vote(int rank, string name, int ranks[])
{
    for (int i = 0; i < candidate_count; i++)
    {
        if (strcmp(candidates[i], name) == 0)
        {
            ranks[rank] = i;
            return true;
        }
    }
    return false;
}

// Update preferences given one voter's ranks
void record_preferences(int ranks[])
{
    for (int i = 0; i < candidate_count; i++)
    {
        for (int j = i + 1; j < candidate_count; j++)
        {
            {
                preferences[ranks[i]][ranks[j]]++;
            }
        }
    }
    return;
}

// Record pairs of candidates where one is preferred over the other
void add_pairs(void)
{
    for (int i = 0; i < candidate_count - 1; i++)
    {
        for (int j = i + 1; j < candidate_count; j++)
        {
            {
                if (preferences[i][j] > preferences[j][i])
                {
                    pairs[pair_count].winner = i;
                    pairs[pair_count].loser = j;
                    pair_count++;
                }
                else if (preferences[i][j] < preferences[j][i])
                {
                    pairs[pair_count].winner = j;
                    pairs[pair_count].loser = i;
                    pair_count++;
                }
            }
        }
    }
    return;
}

// Sort pairs of candidates using merge sort
void merge_sort(int i, int j, pair origin[], pair temp[])
{
    
    // i = Start of array index
    // j = End of array index
    if (j <= i)
    {
        return;
    }

    int m = (i + j) / 2;

    merge_sort(i, m, pairs, temp);
    merge_sort(m + 1, j, pairs, temp);

    int lp = i;
    int rp = m + 1;

    // Start of array index
    for (int k = i; k < j + 1; k++)
    {
        int left_w = origin[lp].winner;
        int left_l = origin[lp].loser;
        int right_w = origin[rp].winner;
        int right_l = origin[rp].loser;

        // End of left array
        if (lp == m + 1)
        {
            temp[k] = origin[rp];
            rp++;
        }
        // End of right array
        else if (rp == j + 1)
        {
            temp[k] = origin[lp];
            lp++;
        }

        else if (preferences[left_w][left_l] > preferences[right_w][right_l])
        {
            temp[k] = origin[lp];
            lp++;
        }

        else
        {
            temp[k] = origin[rp];
            rp++;
        }
    }

    for (int k = i; k < j + 1; k++)
    {
        // Copy sorted array
        origin[k] = temp[k];
    }

}

// Sort pairs in decreasing order by strength of victory
void sort_pairs(void)
{
    pair temp[pair_count];
    merge_sort(0, pair_count - 1, pairs, temp);
    return;
}


// Cycle
bool cycle(int c_start, int c_end)
{
    // Default
    if (locked[c_end][c_start])
    {
        return true;
    }

    for (int i = 0; i < candidate_count; i++)
    {
        if (locked[c_end][i] == true && cycle(c_start, i))
        {
            // Create a cycle
            return true;
        }
    }
    return false;
}


// Lock pairs into the candidate graph in order, without creating cycles
void lock_pairs(void)
{
    for (int i = 0; i < pair_count; i++)
    {
        if (!cycle(pairs[i].winner, pairs[i].loser))
        {
            locked[pairs[i].winner][pairs[i].loser] = true;
        }
    }
}

// Print the winner of the election
void print_winner(void)
{
    for (int c = 0; c < candidate_count; c++)
    {
        int count = 0;
        for (int r = 0; r < candidate_count; r++)
        {
            if (locked[r][c])
            {
                break;
            }
            if (!locked[r][c])
            {
                count++;
                // Undefeated
                if (count == candidate_count)
                {
                    printf("%s\n", candidates[c]);
                    break;
                }
            }
        }
    }
    return;
}