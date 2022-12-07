#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int lengthdistinct(char* processed, int i) {
    for (int length = 1; length <= 14; length++){
        for (int k = 0; k < length; k++) {
            if (processed[(i-k+14)%14] == processed[(i-length+14)%14]) return length;
        }
    }
}

int main(int argc, char *argv[])
{
    FILE* file = fopen("input.txt", "r");
    int currentchar;
    int startofpacket = 0;
    int startofmessage = 0;
    char processed[14] = {(char)fgetc(file), (char)fgetc(file), (char)fgetc(file)};
    memset(processed + 3, 0, sizeof processed - 3);
    for (int i = 3; (currentchar = fgetc(file)) != EOF; i++) {
        processed[i%14] = (char)currentchar;
        int length = lengthdistinct(processed, i);
        if (length>=4 && !startofpacket) startofpacket = i+1;
        if (length>=14 && !startofmessage) {startofmessage = i+1; break;}
    }
    printf("Puzzle 1: %d, Puzzle 2: %d", startofpacket, startofmessage);
    return 0;
}