class Monkey 
    def initialize(items, operation, operand, divisor, trueMonkey, falseMonkey)
        @items = items
        @operation = operation
        @operand = operand
        @divisor = divisor
        @trueMonkey = trueMonkey
        @falseMonkey = falseMonkey
        @inspects = 0
    end

    def setMonkeyList(list)
        @monkeyList = list
    end

    def addItem(item)
        @items.append(item)
    end

    def getDivisor()
        return @divisor
    end

    def getInspects()
        return @inspects
    end

    def inspectItem(item)
        @inspects += 1
        if @operand == "old"
            if @operation == "*"
                item = item * item
            else
                item = item + item
            end
        else
            if @operation == "*"
                item = item * @operand.to_i
            else
                item = item + @operand.to_i
            end
        end
        return item
    end

    def throwItem(item)
        if item % @divisor == 0
            @monkeyList[@trueMonkey].addItem(item)
        else
            @monkeyList[@falseMonkey].addItem(item)
        end
    end

    def turnPuzzle1()
        @items.each do |item|
            item = inspectItem(item)
            item = (item / 3).floor
            throwItem(item)
        end
        @items.clear
    end

    def turnPuzzle2()
        @items.each do |item|
            item = inspectItem(item)
            item = item % $lcmPuzzle2
            throwItem(item)
        end
        @items.clear
    end
end

pattern = Regexp.compile(/Monkey \d:\s+Starting items: (\d+(?:, \d+)*)\s+Operation: new = old (.) (\w+)\s+Test: divisible by (\d+)\s+If true: throw to monkey (\d)\s+If false: throw to monkey (\d)/)
input = File.read("input.txt")

monkeyListPuzzle1 = []
monkeyListPuzzle2 = []
input.scan(pattern).each do |match|
    items = match[0].scan(/\d+/).map {|str| str.to_i}
    monkeyListPuzzle1.append(Monkey.new(items, match[1], match[2], match[3].to_i, match[4].to_i, match[5].to_i))
    monkeyListPuzzle2.append(Monkey.new(items.map(&:clone), match[1], match[2], match[3].to_i, match[4].to_i, match[5].to_i))
end

monkeyListPuzzle1.each {|monkey| monkey.setMonkeyList(monkeyListPuzzle1)} 
monkeyListPuzzle2.each {|monkey| monkey.setMonkeyList(monkeyListPuzzle2)}

$lcmPuzzle2 = monkeyListPuzzle2.map{|monkey| monkey.getDivisor}.inject{|a,b| a.lcm(b)}

20.times do
    monkeyListPuzzle1.each {|monkey| monkey.turnPuzzle1}
end
10000.times do
    monkeyListPuzzle2.each {|monkey| monkey.turnPuzzle2}
end

print "Puzzle 1: "
puts monkeyListPuzzle1.map{|monkey| monkey.getInspects}.sort.reverse.slice(0,2).inject(:*)
print "Puzzle 2: "
puts monkeyListPuzzle2.map{|monkey| monkey.getInspects}.sort.reverse.slice(0,2).inject(:*)



