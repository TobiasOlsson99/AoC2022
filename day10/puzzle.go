package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	dat, _ := os.ReadFile("input.txt")
	lines := strings.Split(string(dat), "\n")
	lines = lines[:len(lines)-1] //Remove empty line at end

	regX := []int{1, 1}
	i := 1
	for _, line := range lines {
		if line == "noop" {
			regX = append(regX, regX[i])
			i += 1
		} else {
			arguments := strings.Split(line, " ")
			operand, _ := strconv.Atoi(arguments[1])
			regX = append(regX, regX[i], regX[i]+operand)
			i += 2
		}
	}

	puzzle1 := 20*regX[20] + 60*regX[60] + 100*regX[100] + 140*regX[140] + 180*regX[180] + 220*regX[220]
	fmt.Println("Puzzle 1:", puzzle1)
	fmt.Println("Puzzle 2:")

	for i := 1; i <= 240; i++ {
		if regX[i] <= (i-1)%40+1 && regX[i] >= (i-1)%40-1 {
			fmt.Print("#")
		} else {
			fmt.Print(" ")
		}
		if i%40 == 0 {
			fmt.Print("\n")
		}
	}
}
