#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define XMAX 102
#define YMAX 37
#define FILENAME "input.txt"
#define MOD(a,b) (((a) % (b) + (b)) % (b))

char right[YMAX-2][XMAX-2];
char left[YMAX-2][XMAX-2];
char up[YMAX-2][XMAX-2];
char down[YMAX-2][XMAX-2];
char walls[YMAX][XMAX];
char map[YMAX][XMAX];
char tmp[YMAX][XMAX];

void read_file(FILE* file){
    int i = 0;
    int j = 0;
    char c;
    do {
        c = fgetc(file);
        if (c >= '#'){
            switch (c){
                case '#': walls[j][i] = 1; break;
                case '<': left[j-1][i-1] = 1; break;
                case '>': right[j-1][i-1] = 1; break;
                case 'v': down[j-1][i-1] = 1; break;
                case '^': up[j-1][i-1] = 1; break;
            }
            i++;
        }
        else if (c == '\n'){
            i = 0;
            j++;
        }
    } while (c != EOF);
}

int bfs(int t, int goalx, int goaly){
    memset((void*) tmp, 0, XMAX*YMAX);
    for (int j = 0; j < YMAX; j++) {
        for (int i = 0; i < XMAX; i++) {
            if (map[j][i] && j == goaly && i == goalx) return t;
            if (map[j][i]) {
                tmp[j][i] = 1;
                tmp[MOD(j+1,YMAX)][i] = 1;
                tmp[MOD(j-1,YMAX)][i] = 1;
                tmp[j][MOD(i+1,XMAX)] = 1;
                tmp[j][MOD(i-1,XMAX)] = 1;
            }
        }
    }
    t += 1;
    for (int j = 0; j < YMAX; j++) {
        for (int i = 0; i < XMAX; i++) {
            map[j][i] = tmp[j][i] & ~(
                walls[j][i] |
                right[j-1][MOD(i-t-1,XMAX-2)] |
                left[j-1][MOD(i+t-1,XMAX-2)] |
                up[MOD(j+t-1,YMAX-2)][i-1] |
                down[MOD(j-t-1,YMAX-2)][i-1]);
        }
    }
    return bfs(t, goalx, goaly);
}

void main (int argc, char *argv[]) {
    FILE* file = fopen(FILENAME, "r");
    read_file(file);

    map[0][1] = 1;
    int p1 = bfs(0, 100, 36); // START -> END

    memset((void*) map, 0, YMAX*XMAX);
    map[36][100] = 1;
    int p2 = bfs(p1, 1, 0); // END -> START

    memset((void*) map, 0, YMAX*XMAX);
    map[0][1] = 1;
    int p3 = bfs(p2, 100, 36); // START -> END

    printf("Puzzle 1: %d\n", p1);
    printf("Puzzle 2: %d\n", p3);
}