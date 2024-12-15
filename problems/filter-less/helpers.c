#include "helpers.h"
#include "math.h"

// Convert image to grayscale
void grayscale(int height, int width, RGBTRIPLE image[height][width])
{
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            float red = image[i][j].rgbtRed;
            float green = image[i][j].rgbtGreen;
            float blue = image[i][j].rgbtBlue;

            int avg = round((red + blue + green) / 3);

            image[i][j].rgbtRed = image[i][j].rgbtGreen = image[i][j].rgbtBlue = avg;
        }
    }
    return;
}

// Convert image to sepia
void sepia(int height, int width, RGBTRIPLE image[height][width])
{
    int Red, Green, Blue;
    int sepiaRed, sepiaGreen, sepiaBlue;

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            Red = image[i][j].rgbtRed;
            Green = image[i][j].rgbtGreen;
            Blue = image[i][j].rgbtBlue;

            // Red sepia calculations
            sepiaRed = round(.393 * Red +  .769 * Green + .189 * Blue);

            // Red sepia assignment
            image[i][j].rgbtRed = (sepiaRed > 255) ? 255 : sepiaRed;

            // Green sepia calculations
            sepiaGreen = round(.349 * Red + .686 * Green + .168 * Blue);

            // Green sepia assignment
            image[i][j].rgbtGreen = (sepiaGreen > 255) ? 255 : sepiaGreen;

            // Blue sepia calculations
            sepiaBlue = round(.272 * Red + .534 * Green + .131 * Blue);

            // Blue sepia assignment
            image[i][j].rgbtBlue = (sepiaBlue > 255) ? 255 : sepiaBlue;
        }
    }
    return;
}

// Reflect image horizontally
void reflect(int height, int width, RGBTRIPLE image[height][width])
{
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width / 2; j++)
        {
            int tempRed = image[i][j].rgbtRed;
            int tempGreen = image[i][j].rgbtGreen;
            int tempBlue = image[i][j].rgbtBlue;

            image[i][j].rgbtRed = image[i][width - j - 1].rgbtRed;
            image[i][j].rgbtGreen = image[i][width - j - 1].rgbtGreen;
            image[i][j].rgbtBlue = image[i][width - j - 1].rgbtBlue;

            image[i][width - j - 1].rgbtRed = tempRed;
            image[i][width - j - 1].rgbtGreen = tempGreen;
            image[i][width - j - 1].rgbtBlue = tempBlue;
        }
    }
    return;
}

// Blur image
void blur(int height, int width, RGBTRIPLE image[height][width])
{
    // Temp image
    RGBTRIPLE temp[height][width];

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int totalRed, totalGreen, totalBlue;
            totalRed = totalGreen = totalBlue = 0;
            float counter = 0.00;

            // Get neighbours
            for (int x = -1; x < 2; x++)
            {
                for (int y = -1; y < 2; y++)
                {
                    int currX = i + x;
                    int currY =  j + y;

                    // Validate neighbours
                    if (currX < 0 || currX >= height || currY < 0 || currY >= width)
                    {
                        continue;
                    }

                    // Get image values
                    totalRed += image[currX][currY].rgbtRed;
                    totalGreen += image[currX][currY].rgbtGreen;
                    totalBlue += image[currX][currY].rgbtBlue;

                    counter++;
                }

                // Average neighbours
                temp[i][j].rgbtRed = round(totalRed / counter);
                temp[i][j].rgbtGreen = round(totalGreen / counter);
                temp[i][j].rgbtBlue = round(totalBlue / counter);
            }
        }
    }

    // Copy blurred image to the original
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            image[i][j].rgbtRed = temp[i][j].rgbtRed;
            image[i][j].rgbtGreen = temp[i][j].rgbtGreen;
            image[i][j].rgbtBlue = temp[i][j].rgbtBlue;
        }
    }
    return;
}
