import csv
from sys import argv, exit


def main():

    # Check for command-line usage
    if len(argv) != 3:
        print("Usage: python dna.py data.csv sequence.txt")
        exit(37)

    # Read database file into a variable
    with open(argv[1]) as database_file:
        reader = csv.DictReader(database_file)
        database = list(reader)

    # Read DNA sequence file into a variable
    with open(argv[2]) as sequence_file:
        sequence = sequence_file.read()

    # Find longest match of each STR in DNA sequence
    matches = {}

    for i in database[0]:
        matches[i] = (longest_match(sequence, i))

    # Check database for matching profiles
    profile = "No Match"
    profile_counter = 1

    for i in range(len(database)):
        for j in matches:
            if str(matches[j]) == database[i][j]:
                profile_counter += 1
        if profile_counter == len(matches):
            profile = database[i]["name"]
            break
        else:
            profile_counter = 1

    print(profile)

    return


def longest_match(sequence, subsequence):
    """Returns length of longest run of subsequence in sequence."""

    # Initialize variables
    longest_run = 0
    subsequence_length = len(subsequence)
    sequence_length = len(sequence)

    # Check each character in sequence for most consecutive runs of subsequence
    for i in range(sequence_length):

        # Initialize count of consecutive runs
        count = 0

        # Check for a subsequence match in a "substring" (a subset of characters) within sequence
        # If a match, move substring to next potential match in sequence
        # Continue moving substring and checking for matches until out of consecutive matches
        while True:

            # Adjust substring start and end
            start = i + count * subsequence_length
            end = start + subsequence_length

            # If there is a match in the substring
            if sequence[start:end] == subsequence:
                count += 1

            # If there is no match in the substring
            else:
                break

        # Update most consecutive matches found
        longest_run = max(longest_run, count)

    # After checking for runs at each character in seqeuence, return longest run found
    return longest_run


main()
