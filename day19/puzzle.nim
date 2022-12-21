import std/nre
import std/strutils
import std/strformat

const
    maxOreRobots = 4
    maxClayRobots = 9
    maxObsidianRobots = 8

type Blueprint = ref object
    number:                     int
    oreRobotCost:               int
    clayRobotCost:              int
    obsidianRobotOreCost:       int
    obsidianRobotClayCost:      int
    geodeRobotOreCost:          int
    geodeRobotObsidianCost:     int

proc blueprintFromMatch(match : RegexMatch) : Blueprint = 
    result = Blueprint(
        number:                     match.captures[0].parseInt,
        oreRobotCost:               match.captures[1].parseInt,
        clayRobotCost:              match.captures[2].parseInt,
        obsidianRobotOreCost:       match.captures[3].parseInt,
        obsidianRobotClayCost:      match.captures[4].parseInt,
        geodeRobotOreCost:          match.captures[5].parseInt,
        geodeRobotObsidianCost:     match.captures[6].parseInt
    )

type GameState = ref object
    blueprint:                  Blueprint
    minute:                     int
    ore:                        int
    clay:                       int
    obsidian:                   int
    geodes:                     int
    oreRobots:                  int
    clayRobots:                 int
    geodeRobots:                int
    obsidianRobots:             int
    allowedToBuyOre:            bool
    allowedToBuyClay:           bool

proc newGame(blueprint : Blueprint) : Gamestate = 
    result = Gamestate(
        blueprint:                  blueprint,
        minute:                     1,
        ore:                        0,
        clay:                       0,
        obsidian:                   0,
        geodes:                     0,
        oreRobots:                  1,
        clayRobots:                 0,
        geodeRobots:                0,
        obsidianRobots:             0,
        allowedToBuyOre:            true,
        allowedToBuyClay:           true
    )

proc copy(self : GameState) : GameState = 
    result = Gamestate(
        blueprint:                  self.blueprint,
        minute:                     self.minute,
        ore:                        self.ore,
        clay:                       self.clay,
        obsidian:                   self.obsidian,
        geodes:                     self.geodes,
        oreRobots:                  self.oreRobots,
        clayRobots:                 self.clayRobots,
        geodeRobots:                self.geodeRobots,
        obsidianRobots:             self.obsidianRobots
    )

proc endTurn(self : GameState) =
    self.minute += 1
    self.ore += self.oreRobots
    self.clay += self.clayRobots
    self.obsidian += self.obsidianRobots
    self.geodes += self.geodeRobots

proc robotContinuations(self : GameState, maxMinutes : int) : seq[GameState] =
    result = newSeq[GameState]()

    if self.obsidianRobots > 0: # Save up to geode robot
        let buyGeodeRobot = self.copy
        while(buyGeodeRobot.minute < maxMinutes and 
            (buyGeodeRobot.ore < self.blueprint.geodeRobotOreCost or buyGeodeRobot.obsidian < self.blueprint.geodeRobotObsidianCost)):
            buyGeodeRobot.endTurn
        buyGeodeRobot.endTurn
        buyGeodeRobot.ore -= buyGeodeRobot.blueprint.geodeRobotOreCost
        buyGeodeRobot.obsidian -= buyGeodeRobot.blueprint.geodeRobotObsidianCost
        buyGeodeRobot.geodeRobots += 1
        result.add(buyGeodeRobot)

    if self.clayRobots > 0 and self.obsidianRobots < maxObsidianRobots:
        let buyObsidianRobot = self.copy
        while(buyObsidianRobot.minute < maxMinutes and 
            (buyObsidianRobot.ore < self.blueprint.obsidianRobotOreCost or buyObsidianRobot.clay < self.blueprint.obsidianRobotClayCost)):
            buyObsidianRobot.endTurn
        buyObsidianRobot.endTurn
        buyObsidianRobot.ore -= buyObsidianRobot.blueprint.obsidianRobotOreCost
        buyObsidianRobot.clay -= buyObsidianRobot.blueprint.obsidianRobotClayCost
        buyObsidianRobot.obsidianRobots += 1
        result.add(buyObsidianRobot)

    if self.clayRobots < maxClayRobots:
        let buyClayRobot = self.copy
        while(buyClayRobot.minute < maxMinutes and buyClayRobot.ore < self.blueprint.clayRobotCost):
                buyClayRobot.endTurn
        buyClayRobot.endTurn
        buyClayRobot.ore -= buyClayRobot.blueprint.clayRobotCost
        buyClayRobot.clayRobots += 1
        result.add(buyClayRobot)

    if self.oreRobots < maxOreRobots:
        let buyOreRobot = self.copy
        while(buyOreRobot.minute < maxMinutes and buyOreRobot.ore < self.blueprint.oreRobotCost):
            buyOreRobot.endTurn
        buyOreRobot.endTurn
        buyOreRobot.ore -= buyOreRobot.blueprint.oreRobotCost
        buyOreRobot.oreRobots += 1
        result.add(buyOreRobot)

proc quadraticSeries(n : int) : int =
    if (n <= 0):
        result = 0
    else:
        result = n + quadraticSeq(n-1)

proc pruneGameState(self : GameState, maxSoFar : int, maxMinutes : int) : bool =
    result = quadraticSeq(maxMinutes-self.minute) + (maxMinutes-self.minute+1)*self.geodeRobots + self.geodes < maxSoFar

proc maximizeGeodes(self : GameState, maxSoFar : int, maxMinutes : int) : int =
    if self.pruneGameState(maxSoFar, maxMinutes):
        result = 0
    elif self.minute > maxMinutes:
        result = self.geodes
    else:
        let newStates = self.robotContinuations(maxMinutes)
        result = 0
        for state in newStates:
            result = max(result, state.maximizeGeodes(result, maxMinutes))

let pattern = re"\S+ (\d+)[^\d]+(\d+)[^\d]+(\d+)[^\d]+(\d+)[^\d]+(\d+)[^\d]+(\d+)[^\d]+(\d+) \S+"
let input = readFile("input.txt")
var blueprints = newSeq[Blueprint]()

for match in input.findIter(pattern):
    blueprints.add(blueprintFromMatch(match))

var puzzle1 = 0
for blueprint in blueprints:
    let geodes = blueprint.newGame.maximizeGeodes(0, 24)
    echo geodes
    puzzle1 += geodes * blueprint.number
echo fmt"Puzzle 1: {puzzle1}"

var puzzle2 = 1
for i in 0..2:
    let geodes = blueprints[i].newGame.maximizeGeodes(0, 32)
    echo geodes
    puzzle2 *= geodes
echo fmt"Puzzle 2: {puzzle2}"