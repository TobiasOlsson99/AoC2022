open System
open System.IO

let cubes = (File.ReadAllLines >> Seq.toList) "input.txt" |> List.map (fun line -> Seq.toList (line.Split ",") |> List.map int)

let getNeighbours (cube : int list) =
    [[cube[0]+1;cube[1];cube[2]]; [cube[0]-1;cube[1];cube[2]]; [cube[0];cube[1]+1;cube[2]]; 
    [cube[0];cube[1]-1;cube[2]]; [cube[0];cube[1];cube[2]+1]; [cube[0];cube[1];cube[2]-1]]

let neighbour (cube1 : int list) (cube2 : int list) = 
    abs (cube1[0]-cube2[0]) + abs (cube1[1]-cube2[1]) + abs (cube1[2]-cube2[2]) = 1

let rec neighbours (cube : int list) (cubes : int list list) : int =
    match cubes with
    | [] -> 0
    | head :: tail ->
        if neighbour cube head then 1 + neighbours cube tail
        else neighbours cube tail

let rec surfaceArea (cubes : int list list) (allCubes : int list list): int=
    match cubes with
    | [] -> 0
    | head :: tail ->
        6 - neighbours head allCubes + surfaceArea tail allCubes

printfn "Puzzle 1: %i" (surfaceArea cubes cubes)

let inBounds (cube : int list) =
    (cube[0] >= -1) && (cube[0] <= 25) && (cube[1] >= -1) && (cube[1] <= 25) && (cube[2] >= -1) && (cube[2] <= 25)

let validAir (allCubes : int list list) (cube : int list)  =
    (not (List.contains cube allCubes)) && inBounds cube

let rec bfs (queue : int list list) (visited : int list list) (allCubes : int list list) : int =
    match queue with
        | [] -> 0
        | head :: tail ->
            if List.contains head visited then bfs tail visited allCubes
            else
                let newAirs = getNeighbours head |> List.filter (validAir allCubes)
                neighbours head allCubes + bfs (List.append tail newAirs) (head :: visited) allCubes

printfn "Puzzle 2: %i" (bfs [[0;0;0]] [] cubes)