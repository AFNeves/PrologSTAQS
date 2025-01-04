% ------------------------- %
% Piece Movement Predicates %
% ------------------------- %

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

% replace_row(+Row, +X, +Piece, -NewRow)
% Replaces the piece in the X position of the given row.
replace_row([], _, _, []).
replace_row([_ | Rest], 1, Piece, NewRow) :-
    NewRow = [Piece | Rest].
replace_row([Cell | Rest], X, Piece, NewRow) :-
    NewX is X - 1,
    replace_row(Rest, NewX, Piece, NewRest),
    NewRow = [Cell | NewRest].

% ----------------------- %
% Board Stages Predicates %
% ----------------------- %

% initial_board(-Board)
% Creates the initial state board.
initial_board(Board) :-
    Board = [
        [neutral, neutral, neutral, neutral, neutral],
        [neutral, neutral, neutral, neutral, neutral],
        [neutral, neutral, neutral, neutral, neutral],
        [neutral, neutral, neutral, neutral, neutral],
        [neutral, neutral, neutral, neutral, neutral]
    ].

% play_move_board(-Board)
% Board used in the play_move\0 predicate.
play_move_board(Board) :-
    Board = [
        [[blue, 1], neutral, neutral, [blue, 1], neutral],
        [neutral, neutral, neutral, [white, 1], [white, 1]],
        [neutral, neutral, [blue, 1], neutral, neutral],
        [neutral, [white, 1], neutral, neutral, neutral],
        [[blue, 1], neutral, neutral, neutral, [white, 1]]
    ].

% play_final_board(-Board)
% Board used in the play_final\0 predicate.
play_final_board(Board) :-
    Board = [
        [empty, [blue, 2], neutral, [blue, 1], neutral],
        [empty, [blue, 5], neutral, empty, [white, 1]],
        [empty, [blue, 2], empty, [white, 2], neutral],
        [empty, empty, [white, 6], empty, neutral],
        [empty, empty, empty, empty, [white, 1]]
    ].
