file = fopen('input.txt');
line = fgetl(file);
pattern = '(\d+),(\d+)';

cave = zeros(200,1000);

while ischar(line) % Fill cave with rocks
    matches = regexp(line, pattern, 'tokens');
    x1 = str2num(matches{1}{1});
    y1 = str2num(matches{1}{2}) + 1; % + 1 since matlab is not zero-indexed
    for groups=matches
        x2 = str2num(groups{1}{1});
        y2 = str2num(groups{1}{2}) + 1; 
        if x1==x2 %Assuming only straight lines
            if y1<y2
                cave(y1:y2,x1) = 1;
            else
                cave(y2:y1,x1) = 1;
            end
        else
           if x1<x2
                cave(y1,x1:x2) = 1;
            else
                cave(y1,x2:x1) = 1;
            end
        end
        x1 = x2;
        y1 = y2;
    end
    line = fgetl(file);
end
fclose(file);

maxy = 1;
for y = 1:200 %%Find lowest rock piece
    if sum(cave(y,:), 2) > 0
       maxy = y; 
    end
end

x = 500;
y = 1;
stabilizedSands = 0;
while (y < maxy+1) % Puzzle 1, run til found void
    [x, y] = stabilizeSand(maxy, cave);
    if y < maxy+1
        stabilizedSands = stabilizedSands + 1;
        cave(y,x) = 2;
    end
end

fprintf("Puzzle 1: %d\n", stabilizedSands);

while (y > 1) % Puzzle 2, run til reached top
    [x, y] = stabilizeSand(maxy, cave);
    stabilizedSands = stabilizedSands + 1;
    cave(y,x) = 2;
end

fprintf("Puzzle 2: %d\n", stabilizedSands);

%=====================================================================================
%                                       Functions

function [x, y] = stabilizeSand(maxy, cave)
    steps = 0;
    x=500;
    y=1;
    while y < maxy+1
       [dx, dy] = nextMove(x,y, cave);
       x = x + dx;
       y = y + dy;
       steps = steps + 1;
       if dx == 0 && dy == 0
           break;
       end
    end
end

function [dx, dy] = nextMove(x,y, cave)
    if cave(y+1,x) == 0
        dx = 0;
        dy = 1;
    elseif cave(y+1,x-1) == 0
        dx = -1;
        dy = 1;
    elseif cave(y+1,x+1) == 0
        dx = 1;
        dy = 1;
    else
        dx = 0;
        dy = 0;
    end
end