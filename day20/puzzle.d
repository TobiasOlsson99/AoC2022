import std.stdio;
import std.string: chomp;
import std.conv: parse;
import std.algorithm.iteration: map,sum;
import std.array: array;
import std.format: format;
import std.range: iota;

class Sequence {
    int[] data;
    int[] orderToPos;
    int[] posToOrder;
    int dataLength;

    void setData(int[] newData){
        data = newData.dup;
        dataLength = data.length;
        orderToPos = iota(dataLength).array;
        posToOrder = iota(dataLength).array;
    }

    void mix(int times) {
        for(int time = 0; time < times; time++){
            for (int ord = 0; ord < dataLength; ord++){
                int pos = orderToPos[ord];
                int offset = data[pos];
                int newPos = (pos + offset) % (dataLength-1);
                while(newPos < 0) newPos += (dataLength-1);
                if (newPos - pos > 0) {
                    for (int i = pos; i < newPos; i++){
                        data[i] = data[i+1];
                        int tmpOrder = posToOrder[i+1];
                        posToOrder[i] = tmpOrder;
                        orderToPos[tmpOrder] = i;
                    }
                    data[newPos] = offset;
                    posToOrder[newPos] = ord;
                    orderToPos[ord] = newPos;
                }
                if (newPos - pos < 0) {
                    for (int i = pos-1; i >= newPos; i--){
                        data[i+1] = data[i];
                        int tmpOrder = posToOrder[i];
                        posToOrder[i+1] = tmpOrder;
                        orderToPos[tmpOrder] = i+1;
                    }
                    data[newPos] = offset;
                    posToOrder[newPos] = ord;
                    orderToPos[ord] = newPos;
                }
            }
        }
    }

    int[] getCoordinates(){
        int zeroIndex = 0;
        for (int i = 0; i < dataLength; i++){
            if (data[i] == 0) {
                zeroIndex = i;
                break;
            }
        }
        int[] coordinates = [data[(zeroIndex + 1000)%dataLength], data[(zeroIndex + 2000)%dataLength], data[(zeroIndex + 3000)%dataLength]];
        return coordinates;
    }
}

void main(){
    File file = File("input.txt", "r");
    string line;
    int[] data;
    for (int i = 0; !file.eof(); i++){
        line = chomp(file.readln());
        if (line.length > 0) data ~= [parse!int(line)];
    }

    Sequence seq = new Sequence;

    seq.setData(data);
    seq.mix(1);
    writeln(format("Puzzle 1: %d", sum(seq.getCoordinates())));

    const long key = 811_589_153L;
    int modulo = key % (data.length-1);
    seq.setData(data.map!(a => a * modulo).array);
    seq.mix(10);
    writeln(format("Puzzle 2: %d", sum(seq.getCoordinates()) / modulo * key));
}