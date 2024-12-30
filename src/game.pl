:- use_module(library(lists)).
:- use_module(library(between)).

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

% --------------------- %
% Read/Input Predicates %
% --------------------- %

% read_and_validate_int(+MaxValidOption, -Input)
% Reads the input from the user and validates it.
read_and_validate_int(MaxValidOption, Input) :-
    repeat,
        read(Input),
    (between(0, MaxValidOption, Input) -> ! ;
        nl, write('Please enter a valid option.'), nl,
        nl, write('Chosen option: '), fail).

% read_and_validate_string(-PlayerName)
% Reads the input from the user and validates it.
read_and_validate_string(PlayerName) :-
    repeat,
        read(PlayerName),
    (PlayerName \= '' -> ! ;
        nl, write('Please enter a valid name.'), nl,
        nl, write('Player name: '), fail).

% ----------------- %
% Layout Predicates %
% ----------------- %

% display_game(+GameState)
% Displays the game state to the screen.
display_game(GameState) :-
    clear, nl,
    write('     1   2   3   4   5  '), nl,
    write('   |---|---|---|---|---|'), nl,
    GameState = [Board, _, _, _, _, _],
    layout_board(Board, 5).

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
    write(' '), write(RowNumber), layout_row(Row), write(' |'), nl,
    layout_division_line,
    NextRowNumber is RowNumber - 1,
    layout_board(Rest, NextRowNumber).

% layout_row(+Row)
% Prints the row layout to the screen.
layout_row([]).
layout_row([Cell | Rest]) :-
    write(' | '),
    (Cell = empty -> write(' ') ;
     Cell = neutral -> write('#') ;
     Cell = [blue, Height] -> write('B') ;
     Cell = [white, Height] -> write('W')),
    layout_row(Rest).

% layout_division_line/0
% Prints the division line layout to the screen.
layout_division_line :-
    write('   |---|---|---|---|---|'), nl.

% -------------- %
% PLAY Predicate %
% -------------- %

play :-
    % Create the GameConfig and initial GameState.
    create_config(GameConfig),
    initial_state(GameConfig, GameState),
    repeat,
        % Check if the game is over.
        game_over(GameState, Winner),
        (Winner == 0 ->
            % GameState expansion for easier access.
            GameState = [Board, CurrentPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite],
            % Display the game state.
            display_game(GameState),
            % Placement of the initial pieces.
            (CurrentPlayer == blue , RemainingBlue > 0 ; CurrentPlayer == white , RemainingWhite > 0 ->
                % Display the instructions for placing a new piece.
                nl, write('To place a new piece, enter the coordinates in the format "X Y".'), nl,
                % Loop to check for valid placements.
                repeat,
                    % Ask the user for the coordinates.
                    nl, write('Please enter the coordinates: '),
                    % Read and validate the coordinates.
                    read_and_validate_place(Board, Move),
                    % Validate the move.
                    validate_move(Board, Move, Valid),
                    (Valid == false ->
                        % Invalid move, so display an error message.
                        nl, write('Invalid placement.'), nl, fail ;
                        % Valid move, so place the piece.
                        move(GameState, Move, NewGameState), !) ;
                % Display the instructions for moving a piece.
                    nl, write('To move a piece, enter the coordinates of the piece to move and the direction in the format "X Y up/down/left/right".'), nl,
                    % Loop to check for valid placements.
                    repeat,
                        % Ask the user for the coordinates.
                        nl, write('Please enter the move: '),
                        % Read and validate the coordinates.
                        read_and_validate_move(Board, Move),
                        % Validate the move.
                        validate_move(Board, Move, Valid),
                        (Valid == false ->
                            % Invalid move, so display an error message.
                            nl, write('Invalid move.'), nl, fail ;
                            % Valid move, so place the piece.
                            move(GameState, Move, NewGameState), !)), ! ;
        Winner \= 0 ->
            % Display the game state.
            display_game(GameState),
            % Display the winner.
            (Winner == draw -> nl, write('The game ended in a draw.'), nl ;
             Winner == blue -> nl, write('The blue player won.'), nl ;
             Winner == white -> nl, write('The white player won.'), nl), !).

% ------------------------ %
% Create Config Predicates %
% ------------------------ %

% create_config(-GameConfig)
% Displays the configuration menus and creates the GameConfig.
create_config(GameConfig) :-
    game_mode_selector(GameMode),
    (GameMode \= 1 -> difficulty_selector(Difficulty) ; Difficulty = 0),
    (GameMode = 1 -> player_name_intake('Blue', BluePlayerName), player_name_intake('White', WhitePlayerName) ;
     GameMode = 2 -> player_name_intake('', BluePlayerName), WhitePlayerName = 'Computer' ;
     GameMode = 3 -> player_name_intake('', WhitePlayerName), BluePlayerName = 'Computer' ;
     GameMode = 4 -> BluePlayerName = 'Computer_B', WhitePlayerName = 'Computer_W' ),
    GameConfig = [GameMode, Difficulty, BluePlayerName, WhitePlayerName].

