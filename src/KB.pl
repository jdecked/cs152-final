% Adapted from Gauthier Picard's prolog implementation of tic-tac-toe with regular
% minimax (retrieved from http://www.emse.fr/~picard/cours/ai/minimax/#fn.2) to
% create connect four using minimax with alpha-beta pruning.
% Note that this algorithm doesn't care about storing state over time — in every
% case, it's given the state of the board after one move by the human player.
% Therefore, all we need to do is calculate the next best move for the AI. This
% approach leaves Prolog to do what it does best — figure out the answer given
% a description of what's wanted — instead of having it handle pieces of this
% game that are better handled procedurally (vs. declaratively).

:- use_module(library(clpfd)).

% Minimax algorithm with alpha-beta pruning
minimax(CurrentMove, 0, _, _, _, Val) :-
    utility(CurrentMove, 0, Val).
minimax(CurrentMove, Depth, Alpha, Beta, BestNextMove, Val) :-
    Depth > 0,
    bagof(
        NextMove,
        move(CurrentMove, NextMove),
        NextMoves
    ),
    best(NextMoves, Depth, Alpha, Beta, BestNextMove, Val), !.
minimax(CurrentMove, Depth, _, _, _, Val) :-
    utility(CurrentMove, Depth, Val).

next_player(1, 2).
next_player(2, 1).

% Determining legal moves
move([Player, play, Board], [NextPlayer, win, NextBoard]) :-
    next_player(Player, NextPlayer),
    transpose(Board, TransposedBoard),
    move_aux(Player, TransposedBoard, TransposedNextBoard),
    transpose(TransposedNextBoard, NextBoard),
    win(Player, NextBoard), !.

move([Player, play, Board], [NextPlayer, draw, NextBoard]) :-
    next_player(Player, NextPlayer),
    transpose(Board, TransposedBoard),
    move_aux(Player, TransposedBoard, TransposedNextBoard),
    transpose(TransposedNextBoard, NextBoard),
    draw(Player, NextBoard), !.

move([Player, play, Board], [NextPlayer, play, NextBoard]) :-
    next_player(Player, NextPlayer),
    transpose(Board, TransposedBoard),
    move_aux(Player, TransposedBoard, TransposedNextBoard),
    transpose(TransposedNextBoard, NextBoard).

move_aux(Player, [[0 | RestCol] | Rest], [[Player | RestCol] | Rest]).
move_aux(Player, [[Elem | RestCol] | Rest], [[Elem | NextRestCol] | Rest]) :-
    Elem \== 0,
    move_aux(Player, [RestCol], [NextRestCol]).
move_aux(Player, [Board | RestBoard], [Board | NextRestBoard]) :-
    move_aux(Player, RestBoard, NextRestBoard).

% Determining close-enough-to-best move
min_to_move([1, _, _]).
max_to_move([2, _, _]).

best([Move | RestMoves], Depth, Alpha, Beta, BestMove, BestVal) :-
    NextDepth #= Depth - 1,
    minimax(Move, NextDepth, Alpha, Beta, _, Val),
    approximate_best(RestMoves, Depth, Alpha, Beta, Move, Val, BestMove, BestVal).

approximate_best([], _, _, _, Move, Val, Move, Val) :- !.
approximate_best(_, _, Alpha, Beta, Move, Val, Move, Val) :-
    min_to_move(Move),
    Val > Beta, !;
    max_to_move(Move),
    Val < Alpha, !.
approximate_best(Moves, Depth, Alpha, Beta, Move1, Val1, BestMove, BestVal) :-
    adjust_bounds(Alpha, Beta, Move1, Val1, NextAlpha, NextBeta),
    best(Moves, Depth, NextAlpha, NextBeta, Move2, Val2),
    better_move(Move1, Val1, Move2, Val2, BestMove, BestVal).

adjust_bounds(Alpha, Beta, Move, Val, Val, Beta) :-
    min_to_move(Move),
    Val > Alpha, !.
adjust_bounds(Alpha, Beta, Move, Val, Alpha, Val) :-
    max_to_move(Move),
    Val < Beta, !.
adjust_bounds(Alpha, Beta, _, _, Alpha, Beta).

better_move(Move1, Val1, _, Val2, Move1, Val1) :-
    min_to_move(Move1),
    Val1 > Val2, !;
    max_to_move(Move1),
    Val1 < Val2, !.
better_move(_, _, Move2, Val2, Move2, Val2).

% Utility function: How many rows/columns/diagonals can Player still win?
% What's the difference between this number for human vs. the AI?
% Player 1 (MIN) wants odd threats, and to defend against even threats.
% Player 2 (MAX) wants even threats, and to defend against odd threats.
% (A threat is a square that, if taken by the opponent, wins them the game.)
popleft([_ | T], T).
count_threats(_, [], 0).
count_threats(Player, Row, Count) :-
    Row = [0, Player, Player, Player | _],
    popleft(Row, RestRow),
    count_threats(Player, RestRow, Count2),
    Count is 1 + Count2, !;
    Row = [Player, Player, Player, 0 | _],
    popleft(Row, RestRow),
    count_threats(Player, RestRow, Count2),
    Count is 1 + Count2, !.
count_threats(Player, Row, Count) :-
    popleft(Row, RestRow),
    count_threats(Player, RestRow, Count2),
    Count is Count2, !.

count_horizontal_threats(_, [], 0).
count_horizontal_threats(Player, [Row | RestRows], Count) :-
    count_threats(Player, Row, Count2),
    count_horizontal_threats(Player, RestRows, Count3),
    Count is Count2 + Count3, !.

count_vertical_threats(Player, Board, Count) :-
    transpose(Board, TransposedBoard),
    count_horizontal_threats(Player, TransposedBoard, Count).

count_diagonal_threats(_, [], 0).
count_diagonal_threats(Player, Board, Count) :-
    count_down_diagonal_threats(Player, Board, Count2),
    count_up_diagonal_threats(Player, Board, Count3),
    Count is Count2 + Count3, !.

count_down_diagonal_threats(_, [[], [], [], [], [], []], 0).
count_down_diagonal_threats(Player, Board, Count) :-
    Board = [Row1, Row2, Row3, Row4 | _],
    Row1 = [Player | _],
    Row2 = [_, Player | _],
    Row3 = [_, _, Player | _],
    Row4 = [_, _, _, 0 | _],
    pop_column(Board, RestBoard),
    count_down_diagonal_threats(Player, RestBoard, Count2),
    Count is 1 + Count2, !;
    Board = [Row1, Row2, Row3, Row4 | _],
    Row1 = [0 | _],
    Row2 = [_, Player | _],
    Row3 = [_, _, Player | _],
    Row4 = [_, _, _, Player | _],
    pop_column(Board, RestBoard),
    count_down_diagonal_threats(Player, RestBoard, Count2),
    Count is 1 + Count2, !.
count_down_diagonal_threats(Player, Board, Count) :-
    pop_column(Board, RestBoard),
    count_down_diagonal_threats(Player, RestBoard, Count2),
    Count is Count2, !.

count_up_diagonal_threats(_, [[], [], [], [], [], []], 0).
count_up_diagonal_threats(Player, Board, Count) :-
    Board = [Row1, Row2, Row3, Row4 | _],
    Row1 = [_, _, _, 0 | _],
    Row2 = [_, _, Player | _],
    Row3 = [_, Player | _],
    Row4 = [Player | _],
    pop_column(Board, RestBoard),
    count_up_diagonal_threats(Player, RestBoard, Count2),
    Count is 1 + Count2, !;
    Board = [Row1, Row2, Row3, Row4 | _],
    Row1 = [_, _, _, Player | _],
    Row2 = [_, _, Player | _],
    Row3 = [_, Player | _],
    Row4 = [0 | _],
    pop_column(Board, RestBoard),
    count_up_diagonal_threats(Player, RestBoard, Count2),
    Count is 1 + Count2, !.
count_up_diagonal_threats(Player, Board, Count) :-
    pop_column(Board, RestBoard),
    count_up_diagonal_threats(Player, RestBoard, Count2),
    Count is Count2, !.

count_all_threats(Player, Board, Count) :-
    count_horizontal_threats(Player, Board, Count2),
    count_vertical_threats(Player, Board, Count3),
    count_diagonal_threats(Player, Board, Count4),
    Count is Count2 + Count3 + Count4, !.

eval_threats(Board, Val) :-
    count_all_threats(1, Board, MinCount),
    count_all_threats(2, Board, MaxCount),
    Val is MaxCount - MinCount.

utility([_, _, Board], _, Val) :-
    eval_threats(Board, Val2),
    Val #= Val2 * 10, !.

utility([2, win, _], Depth, 10 + Depth).
utility([1, win, _], Depth, -10 - Depth).
utility([_, draw, _], _, 0).

% Final game states (win/draw)
win(Player, Board) :-
    horizontal_win(Player, Board), !;
    vertical_win(Player, Board), !;
    append(_, [Row1, Row2, Row3, Row4 | _], Board),
    (diagonal_win(Player, [Row1, Row2, Row3, Row4]), !;
    diagonal_win(Player, [Row4, Row3, Row2, Row1]), !).

draw(_, Board) :-
    flatten(Board, FlatBoard),
    not(member(0, FlatBoard)).

four_in_a_row(Element, [Element, Element, Element, Element | _]) :- !.
four_in_a_row(Element, [_ | Rest]) :- four_in_a_row(Element, Rest).

horizontal_win(Player, [Row | RestRows]) :-
    four_in_a_row(Player, Row);
    horizontal_win(Player, RestRows).

vertical_win(Player, Board) :-
    transpose(Board, TransposedBoard),
    horizontal_win(Player, TransposedBoard).

diagonal_win(Player, [[Player | _] | RestBoard]) :-
    pop_column(RestBoard, NextRestBoard),
    diagonal_win_helper(Player, NextRestBoard).
diagonal_win(Player, Board) :-
    pop_column(Board, RestBoard),
    diagonal_win(Player, RestBoard).

diagonal_win_helper(Player, [[Player | _]]).
diagonal_win_helper(Player, [[Player | _] | RestBoard]) :-
    pop_column(RestBoard, NextRestBoard),
    diagonal_win_helper(Player, NextRestBoard).

pop_column([], []).
pop_column([[_ | Rest] | RestColumns], [Rest | New]) :-
    pop_column(RestColumns, New).

best_move(Move, Depth, NextMove) :-
    Alpha #= -Depth - 1,
    Beta #= Depth + 1,
    minimax(Move, Depth, Alpha, Beta, NextMove, _).
