
//Import fs
const fs = require('fs');

const pattern = RegExp("move (?<amount>\\d+) from (?<from>\\d) to (?<to>\\d)", "");
function puzzle1(lines, stacks){
    for (const line of lines) {
        const matches = line.match(pattern);
        if (matches != null) {
            const amount = parseInt(matches["groups"]["amount"]);
            const from = parseInt(matches["groups"]["from"]) - 1;
            const to = parseInt(matches["groups"]["to"]) - 1;
            for (i = 0; i < amount && stacks[from].length > 0; i++){
                stacks[to].push(stacks[from].pop());
            }

        }
    }
    return stacks;
}
function puzzle2(lines, stacks) {
    for (const line of lines) {
        const matches = line.match(pattern);
        if (matches != null) {
            amount = parseInt(matches["groups"]["amount"]);
            from = parseInt(matches["groups"]["from"]) - 1;
            to = parseInt(matches["groups"]["to"]) - 1;
            amount = Math.min(amount, stacks[from].length);
            Array.prototype.push.apply(stacks[to], stacks[from].slice(stacks[from].length-amount));
            stacks[from] = stacks[from].slice(0,stacks[from].length-amount)
        }
    }
    return stacks;
}

function main() {
    input = fs.readFileSync("input.txt", "utf8");
    lines = input.split('\n');
    stacks = [];
    for (i = 0; i < 9; i++) stacks.push(new Array);
    i = 0;
    while (lines[i] != " 1   2   3   4   5   6   7   8   9 ") i++;
    for (j = i-1; j >= 0; j--) {
        for (k = 0; k < 9; k++) {
            item = lines[j].charAt(k*4+1);
            if (item != ' ') stacks[k].push(item);
        };
    };

    lines = lines.slice(i+2);

    console.log("Puzzle 1");
    console.log(puzzle1(lines, JSON.parse(JSON.stringify(stacks))));
    console.log("Puzzle 2");
    console.log(puzzle2(lines, JSON.parse(JSON.stringify(stacks))));
    
}

main();