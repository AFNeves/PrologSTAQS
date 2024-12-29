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

% -------------- %
% PLAY Predicate %
% -------------- %

play :-
    % Load the necessary libraries.
    use_module(library(between)),
    % Create the GameConfig and initial GameState.
    create_config(GameConfig),
    initial_state(GameConfig, GameState),
    nl, write(GameState).

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
player_config([GameMode, Difficulty, BluePlayerName, WhitePlayerName], BluePlayer, WhitePlayer) :-
    (GameMode = 1 -> BluePlayer = ['H', BluePlayerName], WhitePlayer = ['H', WhitePlayerName] ;
     GameMode = 2 -> BluePlayer = ['H', BluePlayerName], WhitePlayer = ['C', WhitePlayerName] ;
     GameMode = 3 -> BluePlayer = ['C', BluePlayerName], WhitePlayer = ['H', WhitePlayerName] ;
     GameMode = 4 -> BluePlayer = ['C', BluePlayerName], WhitePlayer = ['C', WhitePlayerName] ).

% ---------------------- %
% Still TODO: Predicates %
% ---------------------- %

/*
    TODO:
    This predicate receives the current game state (including the player
    who will make the next move) and prints the game state to the terminal. Appealing and intuitive
    visualizations will be valued. Flexible game state representations and visualization predicates will
    also be valued, for instance those that work with any board size. For uniformization purposes,
    coordinates should start at (1,1) at the lower left corner.
*/
display_game(+GameState).

/*
    TODO:
    This predicate is responsible for move validation and
    execution, receiving the current game state and the move to be executed, and (if the move is valid)
    returns the new game state after the move is executed.
*/
move(+GameState, +Move, -NewGameState).

/*
    TODO:
    This predicate receives the current game state, and
    returns a list of all possible valid moves.
*/
valid_moves(+GameState, -ListOfMoves).

/*
    TODO:
    This predicate receives the current game state, and verifies
    whether the game is over, in which case it also identifies the winner (or draw). Note that this
    predicate should not print anything to the terminal.
*/
game_over(+GameState, -Winner).

/*
    TODO:
    This predicate receives the current game state and returns a
    value measuring how good/bad the current game state is to the given Player.
*/
value(+GameState, +Player, -Value).

/*
    TODO:
    This predicate receives the current game state and
    returns the move chosen by the computer player. Level 1 should return a random valid move. Level
    2 should return the best play at the time (using a greedy algorithm), considering the evaluation of
    the game state as determined by the value/3 predicate. For human players, it should interact with
    the user to read the move.
*/
choose_move(+GameState, +Player, -Move).
