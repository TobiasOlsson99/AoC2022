
def elfIter(calorieList):
    elf = []
    for calorie in calorieList:
        calorie = calorie.strip()
        if calorie == '':
            yield sum(elf)
            elf = []
            continue
        else:
            elf.append(int(calorie))
    
def puzzle1():    
    return max(elfIter(open("input1.txt", "r").readlines()))

def puzzle2():
    return sum(sorted(elfIter(open("input1.txt", "r").readlines()), reverse=True)[:3])

if __name__ == "__main__":
    print(puzzle1(), puzzle2())