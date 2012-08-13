
#include "tom-thumb-tall.h"
#include "stdio.h"
#include "unistd.h"

int main(int argc, char** argv) {

    if (argc < 2) {
        fprintf(stderr, "Usage: testfont <str>\n");
        return 2;
    }

    char* msg = argv[1];

    printf("\n");

    for (; *msg != '\0'; msg++) {
        int idx = ((int)*msg) - 32;
        for (int ci = 0; ci < 4; ci++) {
            int colval = tom_thumb_tall[idx][ci];
            printf("                    ");
            for (int ri = 7; ri >= 0; ri--) {
                if (colval & (1 << ri)) {
                    printf("#");
                }
                else {
                    printf(" ");
                }
            }
            printf("\n");
            // To make a poor-man's LED scroll in the terminal buffer :)
            //usleep(100000);
        }
    }

    return 0;
}
