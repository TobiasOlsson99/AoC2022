boolean turn(map, directionOrder, xmax, ymax) {
    int[][] propsMap = [[0]*xmax]*ymax
    List<Tuple<int>> props = []
    int moves = 0
    (2..ymax-2).each { y ->
        (2..xmax-2).each { x ->
            if (map[y][x] == 1 && (
                map[y+0][x+1] != 0 || map[y+0][x-1] != 0 || map[y+1][x+1] != 0 || map[y+1][x+0] != 0 || 
                map[y+1][x-1] != 0 || map[y-1][x+1] != 0 || map[y-1][x+0] != 0 || map[y-1][x-1] != 0)) {

                directionOrder.any { t ->
                    dx = t[0]
                    dy = t[1]
                    if (map[y+dy][x+dx] == 0 && map[y+dy+dx][x+dx+dy] == 0 && map[y+dy-dx][x+dx-dy] == 0) {
                        propsMap[y+dy][x+dx] += 1
                        props.add(new Tuple(x,y,dx,dy))
                        return true //Break
                    }
                }
            }
        }
    }
    props.each { t ->
        x = t[0]
        y = t[1]
        dx = t[2]
        dy = t[3]
        if (propsMap[y+dy][x+dx] == 1) {
            moves += 1
            map[y+dy][x+dx] = 1
            map[y][x] = 0
        }
    }
    directionOrder.add(directionOrder.remove(0))
    return (moves > 0)
}

int simulate(map, directionOrder, xmax, ymax, turns) {
    for (int t = 1; t <= turns; t++) {
        if (!turn(map, directionOrder, xmax, ymax)) return t
    }
    return -1
}

int emptySquares(map, xmax, ymax) {
    def xfirst = 2000
    def xlast = 0
    def yfirst = 2000
    def ylast = 0
    (0..ymax-1).each { y ->
        (0..xmax-1).each { x ->
            if (map[y][x] == 1) {
                xfirst = Math.min(xfirst, x)
                xlast = Math.max(xlast, x)
                yfirst = Math.min(yfirst,y)
                ylast = Math.max(ylast,y)
            }
        }
    }
    def emptyground = 0
    (yfirst..ylast).each { y ->
        (xfirst..xlast).each { x ->
            if (map[y][x] == 0) {
                emptyground += 1
            }
        }
    }
    return emptyground
}

def xmax = 200
def ymax = 200
int[][] map = [[0]*xmax]*ymax
new File("input.txt").readLines().eachWithIndex { line, j ->
    line.eachWithIndex{ c, i ->
        if (c == '#') map[(ymax.intdiv(2) - 35 + j)][(xmax.intdiv(2) - 35 + i)] = 1
    }
}
List<Tuple<int>> directionOrder = [new Tuple(0,-1), new Tuple(0,1), new Tuple(-1,0), new Tuple(1,0)]

simulate(map, directionOrder, xmax, ymax, 10)
println sprintf("Puzzle 1: %d",emptySquares(map, xmax, ymax))
println sprintf("Puzzle 2: %d",10 + simulate(map, directionOrder, xmax, ymax, 10000))