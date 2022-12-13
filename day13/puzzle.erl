-module(puzzle).

-import(lists,[filter/2, map/2]).

-export([main/0]).

main() ->
    Packets = readPackets(),
    io:fwrite("Puzzle 1: ~p~n", [puzzle1(Packets, 1)]),
    io:fwrite("Puzzle 2: ~p~n", [puzzle2(quicksort([[[2]], [[6]] | Packets]), 1)]).

quicksort([Pivot | Rest]) -> 
    quicksort([Packet || Packet <- Rest, element(2,comparePair(Packet, Pivot))]) ++ 
    [Pivot] ++
    quicksort([Packet || Packet <- Rest, element(2,comparePair(Pivot, Packet))]);
quicksort([]) ->
    [].

puzzle2([Packet | Rest], I) ->
    if
        (Packet == [[2]]) or (Packet == [[6]]) ->
            I * puzzle2(Rest, I + 1);
        true ->
            puzzle2(Rest, I + 1)
    end;
puzzle2(_, _) ->
    1.

puzzle1([A, B | Rest], I) ->
    Ordered = element(2,comparePair(A,B)),
    if
        Ordered ->
            I + puzzle1(Rest, I + 1);
        true ->
            puzzle1(Rest, I + 1)
    end;
puzzle1(_, _) ->
    0.

parse(S) -> 
    Tokens = element(2,erl_scan:string(S)), 
    element(2,erl_parse:parse_term(Tokens ++ [{dot,1}])).

readPackets() ->
    Str = binary_to_list(element(2,file:read_file("input.txt"))),
    Packets = filter(fun(L) -> length(L) > 0 end,string:tokens(filter(fun(C) -> C =/= $\r end, Str), "\n")),
    map(fun(L) -> parse(L) end, Packets).

comparePair([],[]) ->
    {true, true};
comparePair([],_) ->
    {false, true};
comparePair(_,[]) ->
    {false, false};
comparePair([H1 | Rest1], [H2 | Rest2]) ->
    {Same, RightOrder} = comparePair(H1,H2),
    if
        Same ->
            comparePair(Rest1, Rest2);
        true ->
            {false, RightOrder}
    end;
comparePair([H | Rest], Int) ->
    comparePair([H | Rest], [Int]);
comparePair(Int, [H | Rest]) ->
    comparePair([Int], [H | Rest]);
comparePair(Int1, Int2) ->
    {Int1 == Int2, Int1 =< Int2}.


