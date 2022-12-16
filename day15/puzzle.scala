import scala.io.Source
import scala.util.matching.Regex

val pattern: Regex = """.+?x=(-?\d+), y=(-?\d+):.+?x=(-?\d+), y=(-?\d+)""".r

def parseSensor(str : String) : (Int,Int,Int,Int) =
    val m = pattern.findFirstMatchIn(str).get
    return (m.group(1).toInt, m.group(2).toInt, m.group(3).toInt, m.group(4).toInt)

def coverage(y0 : Int, sensor : (Int,Int,Int,Int)) : (Int,Int) =
    val distance = ((sensor(0)-sensor(2)).abs + (sensor(1)-sensor(3)).abs - (sensor(1)-y0).abs)
    return (sensor(0)-distance, sensor(0)+distance)

def puzzle1(sensors : List[(Int,Int,Int,Int)]) : Int =
    val sorted = sensors.map(coverage(2000000, _)).filter((x1,x2) => x2 >= x1).sortBy(_(0))
    val reduced = sorted.reduce((x1,x2) => (x1(0).min(x2(0)),x1(1).max(x2(1))))
    return reduced(1)-reduced(0)

def puzzle2(sensors : List[(Int,Int,Int,Int)]) : Long =
    for (y <- 0 to 4_000_000)
        val sorted = sensors.map(coverage(y, _)).filter((x1,x2) => x2 >= x1).sortBy(_(0))
        var max_x2 = sorted.head(1)
        for ((x1,x2) <- sorted.tail)
            if (x1 > max_x2 + 1) then
                return (max_x2 + 1) * 4_000_000.toLong + y
            max_x2 = max_x2.max(x2)
    return -1


@main def main() = 
    val sensors = Source.fromFile("input.txt").getLines.toList.map(parseSensor)
    print("Puzzle 1: ")
    println(puzzle1(sensors))
    print("Puzzle 2: ")
    println(puzzle2(sensors))