% game_mode_selector(-GameMode)
% Asks the user to choose a game mode.
game_mode_selector(GameMode) :-
    clear,
    layout_game_mode,
    read_and_validate_int(4, GameMode),
    GameMode \= 0.

% difficulty_selector(-Difficulty)
% Asks the user to choose a difficulty.
difficulty_selector(Difficulty) :-
    clear,
    layout_difficulty,
    read_and_validate_int(2, Difficulty),
    Difficulty \= 0.

% player_name_intake(+PlayerColor, -PlayerName)
% Asks the user to input the player name.
player_name_intake(PlayerColor, PlayerName) :-
    clear,
    layout_player_name(PlayerColor),
    read_and_validate_string(PlayerName),
    PlayerName \= ''.

% ------------------------ %
% Initial State Predicates %
% ------------------------ %

% initial_state(+GameConfig, -GameState).
% Creates the initial game state based on the given game configuration.
initial_state(GameConfig, GameState) :-
    CurrentPlayer = 1, RemainingBlue = 4, RemainingWhite = 4,
    initial_board(Board), player_config(GameConfig, BluePlayer, WhitePlayer),
    GameState = [Board, CurrentPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite].

% player_config(+GameConfig, -BluePlayer, -WhitePlayer).
% Returns the player configuration based on the given game configuration.
player_config([1, _, BluePlayerName, WhitePlayerName], ['H', BluePlayerName], ['H', WhitePlayerName]).
player_config([2, _, BluePlayerName, WhitePlayerName], ['H', BluePlayerName], ['C', WhitePlayerName]).
player_config([3, _, BluePlayerName, WhitePlayerName], ['C', BluePlayerName], ['H', WhitePlayerName]).
player_config([4, _, BluePlayerName, WhitePlayerName], ['C', BluePlayerName], ['C', WhitePlayerName]).

% --------------------- %
% Move Piece Predicates %
% --------------------- %

/*
    TODO:
    This predicate is responsible for move validation and
    execution, receiving the current game state and the move to be executed, and (if the move is valid)
    returns the new game state after the move is executed.
*/
% move(+GameState, +Move, -NewGameState)
move(GameState, Move, NewGameState) :-
    GameState = [Board, CurrentPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite],
    validate_move(Board, Move, Valid),
    (Valid == false -> NewGameState = GameState ;
     execute_move(Board, Move, NewBoard),
     change_player(CurrentPlayer, NextPlayer),
     NewGameState = [NewBoard, NextPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite]).

% ---------------------- %
% Valid Moves Predicates %
% ---------------------- %

% valid_moves(+GameState, -ListOfMoves)
% Returns the list of valid moves for the given game state.
valid_moves(GameState, ListOfMoves) :-
    GameState = [Board, CurrentPlayer, _, _, _, _],
    horizontal_moves(Board, 5, CurrentPlayer, HorizontalMoves),
    transpose(Board, TransposedBoard),
    horizontal_moves(TransposedBoard, 1, CurrentPlayer, VerticalMoves),
    append(HorizontalMoves, VerticalMoves, ListOfMoves).

/* Horizontal Moves */

% horizontal_moves(+Board, +CordY, +Color, -HorizontalMoves)
% Returns the list of valid horizontal moves for the given player.
horizontal_moves([], _, _, []).
horizontal_moves([Row | Rest], CordY, Color, HorizontalMoves) :-
    valid_hmoves_row(Row, 1, CordY, Color, HorizontalMovesRow),
    NewCordY is CordY - 1,
    horizontal_moves(Rest, NewCordY, Color, RestHorizontalMoves),
    append(HorizontalMovesRow, RestHorizontalMoves, HorizontalMoves).

% valid_hmoves_row(+Row, +CordX, +CordY, +Color, -HorizontalMovesRow)
% Returns the list of valid horizontal moves in a row for the given player.
valid_hmoves_row([], _, _, _, []).
valid_hmoves_row([[Color, _], neutral | Rest], CordX, CordY, Color, HorizontalMovesRow) :-
    NewCordX is CordX + 1,
    valid_hmoves_row([neutral | Rest], NewCordX, CordY, Color, RestHorizontalMovesRow),
    append([[CordX, CordY, right]], RestHorizontalMovesRow, HorizontalMovesRow).
