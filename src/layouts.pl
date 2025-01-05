% ------------------ %
% GameConfig Layouts %
% ------------------ %

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
    write('------------------------------'), nl,
    write('STAQS | Player\'s Name        '), nl,
    write('------------------------------'), nl,
    write('Please enter the player\'s name'), nl, nl,
    write('Player ').
layout_player_name(PlayerColor) :-
    write('------------------------------'), nl,
    write('STAQS | '), write(PlayerColor), write(' Player\'s Name'), nl,
    write('------------------------------'), nl,
    write('Please enter the player\'s name'), nl, nl,
    write('Player ').

% --------------------- %
% General Board Layouts %
% --------------------- %

% display_game(+GameState)
% Displays the game state to the screen.
display_game(GameState) :-
    GameState = [Board, _, _, _, _, _],
    % Display the board layout.
    clear, nl,
    write('  |---|---|---|---|---|'), nl,
    layout_board(Board, 5),
    write('    1   2   3   4   5  '), nl,
    % Display the players information.
    player_info(GameState).

% layout_board(+Board, +RowNumber)
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
% Prints the division line to the screen.
layout_division_line :-
    write('  |---|---|---|---|---|'), nl.

% ----------------- %
% Game Info Layouts %
% ----------------- %

% player_info(+GameState)
% Displays the player information to the screen.
player_info(GameState) :-
    % GameState expansion for easier access.
    GameState = [_, _, [_, BluePlayerName], [_, WhitePlayerName], RemainingBlue, RemainingWhite],
    % Calculate the number of spaces needed to align the player names.
    atom_length(BluePlayerName, BCount), atom_length(WhitePlayerName, WCount),
    BSpaceN is 11 - BCount, WSpaceN is 11 - WCount,
    dup_char(BSpaceN, ' ', BSpace), dup_char(WSpaceN, ' ', WSpace),
    % Fetch the game score.
    value(GameState, blue, BlueValue), value(GameState, white, WhiteValue),
    % Write the player information to the screen.
    nl, write(BluePlayerName), write(BSpace), write(' B | '), write(RemainingBlue), write(' | '), write(BlueValue),
    nl, write(WhitePlayerName), write(WSpace), write(' W | '), write(RemainingWhite), write(' | '), write(WhiteValue).

% current_player(+GameState)
% Displays the current player to the screen.
current_player(GameState) :-
    GameState = [_, CurrentPlayer, [_, BluePlayerName], [_, WhitePlayerName], _, _],
    nl, nl, write('Current Turn: '),
    (CurrentPlayer = blue -> write(BluePlayerName) ;
     CurrentPlayer = white -> write(WhitePlayerName)).

% show_player_pieces(+Board, +Player, +BluePlayerName, +WhitePlayerName)
% Displays the player's pieces coordinates and heights to the screen.
show_player_pieces(Board, Player, BluePlayerName, WhitePlayerName) :-
    % Get the list of pieces for the player.
    player_pieces(Board, Player, 1, ListOfPieces),
    % Sort the list of pieces by height.
    samsort(sort_pieces, ListOfPieces, ListOfPiecesSorted),
    % Display the list of pieces to the screen.
    nl, nl, (Player = blue -> write(BluePlayerName) ; write(WhitePlayerName)),
    write(' Pieces: [X,Y,H]'),
    nl, nl, write('    '), write(ListOfPiecesSorted).

% ------------------ %
% Game Winner Layout %
% ------------------ %

% display_winner(+GameState, +Winner)
% Displays the winner to the screen.
display_winner(GameState, Winner) :-
    % Display the winner to the screen.
    nl, nl, write(' --- GAME OVER ---'),
    (Winner = draw -> nl, nl, write('Wow! The game ended in a draw.'), nl, nl ;
        GameState = [_, _, [_, BluePlayerName], [_, WhitePlayerName], _, _],
        nl, nl, write('The winner is: '),
        (Winner = blue -> write(BluePlayerName) ; write(WhitePlayerName)),
        nl, nl, write('Congratulations!'), nl),
    nl, write(' -----------------'), nl, nl.
