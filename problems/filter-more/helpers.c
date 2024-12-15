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
                    if (currX < 0 || currX > (height - 1) || currY < 0 || currY > (width - 1))
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

// Detect edges
void edges(int height, int width, RGBTRIPLE image[height][width])
{
    // Temp array
    RGBTRIPLE temp[height][width];

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            temp[i][j] = image[i][j];
        }
    }


    // Sobel arrarys
    int Gx[3][3] =
    {
        {-1, 0, 1},
        {-2, 0, 2},
        {-1, 0, 1}
    };

    int Gy[3][3] =
    {
        {-1, -2, -1},
        {0, 0, 0},
        {1, 2, 1}
    };

    // Loop rows
    for (int i = 0; i < height; i++)
    {
        // Loop columns
        for (int j = 0; j < width; j++)
        {
            int rows[3] = {i - 1, i, i + 1};
            int cols[3] = {j - 1, j, j + 1};

            int Gx_R, Gx_G, Gx_B;
            Gx_R = Gx_G = Gx_B = 0;

            int Gy_R, Gy_G, Gy_B;
            Gy_R = Gy_G = Gy_B = 0;

            // Loop for each pixel
            for (int x = 0; x < 3; x++)
            {
                for (int y = 0; y < 3; y++)
                {
                    int row = rows[x];
                    int col = cols[y];
                    RGBTRIPLE pixel = temp[row][col];

                    if (row < height && row >= 0 && col < width && col >= 0)
                    {
                        Gx_R += pixel.rgbtRed * Gx[x][y];
                        Gx_G += pixel.rgbtGreen * Gx[x][y];
                        Gx_B += pixel.rgbtBlue * Gx[x][y];
                        Gy_R += pixel.rgbtRed * Gy[x][y];
                        Gy_G += pixel.rgbtGreen * Gy[x][y];
                        Gy_B += pixel.rgbtBlue * Gy[x][y];
                    }
                }
            }

            // Calculate Sobel operator
            int R = round(sqrt(Gx_R * Gx_R + Gy_R * Gy_R));
            int G = round(sqrt(Gx_G * Gx_G + Gy_G * Gy_G));
            int B = round(sqrt(Gx_B * Gx_B + Gy_B * Gy_B));

            // Assign new values
            image[i][j].rgbtRed = R > 255 ? 255 : R;
            image[i][j].rgbtGreen = G > 255 ? 255 : G;
            image[i][j].rgbtBlue = B > 255 ? 255 : B;
        }
    }
    return;
}