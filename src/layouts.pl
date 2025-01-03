% ----------------- %
% Layout Predicates %
% ----------------- %

% display_game(+GameState)
% Displays the game state to the screen.
display_game(GameState) :-
    clear, nl,
    GameState = [Board, _, _, _, _, _],
    layout_division_line,
    layout_board(Board, 5),
    write('    1   2   3   4   5  '), nl.

% layout_game_mode/0
% Prints the Game Mode Selector layout to the screen.
layout_game_mode :-
    write('--------------------------'), nl,
    write('STAQS | Game Mode         '), nl,
    write('--------------------------'), nl,
    write('Please choose a game mode:'), nl, nl,
    write(' 1. Player vs Player      '), nl,
    write(' 2. Player vs Computer    '), nl,
    write(' 3. Computer vs Player    '), nl,
    write(' 4. Computer vs Computer  '), nl, nl,
    write(' 0. Exit                  '), nl, nl,
    write('Chosen option: ').

% layout_difficulty/0
% Prints the Difficulty Selector layout to the screen.
layout_difficulty :-
    write('---------------------------'), nl,
    write('STAQS | Difficulty         '), nl,
    write('---------------------------'), nl,
    write('Please choose a difficulty:'), nl, nl,
    write(' 1. Random Moves           '), nl,
    write(' 2. Best Available Play    '), nl, nl,
    write(' 0. Exit                   '), nl, nl,
    write('Chosen option ').

% layout_player_name(+PlayerColor)
% Prints the Player Name Intake layout to the screen.
layout_player_name('') :-
    write('-------------------------------------------'), nl,
    write('STAQS | Player Name                        '), nl,
    write('-------------------------------------------'), nl,
    write('Please enter the player name               '), nl, nl,
    write('Don\'t forget to enclose it in single quotes'), nl, nl,
    write('Player name ').
layout_player_name(PlayerColor) :-
    write('-------------------------------------------'), nl,
    write('STAQS | '), write(PlayerColor), write(' Player Name'), nl,
    write('-------------------------------------------'), nl,
    write('Please enter the '), write(PlayerColor), write(' player name'), nl, nl,
    write('Don\'t forget to enclose it in single quotes'), nl, nl,
    write('Player name ').

% layout_board(+GameState)
% Prints the board layout to the screen.
layout_board([], _).
layout_board([Row | Rest], RowNumber) :-
    write(' '), write(RowNumber), write('| '), layout_row(Row), nl,
    layout_division_line,
    NextRowNumber is RowNumber - 1,
    layout_board(Rest, NextRowNumber).

% layout_row(+Row)
% Prints the row layout to the screen.
layout_row([]).
layout_row([Cell | Rest]) :-
    (Cell = empty -> write(' ') ;
     Cell = neutral -> write('#') ;
     Cell = [blue, Height] -> write('B') ;
     Cell = [white, Height] -> write('W')),
    write(' | '),
    layout_row(Rest).

% layout_division_line/0
% Prints the division line layout to the screen.
layout_division_line :-
    write('  |---|---|---|---|---|'), nl.