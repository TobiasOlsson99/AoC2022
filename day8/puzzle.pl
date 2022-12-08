use List::Util qw/sum/;
use strict;

open(FH, '<', "input.txt") or die $!;
my @trees;

while(<FH>){
    chop($_); # Remove \n
    my @row = map {ord($_) - 48} split("", $_);
    if (length($_) > 0) {push @trees, \@row;}
}

close(FH);


my $rows = 98;
my $cols = 98;

my @visibleTrees;

#Horizontal
foreach my $y (0 .. $rows) {
    my $currentViewedFromLeft = -1;
    my $currentViewedFromRight = -1;
    foreach my $x (0 .. $cols){
        if ($trees[$y][$x] > $currentViewedFromLeft) {
            $visibleTrees[$y][$x] = 1;
            $currentViewedFromLeft = $trees[$y][$x];
        }
        if ($trees[$y][$cols - $x] > $currentViewedFromRight) {
            $visibleTrees[$y][$cols - $x] = 1;
            $currentViewedFromRight = $trees[$y][$cols - $x];
        }
    }
}

#Vertical
foreach my $x (0 .. $cols) {
    my $currentViewedFromTop = -1;
    my $currentViewedFromBottom = -1;
    foreach my $y (0 .. $rows){
        if ($trees[$y][$x] > $currentViewedFromTop) {
            $visibleTrees[$y][$x] = 1;
            $currentViewedFromTop = $trees[$y][$x];
        }
        if ($trees[$rows - $y][$x] > $currentViewedFromBottom) {
            $visibleTrees[$rows - $y][$x] = 1;
            $currentViewedFromBottom = $trees[$rows - $y][$x];
        }
    }
}

my $puzzle1 = 0;
foreach my $x (0 .. $cols) {
    foreach my $y (0 .. $rows){
        $puzzle1 += $visibleTrees[$y][$x];
    }
}

print "Puzzle 1: $puzzle1\n";

my $puzzle2 = 0;

foreach my $treeX (1 .. $cols - 1) {
    foreach my $treeY (1 .. $rows - 1){
        my $treeHeight = $trees[$treeY][$treeX];

        my $seenTrees = 0;
        foreach my $y ($treeY+1 .. $rows){$seenTrees += 1; last if ($trees[$y][$treeX] >= $treeHeight);}
        my $scenicScore = $seenTrees;

        $seenTrees = 0;
        foreach my $y (1 .. $treeY){$seenTrees += 1; last if ($trees[$treeY - $y][$treeX] >= $treeHeight);}
        $scenicScore *= $seenTrees;

        $seenTrees = 0;
        foreach my $x ($treeX+1 .. $cols){$seenTrees += 1; last if ($trees[$treeY][$x] >= $treeHeight);}
        $scenicScore *= $seenTrees;
        
        $seenTrees = 0;
        foreach my $x (1 .. $treeX){$seenTrees += 1; last if ($trees[$treeY][$treeX - $x] >= $treeHeight);}
        $scenicScore *= $seenTrees;

        if ($scenicScore > $puzzle2) {$puzzle2 = $scenicScore;}
    }
}

print "Puzzle 2: $puzzle2\n";