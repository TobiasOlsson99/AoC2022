use std::io::BufReader;
use std::io::BufRead;
use std::fs::File;
use regex::Regex;

#[derive(Clone)]
struct MapSegment {
    index: i32,
    xmin: i32,
    xmax: i32,
    ymin: i32,
    ymax: i32,
    up: Option<i32>,
    down: Option<i32>,
    right: Option<i32>,
    left: Option<i32>,
    upRot: i32,
    downRot: i32,
    leftRot: i32,
    rightRot: i32
}

fn firstTile(row: &Vec<char>) -> usize {
    for (i,t) in row.iter().enumerate() {if t > &' ' {return i;}}
    0
}

fn whichMapSegment(x: i32, y: i32, mapSegments: &Vec<MapSegment>) -> usize {
    for i in 0..mapSegments.len(){
        if x >= mapSegments[i].xmin && x < mapSegments[i].xmax && y >= mapSegments[i].ymin && y < mapSegments[i].ymax {
            return i;
        } 
    }
    panic!("In unknown map section!")
}

fn nextMove(map: &Vec<Vec<char>>, mapSegments: &Vec<MapSegment>, x: i32, y: i32, dx: i32 , dy: i32) -> (i32,i32,i32,i32){
    let mut xnew = x + dx;
    let mut ynew = y + dy;
    let currentSeg = &mapSegments[whichMapSegment(x,y,mapSegments)];
    if xnew >= currentSeg.xmin && xnew < currentSeg.xmax && ynew >= currentSeg.ymin && ynew < currentSeg.ymax {
        if map[ynew as usize][xnew as usize] == '.' {return (xnew, ynew,dx,dy)}
        else if map[ynew as usize][xnew as usize] == '#' {return (x, y,dx,dy)}
    }
    else{
        let mut dxnew = dx;
        let mut dynew = dy;
        let mut relx = -1;
        let mut rely = -1;
        let mut rotations = -1;
        let mut newSeg = currentSeg;
        if xnew >= currentSeg.xmax {
            newSeg = &mapSegments[currentSeg.right.unwrap() as usize];
            rotations = currentSeg.rightRot;
            (relx,rely) = (0,ynew - currentSeg.ymin);
        }
        else if xnew < currentSeg.xmin {
            newSeg = &mapSegments[currentSeg.left.unwrap() as usize];
            rotations = currentSeg.leftRot;
            (relx,rely) = (49,ynew - currentSeg.ymin);
        }
        else if ynew >= currentSeg.ymax {
            newSeg = &mapSegments[currentSeg.down.unwrap() as usize];
            rotations = currentSeg.downRot;
            (relx,rely) = (xnew - currentSeg.xmin,0);
        }
        else if ynew < currentSeg.ymin {
            newSeg = &mapSegments[currentSeg.up.unwrap() as usize];
            rotations = currentSeg.upRot;
            (relx,rely) = (xnew - currentSeg.xmin,49);
        }
        for rot in 0..rotations{
            (dxnew,dynew) = (-dynew,dxnew);
            (relx,rely) = (49-rely,relx);
        }
        xnew = relx + newSeg.xmin;
        ynew = rely + newSeg.ymin;
        if map[ynew as usize][xnew as usize] == '.' {return (xnew, ynew,dxnew,dynew)}
        else if map[ynew as usize][xnew as usize] == '#' {return (x, y,dx,dy)}
    }
    panic!("Can't find square!")
}

fn finalPosition(map: &Vec<Vec<char>>, mapSegments: &Vec<MapSegment>, path: &String) -> i32 {
    let pattern = Regex::new(r"(R)|(L)|(\d+)").unwrap();
    let mut x = mapSegments[0].xmin;
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
                (x,y,dx,dy) = nextMove(map, mapSegments, x, y, dx, dy);
            }
        }
    }
    (dx-1)*dx + (2-dy)*dy.abs() + 4*(x+1) + 1000*(y+1)
}