valid_hmoves_row([neutral, [Color, _] | Rest], CordX, CordY, Color, HorizontalMovesRow) :-
    NewCordX is CordX + 1,
    valid_hmoves_row([[Color, _] | Rest], NewCordX, CordY, Color, RestHorizontalMovesRow),
    append([[NewCordX, CordY, left]], RestHorizontalMovesRow, HorizontalMovesRow).
valid_hmoves_row([_ | Rest], CordX, CordY, Color, HorizontalMovesRow) :-
    NewCordX is CordX + 1,
    valid_hmoves_row(Rest, NewCordX, CordY, Color, HorizontalMovesRow).

/* Vertical Moves */

% vertical_moves(+Board, +CordX, +Color, -VerticalMoves)
% Returns the list of valid vertical moves for the given player.
vertical_moves([], _, _, []).
vertical_moves([Row | Rest], CordX, Color, VerticalMoves) :-
    valid_vmoves_row(Row, CordX, 5, Color, VerticalMovesRow),
    NewCordX is CordX + 1,
    vertical_moves(Rest, NewCordX, Color, RestVerticalMoves),
    append(VerticalMovesRow, RestVerticalMoves, VerticalMoves).

% valid_vmoves_row(+Row, +CordX, +CordY, +Color, -VerticalMovesRow)
% Returns the list of valid vertical moves in a row for the given player.
valid_vmoves_row([], _, _, _, []).
valid_vmoves_row([[Color, _], neutral | Rest], CordX, CordY, Color, VerticalMovesRow) :-
    NewCordY is CordY - 1,
    valid_vmoves_row([neutral | Rest], CordX, NewCordY, Color, RestVerticalMovesRow),
    append([[CordX, CordY, down]], RestVerticalMovesRow, VerticalMovesRow).
valid_vmoves_row([neutral, [Color, _] | Rest], CordX, CordY, Color, VerticalMovesRow) :-
    NewCordY is CordY - 1,
    valid_vmoves_row([[Color, _] | Rest], CordX, NewCordY, Color, RestVerticalMovesRow),
    append([[CordX, NewCordY, up]], RestVerticalMovesRow, VerticalMovesRow).
valid_vmoves_row([_ | Rest], CordX, CordY, Color, VerticalMovesRow) :-
    NewCordY is CordY - 1,
    valid_vmoves_row(Rest, CordX, NewCordY, Color, VerticalMovesRow).

% --------------------------- %
% Game State Value Predicates %
% --------------------------- %

% value(+GameState, +Player, -Value)
% Returns the value of the game state to the given player.
value(GameState, Player, Value) :-
    GameState = [Board, _, _, _, _, _],
    value_board(Board, Player, Value).

% value_board(+Board, +Player, -Value)
% Returns the value of the board to the given player.
value_board([], _, 0).
value_board([Row | Rest], Player, Value) :-
    value_row(Row, Player, RowValue),
    value_board(Rest, Player, RestValue),
    Value is RowValue + RestValue.

% value_row(+Row, +Player, -Value)
% Returns the value of the row to the given player.
value_row([], _, 0).
value_row([Cell | Rest], Player, Value) :-
    value_cell(Cell, Player, CellValue),
    value_row(Rest, Player, RestValue),
    Value is CellValue + RestValue.

% value_cell(+Cell, +Player, -Value)
% Returns the value of the cell to the given player.
value_cell(empty, _, 0).
value_cell(neutral, _, 0).
value_cell([Player, Height], Player, Height).
value_cell([Player, Height], _, -Height).

% -------------------- %
% Game Over Predicates %
% -------------------- %

% game_over(+GameState, -Winner)
% Checks if the game is over and returns the winner.
game_over(GameState, Winner) :-
    valid_moves(GameState, ListOfMovesP1),
    GameState = [Board, CurrentPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite],
    (CurrentPlayer == blue -> OtherPlayer = white ; OtherPlayer = blue),
    valid_moves([Board, OtherPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite], ListOfMovesP2),
    append(ListOfMovesP1, ListOfMovesP2, ListOfMoves),
    (ListOfMoves \= [] -> Winner = 0 , ! ;
     value(GameState, blue, Score),
      (Score > 0 -> Winner = blue, ! ;
       Score < 0 -> Winner = white, ! ;
       Winner = draw)), !.

% ---------------------- %
% Choose Move Predicates %
% ---------------------- %

/*
    TODO:
    This predicate receives the current game state and
    returns the move chosen by the computer player. Level 1 should return a random valid move. Level
    2 should return the best play at the time (using a greedy algorithm), considering the evaluation of
    the game state as determined by the value/3 predicate. For human players, it should interact with
    the user to read the move.
*/
choose_move(+GameState, +Player, -Move).
