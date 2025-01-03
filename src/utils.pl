% -------------------- %
% Auxiliary Predicates %
% -------------------- %

% clear/0
% Clears the screen. Found the code in the following link.
% https://stackoverflow.com/questions/53262099/swi-prolog-how-to-clear-terminal-screen-with-a-keyboard-shortcut-or-global-pre
clear :- write('\33\[2J').

% initial_board(-Board).
% Creates the initial game board.
initial_board(Board) :-
    Board = [
        [neutral, neutral, neutral, neutral, neutral],
        [neutral, neutral, neutral, neutral, neutral],
        [neutral, neutral, neutral, neutral, neutral],
        [neutral, neutral, neutral, neutral, neutral],
        [neutral, neutral, neutral, neutral, neutral]
    ].

% count(+List, -N)
% Counts the number of elements in a list.
count([], 0).
count([H | T], N) :- count(T, N1), N is N1 + 1.

% replace_row(Row, X, Piece, NewRow)
% Replaces the piece in the X position of the given row.
replace_row([], _, _, []).
replace_row([Cell | Rest], 1, Piece, NewRow) :-
    NewRow = [Piece | Rest].
replace_row([Cell | Rest], X, Piece, NewRow) :-
    NewX is X - 1,
    replace_row(Rest, NewX, Piece, NewRest),
    NewRow = [Cell | NewRest].

% replace(+Board, +X, +Y, +Piece, -NewBoard)
% Replaces the piece at the given coordinates. Y is list relative, not coordinate relative.
replace([], _, _, _, []).
replace([Row | Rest], X, 1, Piece, NewBoard) :-
    replace_row(Row, X, Piece, NewRow),
    NewBoard = [NewRow | Rest].
replace([Row | Rest], X, Y, Piece, NewBoard) :-
    NewY is Y - 1,
    replace(Rest, X, NewY, Piece, NewRest),
    NewBoard = [Row | NewRest].