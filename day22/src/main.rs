use std::io::BufReader;
use std::io::BufRead;
use std::fs::File;
use regex::Regex;

struct MapSegment {
    xmin: i32;
    xmax: i32;
    ymin: i32;
    ymax: i32;
    up: &MapSegment;
    down: &MapSegment;
    right: &MapSegment;
    left: &MapSegment;
    upRot: i32;
    downRot: i32;
    leftRot: i32;
    rightRot: i32;
}

fn firstTile(row: &Vec<char>) -> usize {
    for (i,t) in row.iter().enumerate() {if t > &' ' {return i;}}
    0
}

fn nextMove(map: &Vec<Vec<char>>, x: i32, y: i32, dx: i32 , dy: i32, xmax: i32, ymax: i32) -> (i32,i32){
    let mut xnew = x;
    let mut ynew = y;
    loop {
        ynew = (ynew + dy + ymax) % ymax; 
        xnew = (xnew + dx + xmax) % xmax;
        if map[ynew as usize][xnew as usize] == '.' {return (xnew, ynew)}
        else if map[ynew as usize][xnew as usize] == '#' {return (x, y)}
    }
}



fn puzzle1(map: &Vec<Vec<char>>, path: &String) -> i32 {
    let pattern = Regex::new(r"(R)|(L)|(\d+)").unwrap();
    let xmax = map[0].len() as i32;
    let ymax = map.len() as i32;
    let mut x = firstTile(&map[0]) as i32;
    let mut y = 0;
    let mut dx = 1;
    let mut dy = 0;

    for m in pattern.captures_iter(path) {
        if &m[0] == "R"{
            (dx,dy) = (-dy,dx);
        }
        else if &m[0] == "L"{
            (dx,dy) = (dy,-dx);
        }
        else {
            for step in 0..m[0].parse::<i32>().unwrap(){
                (x,y) = nextMove(map, x, y, dx, dy, xmax, ymax);
            }
            println!("{},{}", x,y);
        }
    }
    (dx-1)*dx + (2-dy)*dy + 4*(x+1) + 1000*(y+1)
}

fn main() {
    let file: File = File::open("input.txt").unwrap();
    let lines: Vec<String> = BufReader::new(file).lines().map(|l| l.unwrap()).collect();
    let ymax = lines.len()-2;
    let xmax = lines[..ymax].iter().map(|l| l.len()).max().unwrap();
    let mut map: Vec<Vec<char>> = Vec::new();
    for line in &lines[..ymax] {
        let mut lineVec = line.chars().collect::<Vec<_>>();
        lineVec.resize(xmax, ' ');
        map.push(lineVec);
    }
    let path = lines.last().unwrap();
    
    println!("{}", puzzle1(&map, &path));

    if (ymax == 200 && xmax == 150){

    }
    else if (ymax == 150 && xmax == 200) {

    }
    else{
        panic!("Wrong dimensions of board");
    }


}