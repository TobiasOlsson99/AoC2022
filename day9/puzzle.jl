inputLines = filter(line -> length(line) > 0, split(read(open("input.txt", "r"), String), '\n'))
function motion(line)
    words = split(line)

    return words[1][1], parse(Int, words[2])
end
headMotion = map(motion, inputLines)

function move(dir, rope)
    if dir=='U'
        rope[1] = rope[1][1],rope[1][2]+1
    elseif dir=='D'
        rope[1] = rope[1][1],rope[1][2]-1
    elseif dir=='R'
        rope[1] = rope[1][1]+1,rope[1][2]
    elseif dir=='L'
        rope[1] = rope[1][1]-1,rope[1][2]
    end

    for i in 2:length(rope)
        diff = rope[i-1][1] - rope[i][1], rope[i-1][2] - rope[i][2]
        sdiff = sign(diff[1]), sign(diff[2])
        absDiff = sqrt(diff[1]^2 + diff[2]^2)
        if absDiff >= 2
            global rope[i] = rope[i][1] + sdiff[1], rope[i][2] + sdiff[2]
        end
    end
end

puzzle1Rope = fill((0,0), 2)
puzzle2Rope = fill((0,0), 10)
puzzle1History = Vector{Tuple{Int,Int}}(undef, 0)
puzzle2History = Vector{Tuple{Int,Int}}(undef, 0)

for (dir, len) in headMotion
    for _ in 1:len
        move(dir, puzzle1Rope)
        move(dir, puzzle2Rope)
        push!(puzzle1History, puzzle1Rope[2])
        push!(puzzle2History, puzzle2Rope[10])
    end
end

println("Puzzle 1: ", length(unique(puzzle1History)))
println("Puzzle 2: ", length(unique(puzzle2History)))

