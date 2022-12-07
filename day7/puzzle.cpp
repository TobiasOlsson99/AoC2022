#include <iostream>
#include <fstream>
#include <string>
#include <list>

class Directory;

class Directory{
    public:
        Directory(std::string _name) {
            name = _name;
        };
        Directory(std::string _name, Directory *_parent) {
            name = _name;
            parent = _parent;
        };
        Directory *parent;
        std::string name;
        std::list<Directory> directories = {};
        int filesSize = 0;
        int dirSize() {
            int size = filesSize;
            for (auto& dir : directories){
                size += dir.dirSize();
            }
            return size;
        }
        Directory* findDirectory(std::string dirName) {
            for (auto& dir : directories){
                if (dir.name == dirName) return &dir;
            }
            throw("Couldn't find directory: " + dirName);
        }
        void printSelf(std::string prefix){
            std::cout << prefix << name + " - " << dirSize() << "\n";
            if (filesSize > 0) std::cout << prefix << filesSize << "\n";
            for (auto& dir : directories){
                dir.printSelf(prefix + "  ");
            }
        }
};

int totalSizeLimit(int limit, Directory *dir){
    int totalSize = 0;
    int dirSize = dir->dirSize();
    if (dirSize <= limit) totalSize += dirSize;
    for (auto& dir : dir->directories){
        totalSize += totalSizeLimit(limit, &dir);
    }
    return totalSize;
}

int findSmallestLimit(int limit, Directory *dir){
    int smallest = dir->dirSize();
    if (smallest < limit) smallest = 70000000;
    for (auto& dir : dir->directories){
        int newSmallest = findSmallestLimit(limit, &dir);
        if (smallest > newSmallest) smallest = newSmallest;
    }
    return smallest;
}

int main(int argc, char *argv[])
{
    std::ifstream file;
    file.open("input.txt");
    
    Directory root = Directory("/");
    root.parent = &root;
    Directory* currentDir = &root;

    std::string currentLine;
    std::getline(file, currentLine);
    while(file.good()){
        std::string command = currentLine.substr(2,2);
        if (command == "cd") {
            std::string arg = currentLine.substr(5,10);
            if (arg == "/") currentDir = &root;
            else if (arg == "..") currentDir = (currentDir->parent);
            else {
                currentDir = currentDir->findDirectory(arg);
            }
            std::getline(file, currentLine);
                if (currentLine == "") break;
        }
        else if (command == "ls") {
            while(file.good()){
                std::getline(file, currentLine);
                if (currentLine == "") break;
                if (currentLine.at(0) == '$') break;
                int space = currentLine.find(' ');
                std::string first = currentLine.substr(0, space);
                std::string second = currentLine.substr(space+1, 10);
                if (first == "dir") {
                    currentDir->directories.push_back(Directory(second, currentDir));
                }
                else {
                    currentDir->filesSize += std::stoi(first);
                }
            }
        }
    }
    

    std::cout << "Puzzle 1: " << totalSizeLimit(100000, &root) << "\n";
    int limit = root.dirSize() - 40000000;
    std::cout << "Puzzle 2: " << findSmallestLimit(limit, &root) << "\n";
}