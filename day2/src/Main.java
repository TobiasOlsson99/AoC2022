
import java.io.FileNotFoundException;
import java.util.*;
import java.io.File;

public class Main {

    private static int puzzle2(List<Character> opponentList, List<Character> youList) {
        int score = 0;
        for(int i = 0; i < opponentList.size(); i++){
            int opponent = opponentList.get(i) - 'A'; // 0: Rock, 1: Paper, 2: Scissors
            int result = youList.get(i) - 'X'; // 0: lose, 1: draw, 2: win

            score += result * 3;

            int you = (opponent + (result - 1) + 3) % 3; //Lose, choose the one left, draw pick same, win pick on to the right

            score += you + 1;

        }
        return score;
    }

    private static int puzzle1(List<Character> opponentList, List<Character> youList) {
        int score = 0;
        for(int i = 0; i < opponentList.size(); i++){
            int opponent = opponentList.get(i) - 'A'; // 0: Rock, 1: Paper, 2: Scissors
            int you = youList.get(i) - 'X'; // 0: Rock, 1: Paper, 2: Scissors
            score += you + 1;
            int result = (you - opponent + 3) % 3;
            score += ((result + 1) % 3)*3;
        }
        return score;
    }

    public static void main(String[] args) throws FileNotFoundException {

        //Read input file
        Scanner reader = new Scanner(new File("src/input.txt"));
        List<Character> opponent = new LinkedList<Character>();
        List<Character> you = new LinkedList<Character>();
	    while(reader.hasNextLine()){
            char[] line = reader.nextLine().toCharArray();
            opponent.add(line[0]);
            you.add(line[2]);
        }

        System.out.println(puzzle1(opponent, you));
        System.out.println(puzzle2(opponent, you));
    }
}
