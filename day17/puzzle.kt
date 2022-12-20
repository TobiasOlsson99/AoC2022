import java.io.File
import kotlin.math.max

val rocks = arrayOf(
    arrayOf(byteArrayOf(1), byteArrayOf(1), byteArrayOf(1), byteArrayOf(1)),
    arrayOf(byteArrayOf(0,1,0),byteArrayOf(1,1,1),byteArrayOf(0,1,0)),
    arrayOf(byteArrayOf(0,0,1),byteArrayOf(0,0,1),byteArrayOf(1,1,1)),
    arrayOf(byteArrayOf(1,1,1,1)),
    arrayOf(byteArrayOf(1,1),byteArrayOf(1,1)))
class Simulation(moves : ByteArray) {
    private var moves : ByteArray = moves
    private var playingField : Array<ByteArray> = Array(7){_ -> ByteArray(1000)}
    private var turn : Int = 1
    private var step : Int = 0
    private var currentHeight : Int = 0
    private var yOffset : Int = 0
    private var repeats : Pair<Int,Int> = Pair(-1,-1)
    public fun getHeight(turns : Int): Int{
        this.resetSimulation()
        this.simulate(turns)
        return this.currentHeight
    }
    public fun getHeight(turns : Long): Long{
        this.findRepeat()
        val (first,second) = this.repeats
        val diff = second-first
        this.resetSimulation()

        this.simulate(first-1)
        val firstHeight = this.currentHeight

        this.simulate(diff)
        val repeatingHeight = this.currentHeight - firstHeight
        val repeatsAmount = (turns - first + 1) / diff
        val leftOver = (turns - first + 1) % diff

        this.simulate(leftOver.toInt())
        val lastHeight = this.currentHeight - repeatingHeight - firstHeight

        return firstHeight + repeatingHeight * repeatsAmount + lastHeight
    }
    private fun tryMove(rock : Int, x0 : Int, y0: Int): Boolean{
        if (x0 + rocks[rock].size > 7 || x0 < 0) return false
        if (y0 + rocks[rock][0].size > 1000 || y0 < 0) return false
        for (x in 0..rocks[rock].size-1) {
            for (y in 0..rocks[rock][0].size-1){
                if (rocks[rock][x][y].toInt() and this.playingField[x0+x][y0+y].toInt() == 1){
                    return false
                }
            }
        }
        return true;
    }
    private fun simulateRock(rock : Int, yStart : Int): Int{
        var y : Int = yStart
        var x : Int = 2
        while (true){
            this.step = this.step % this.moves.size
            if (this.moves[this.step] == '<'.code.toByte()) {
                if (tryMove(rock, x-1, y)) x -= 1
            } else if (this.moves[this.step] == '>'.code.toByte()){
                if (tryMove(rock, x+1, y)) x += 1
            }
            this.step += 1
            if (tryMove(rock, x, y+1)) {
                y += 1
            } else {
                for (i in 0..rocks[rock].size-1) {
                    for (j in 0..rocks[rock][0].size-1){
                        this.playingField[i+x][j+y] = (rocks[rock][i][j].toInt() or this.playingField[i+x][j+y].toInt()).toByte()
                    }
                }
                this.step = this.step % this.moves.size
                return y
            }
        }
    }
    private fun simulate(turns : Int){
        val maxTurn = this.turn + turns
        while (this.turn < maxTurn){
            val rock = (this.turn-1) % rocks.size
            var y : Int = 1000 + this.yOffset - this.currentHeight - 3 - rocks[rock][0].size
            
            y = simulateRock(rock, y)

            this.currentHeight = max(this.currentHeight,1000 - y + this.yOffset)
            this.trimPlayingField()
            this.turn += 1
        }
    }
    private fun findRepeat(){
        val repeats : MutableList<Triple<Int,Int,Int>> = mutableListOf()
        while (true){
            for ((t,r,s) in repeats) {
                if ((this.turn-1) % rocks.size == r && this.step == s){
                    this.repeats = Pair(t, this.turn)
                    return
                }
            }
            if (turn > 3000) repeats.add(Triple(this.turn, (turn-1) % rocks.size, this.step))

            val rock = (this.turn-1) % rocks.size
            var y : Int = 1000 + this.yOffset - this.currentHeight - 3 - rocks[rock][0].size
            
            y = simulateRock(rock, y)

            this.currentHeight = max(this.currentHeight,1000 - y + this.yOffset)
            this.trimPlayingField()
            this.turn += 1
        }
    }
    private fun trimPlayingField(){
        if (this.currentHeight - this.yOffset > 900){
            this.yOffset += 500
            for (j in 999 downTo 0){
                for (i in 0..6) {
                    if (j < 500) this.playingField[i][j] = 0
                    else this.playingField[i][j] = this.playingField[i][j-500]
                }
            }
        }
    }
    private fun resetSimulation(){
        this.playingField = Array(7){_ -> ByteArray(1000)}
        this.yOffset = 0
        this.currentHeight = 0
        this.step = 0
        this.turn = 1
        this.repeats = Pair(-1,-1)
    }
}
fun main() {
    val moves = File("input.txt").readLines().first().toByteArray()
    val sim = Simulation(moves)
    println("Puzzle 1: %d".format(sim.getHeight(2022)))
    println("Puzzle 2: %d".format(sim.getHeight(1_000_000_000_000)))
}