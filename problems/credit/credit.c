#include <cs50.h>
#include <math.h>
#include <stdio.h>

int main(void)
{

    // Get card number
    long n = get_long("Number: ");

    // Credit card length counter
    int nl = 0;
    long cc = n;
    while (cc > 0)
    {
        cc = cc / 10;
        nl++;
    }

    // Check length is valid
    if (nl != 13 && nl != 15 && nl != 16)
    {
        printf("INVALID\n");
        return 0;
    }


    // Calculate checksum
    int sum1 = 0;
    int sum2 = 0;
    long x = n;
    int total = 0;
    int mod1;
    int mod2;
    int div1;
    int div2;

    do
    {
        // Remove last digit and add to sum1
        mod1 = x % 10;
        x = x / 10;
        sum1 = sum1 + mod1;
        // Remove second last digit
        mod2 = x % 10;
        x = x / 10;
        // Double second last digit and add digits to sum2
        mod2 = mod2 * 2;
        div1 = mod2 % 10;
        div2 = mod2 / 10;
        sum2 = sum2 + div1 + div2;
    }
    while (x > 0);
    total = sum1 + sum2;

    // Check Luhn Algorithm
    if (total % 10 != 0)
    {
        printf("INVALID\n");
        return 0;
    }

    // Get starting numbers
    long start = n;
    do
    {
        start = start / 10;
    }
    while (start > 100);

    // Check starting CC numbers
    if ((start / 10 == 5) && (0 < start % 10 && start % 10 < 6))
    {
        printf("MASTERCARD\n");
    }

    else if ((start / 10 == 3) && (start % 10 == 4 || start % 10 == 7))
    {
        printf("AMEX\n");
    }

    else if (start / 10 == 4)
    {
        printf("VISA\n");
    }

    else
    {
        printf("INVALID\n");
        return 0;
    }
}