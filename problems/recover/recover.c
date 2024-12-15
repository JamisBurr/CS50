#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
typedef uint8_t BYTE;

int main(int argc, char *argv[])
{
    // Command does not equal 2
    if (argc != 2)
    {
        printf("Usage: ./recover image\n");
        return 1;
    }

    // Open card.raw
    char *input_f = argv[1];
    FILE *input_p = fopen(input_f, "r");

    // File failed to open
    if (input_f == NULL)
    {
        printf("Failed to open file.");
        return 2;
    }

    // Intitialize variables
    BYTE buffer[512];
    int count = 0;
    FILE *image_p = NULL;
    char filename[8];

    // Repeat until end
    while (fread(&buffer, 512, 1, input_p) == 1)
    {
        
        // If start of new JPEG
        if (buffer[0] == 0xff && buffer[1] == 0xd8 && buffer[2] == 0xff && (buffer[3] & 0xf0) == 0xe0)
        {

            // If not first JPEG, close
            if (!(count == 0))
            {
                fclose(image_p);
            }

            // Initialize file
            sprintf(filename, "%03i.jpg", count);
            image_p = fopen(filename, "w");
            count++;
        }

        // If JPEG found, write to file
        if (!(count == 0))
        {
            fwrite(&buffer, 512, 1, image_p);
        }
    }
    fclose(input_p);
    fclose(image_p);

    return 0;
}