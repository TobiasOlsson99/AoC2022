local lines = {}
for line in io.open("input.txt"):lines() do
    local tab = {}
    tab.name = string.sub(line,1,4)
    if string.find(line, "%S+: (%S+) %S %S+") then
        tab.operand1 = string.sub(line,7,10)
        tab.operator = string.sub(line,12,12)
        tab.operand2 = string.sub(line,14,17)
    else
        tab.number = tonumber(string.sub(line,7))
    end
    lines[tab.name] = tab
end

function getNumber (entry, humanNumber)
    if entry.name == "humn" and humanNumber ~= null then
        return humanNumber
    elseif entry.number ~= null then
        return entry.number
    else
        local number1 = getNumber(lines[entry.operand1], humanNumber)
        local number2 = getNumber(lines[entry.operand2], humanNumber)
        if      entry.operator == "*" then return (number1 * number2)
        elseif  entry.operator == "/" then return (number1 / number2)
        elseif  entry.operator == "+" then return (number1 + number2)
        elseif  entry.operator == "-" then return (number1 - number2)
        end
    end
end

local root = lines["root"]
print(string.format("Puzzle 1: %d",getNumber(root, null)))

local rootNode2 = lines[root.operand1]
local rootNode1 = lines[root.operand2]
local humanNode = rootNode2
local otherNode = rootNode1
local K = null
if(getNumber(rootNode1, 1) - getNumber(rootNode1, 0) ~= 0) then
    humanNode = rootNode1
    otherNode = rootNode2
end

if (getNumber(humanNode, 1) - getNumber(humanNode, 0) > 0) then K = 1
else K = -1
end

local min = - 2^50
local max =  2^50

while(true) do
    local middle = math.floor((min + max)/2)
    local diff = (getNumber(humanNode, middle) - getNumber(otherNode, null)) * K
    if (diff == 0) then
        print(string.format("Puzzle 2: %d",middle))
        break
    elseif (diff < 0) then min = middle + 1
    else max = middle - 1
    end
end
