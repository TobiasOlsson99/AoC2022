sub digit2snafu($digit) {
    if $digit eq -2 {"="} elsif $digit eq -1 {"-"} else {+$digit};
}

sub snafu($num) {
    my @digits = map {+$_}, ("0" ~ $num.base(5)).comb;
    my $snafu = "";
    my $carry = 0;
    for reverse @digits -> $digit {
        if ($digit + $carry) > 2 {
            $snafu = digit2snafu($digit + $carry - 5) ~ $snafu;
            $carry = 1;
        } else {
            $snafu = digit2snafu($digit + $carry) ~ $snafu;
            $carry = 0;
        }
    }
    $snafu.substr(1);
}

my int $res = 0;
for 'input.txt'.IO.lines -> $line {
    my int $n = 0;
    for $line.comb -> $c {
        $n *= 5;
        if $c eq "-" {$n -= 1} elsif $c eq "=" {$n -= 2} else {$n += +$c};
    }
    $res += $n;
}

say "Puzzle 1: " ~ snafu($res);