fn getCombinations(edges: &Vec<(usize,i32)>) -> Vec<Vec<(usize,i32,usize,i32)>>{
    let (i1,s1) = edges[0];
    let mut returnvec = Vec::new();

    if edges.len() == 2{
        let (i2,s2) = edges[1];
        let mut innerreturnvec = Vec::new();
        innerreturnvec.push((i1,s1,i2,s2));
        returnvec.push(innerreturnvec);
        return returnvec;
    }

    for i in 1..edges.len(){
        let (i2,s2) = edges[i];

        let mut rest: Vec<(usize,i32)> = vec![(0,0);edges.len()-2];
        rest[..i-1].clone_from_slice(&edges[1..i]);
        rest[i-1..].clone_from_slice(&edges[i+1..]);
        let combinations = getCombinations(&rest);

        for mut comb in combinations{
            comb.push((i1,s1,i2,s2));
            returnvec.push(comb);
        }
    }
    return returnvec;
}

fn findSelf(mapSegments: &Vec<MapSegment>, index: i32, searchIndex: i32, rot: i32, turn: i32) -> i32 {
    if rot == 0{
        if (mapSegments[index as usize].right.unwrap() == searchIndex) {return 1};
        return 1 + findSelf(mapSegments, mapSegments[index as usize].right.unwrap(), searchIndex,
                            (rot + mapSegments[index as usize].rightRot + turn) % 4, turn);
    }
    else if rot == 1{
        if (mapSegments[index as usize].down.unwrap() == searchIndex) {return 1};
        return 1 + findSelf(mapSegments, mapSegments[index as usize].down.unwrap(), searchIndex,
                            (rot + mapSegments[index as usize].downRot + turn) % 4, turn);
    }
    else if rot == 2{
        if (mapSegments[index as usize].left.unwrap() == searchIndex) {return 1};
        return 1 + findSelf(mapSegments, mapSegments[index as usize].left.unwrap(), searchIndex,
                            (rot + mapSegments[index as usize].leftRot + turn) % 4, turn);
    }
    else if rot == 3{
        if (mapSegments[index as usize].up.unwrap() == searchIndex) {return 1};
        return 1 + findSelf(mapSegments, mapSegments[index as usize].up.unwrap(), searchIndex,
                            (rot + mapSegments[index as usize].upRot + turn) % 4, turn);
    }
    else {return 0;}
}

