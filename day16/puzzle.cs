using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.IO;
using System.Text.RegularExpressions;

namespace Puzzle
{
    class Program {         
        class Valve{
            public string name;
            public List<string> leadsToNames = new List<string>();
            public List<Valve> leadsTo = new List<Valve>();
            public int flowRate;

            private static Regex lineRegex = new Regex(@"Valve (\w\w) .+=(\d+);.+valves? (.+)", RegexOptions.Compiled);
            private static Regex connectingRegex = new Regex(@"([A-Z]{2})", RegexOptions.Compiled);
            public Valve(string line){
                Match lineMatch = lineRegex.Match(line);
                name = lineMatch.Groups[1].Value;
                flowRate = Int32.Parse(lineMatch.Groups[2].Value);
                foreach (Match connection in connectingRegex.Matches(lineMatch.Groups[3].Value)){
                    leadsToNames.Add(connection.Value);
                }
            }
        }

        class Node{
            public Valve valve;
            public Dictionary<Node,int> distances = new Dictionary<Node,int>();

            public Node(Valve v){
                valve = v;
            }

            public void calculateDistances(List<Node> nodes){
                List<Valve> visited = new List<Valve>();
                Queue<Valve> next = new Queue<Valve>();
                Queue<int> nextCost = new Queue<int>();
                next.Enqueue(valve);
                nextCost.Enqueue(1);
                while(next.Count > 0){
                    Valve v = next.Dequeue();
                    int cost = nextCost.Dequeue();
                    if (!visited.Contains(v)){
                        visited.Add(v);
                        foreach(Valve v2 in v.leadsTo){ 
                            next.Enqueue(v2);
                            nextCost.Enqueue(cost+1);
                        }
                        foreach(Node node in nodes){
                            if (node != this && node.valve == v){
                                distances.Add(node, cost);
                            }
                        }
                    }
                }
                //printDistances();
            }

            public void printDistances(){
                Console.WriteLine("Valve: " + valve.name);
                foreach (KeyValuePair<Node, int> kvp in distances)
                {
                    Console.WriteLine("  Name = {0}, Distance = {1}", kvp.Key.valve.name, kvp.Value);
                }
            }

            public int maximizePressure(List<Node> nodes, int minutes){
                Dictionary<Node,int> pressureScore = new Dictionary<Node,int>();
                foreach (Node node in nodes){
                    if (distances[node] < minutes){
                        pressureScore.Add(node, node.getPressure(minutes - distances[node]));
                    }
                }
                int maximumPressure = 0;
                foreach (Node node in pressureScore.Keys){
                    List<Node> newNodes = new List<Node>(nodes);
                    newNodes.Remove(node);
                    maximumPressure = Math.Max(maximumPressure, pressureScore[node] + 
                                                                node.maximizePressure(newNodes, minutes - distances[node]));
                }
                return maximumPressure;
            }

            public int getPressure(int minutes) {
                return minutes * valve.flowRate;
            }

        }

        static IEnumerable<List<T>> chooseN<T>(List<T> list, int n){
            if (n == 1){
                foreach (T elem in list){
                    List<T> returnList = new List<T>();
                    returnList.Add(elem);
                    yield return returnList;
                }
            }
            else{
                for (int i = 0; i < list.Count-n+1; i++){
                    List<T> nextList = new List<T>(list);
                    T elem = nextList[i];
                    for(int j = i; j >= 0; j--) nextList.RemoveAt(j);
                    foreach (List<T> returnList in chooseN(nextList, n-1)){
                        returnList.Add(elem);
                        yield return returnList;
                    }
                }
            }
        }

        static void Main(string[] args)
        {
            Dictionary<string,Valve> valveDict = new Dictionary<string,Valve>();
            List<Valve> valveList = new List<Valve>();
            List<Node> nodes = new List<Node>();
            Node startingNode = null;

            foreach (string line in File.ReadLines("input.txt"))
            {  
                Valve newValve = new Valve(line);
                valveDict.Add(newValve.name, newValve);
                valveList.Add(newValve);
            }
            foreach (Valve valve in valveList) {
                foreach (string valveName in valve.leadsToNames){
                    valve.leadsTo.Add(valveDict[valveName]);
                }
                if(valve.flowRate > 0){
                    nodes.Add(new Node(valve));
                }
                if(valve.name == "AA"){
                    startingNode = new Node(valve);
                }
            }
            foreach (Node node in nodes) node.calculateDistances(nodes);
            startingNode.calculateDistances(nodes);
            Console.WriteLine("Puzzle 1: {0}", startingNode.maximizePressure(nodes, 30));
            
            int maxPuzzle2 = 0;
            foreach(List<Node> subset in chooseN(nodes, 6)){
                List<Node> others = nodes.Where(x => !subset.Contains(x)).ToList();
                int first = startingNode.maximizePressure(subset, 26);
                int second = startingNode.maximizePressure(others, 26);
                maxPuzzle2 = Math.Max(maxPuzzle2, first + second);
            }
            Console.WriteLine("Puzzle 2: {0}", maxPuzzle2);

        }
    }
}