fn correctCube(mapSegments: &Vec<MapSegment>) -> bool {
    for i in 0..6{
        for rot in 0..4{
            if findSelf(mapSegments, i, i, rot, 0) != 4 {return false};
            if findSelf(mapSegments, i, i, rot, 1) != 3 {return false};
            if findSelf(mapSegments, i, i, rot, 3) != 3 {return false};
        }
    }
    return true;
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

    let mut mapSegments: Vec<MapSegment> = Vec::new();
    let mut mapOfMapSegments: Vec<Vec<Option<i32>>> = Vec::new();
    let segxmax = xmax/50;
    let segymax = ymax/50;

    for j in 0..segymax {
        let mut rowSegments: Vec<Option<i32>> = Vec::new();
        for i in 0..segxmax {
            if map[j*50][i*50] != ' ' {
                let index = mapSegments.len() as i32;
                let mut newMapSegment = MapSegment {
                    index: index,
                    xmin: (i*50) as i32,
                    xmax: (i*50+50) as i32,
                    ymin: (j*50) as i32,
                    ymax: (j*50+50) as i32,
                    up: None,
                    down: None,
                    right: None,
                    left: None,
                    upRot: 0,
                    downRot: 0,
                    leftRot: 0,
                    rightRot: 0
                };
                mapSegments.push(newMapSegment);
                rowSegments.push(Some(index))
            }
            else{
                rowSegments.push(None);
            }
        }
        mapOfMapSegments.push(rowSegments);
    }

    let mut mapSegments1: Vec<MapSegment> = mapSegments.clone();
    let mut mapSegments2: Vec<MapSegment> = mapSegments.clone();

    for j in 0..segymax {
        for i in 0..segxmax {
            if mapOfMapSegments[j][i].is_some(){
                let mut mapSegment = &mut mapSegments1[mapOfMapSegments[j][i].unwrap() as usize];
                let mut up = (j + segymax - 1) % segymax;
                let mut down = (j + segymax + 1) % segymax;
                let mut left = (i + segxmax - 1) % segxmax;
                let mut right = (i + segxmax + 1) % segxmax;
                while mapOfMapSegments[up][i].is_none() {
                    up = (up + segymax - 1) % segymax;
                }
                mapSegment.up = mapOfMapSegments[up][i];
                while mapOfMapSegments[down][i].is_none() {
                    down = (down + segymax + 1) % segymax;
                }
                mapSegment.down = mapOfMapSegments[down][i];
                while mapOfMapSegments[j][left].is_none() {
                    left = (left + segxmax - 1) % segxmax;
                }
                mapSegment.left = mapOfMapSegments[j][left];
                while mapOfMapSegments[j][right].is_none() {
                    right  = (right + segxmax + 1) % segxmax;
                }
                mapSegment.right = mapOfMapSegments[j][right];
            }
        }
    }

    println!("Puzzle 1: {}", finalPosition(&map, &mapSegments1, &path));

    for j in 0..segymax {
        for i in 0..segxmax {
            if mapOfMapSegments[j][i].is_some(){
                let mut mapSegment = &mut mapSegments2[mapOfMapSegments[j][i].unwrap() as usize];
                if mapOfMapSegments[(j+segymax+1)%segymax][i].is_some(){
                    mapSegment.down = Some(mapOfMapSegments[(j+segymax+1)%segymax][i].unwrap());
                }
                if mapOfMapSegments[(j+segymax-1)%segymax][i].is_some(){
                    mapSegment.up = Some(mapOfMapSegments[(j+segymax-1)%segymax][i].unwrap());
                }
                if mapOfMapSegments[j][(i+segxmax+1)%segxmax].is_some(){
                    mapSegment.right = Some(mapOfMapSegments[j][(i+segxmax+1)%segxmax].unwrap());
                }   
                if mapOfMapSegments[j][(i+segxmax-1)%segxmax].is_some(){
                    mapSegment.left = Some(mapOfMapSegments[j][(i+segxmax-1)%segxmax].unwrap());
                }
            }
        }
    }

    let mut edges = Vec::new();
    for i in 0..6{
        if mapSegments2[i].right.is_none(){
            edges.push((i,0))
        }
        if mapSegments2[i].down.is_none(){
            edges.push((i,1))
        }
        if mapSegments2[i].left.is_none(){
            edges.push((i,2))
        }
        if mapSegments2[i].up.is_none(){
            edges.push((i,3))
        }
    }

    let combinations = getCombinations(&edges);

    for combination in combinations{
        let mut newMapSegments2 = mapSegments2.clone();
        for (i1,s1,i2,s2) in combination{
            if s1==0{
                newMapSegments2[i1].right = Some(i2 as i32);
                newMapSegments2[i1].rightRot = ((6-s1+s2) % 4);
            }
            else if s1==1{
                newMapSegments2[i1].down = Some(i2 as i32);
                newMapSegments2[i1].downRot = ((6-s1+s2) % 4);
            }
            else if s1==2{
                newMapSegments2[i1].left = Some(i2 as i32);
                newMapSegments2[i1].leftRot = ((6-s1+s2) % 4);
            }
            else if s1==3{
                newMapSegments2[i1].up = Some(i2 as i32);
                newMapSegments2[i1].upRot = ((6-s1+s2) % 4);
            }
            if s2==0{
                newMapSegments2[i2].right = Some(i1 as i32);
                newMapSegments2[i2].rightRot = ((6-s2+s1) % 4);
            }
            else if s2==1{
                newMapSegments2[i2].down = Some(i1 as i32);
                newMapSegments2[i2].downRot = ((6-s2+s1) % 4);
            }
            else if s2==2{
                newMapSegments2[i2].left = Some(i1 as i32);
                newMapSegments2[i2].leftRot = ((6-s2+s1) % 4);
            }
            else if s2==3{
                newMapSegments2[i2].up = Some(i1 as i32);
                newMapSegments2[i2].upRot = ((6-s2+s1) % 4);
            }
        }
        if correctCube(&newMapSegments2){
            println!("Puzzle 2: {}", finalPosition(&map, &newMapSegments2, &path));
            break;
        }
    }
}