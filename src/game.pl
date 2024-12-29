% -------------------- %
% Auxiliary Predicates %
% -------------------- %

% clear/0
% Clears the screen. Found the code in the following link.
% https://stackoverflow.com/questions/53262099/swi-prolog-how-to-clear-terminal-screen-with-a-keyboard-shortcut-or-global-pre
clear :- write('\33\[2J').

% read_and_validate(+MaxValidOption, -Input)
% Reads the input from the user and validates it.
read_and_validate(MaxValidOption, Input) :-
    repeat,
        read(Input),
    (between(0, MaxValidOption, Input) -> ! ;
        nl, write('Please enter a valid option.'), nl,
        nl, write('Chosen option: '), fail).

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
    write(' 0. Exit                  '), nl, nl,
    write('Chosen option: ').

% -------------- %
% PLAY Predicate %
% -------------- %

% play/0
% Configures the necessary libraries and starts the game.
play :-
    use_module(library(between)),
    main_menu.

% -------------------- %
% Main Menu Predicates %
% -------------------- %

/*
    TODO:
    The main predicate, play/0, must be in the game.pl file and must give access to the game menu,
    which allows configuring the game type (H/H, H/PC, PC/H, or PC/PC), difficulty level(s) to be used
    by the artificial player(s), among other possible parameters, and start the game cycle.
*/

main_menu :-
    game_mode_selector(GameMode),
    difficulty_selector(Difficulty), nl,
    write('Game Mode: '), write(GameMode), nl,
    write('Difficulty: '), write(Difficulty), nl.

% game_mode_selector(-GameMode)
% Asks the user to choose a game mode.
game_mode_selector(GameMode) :-
    clear,
    layout_game_mode,
    read_and_validate(4, GameMode),
    GameMode \= 0.

% difficulty_selector(-Difficulty)
% Asks the user to choose a difficulty.
difficulty_selector(Difficulty) :-
    clear,
    layout_difficulty,
    read_and_validate(2, Difficulty),
    Difficulty \= 0.

% ---------------------- %
% Still TODO: Predicates %
% ---------------------- %

/*
    TODO:
    This predicate receives a desired game configuration and returns the corresponding initial game state.
    Game configuration includes the type of each player and other parameters such as board size,
    use of optional rules, player names, or other information to provide more flexibility to the game.
    The game state describes a snapshot of the current game state, including board configuration
    (typically using list of lists with different atoms for the different pieces), identifies the
    current player (the one playing next), and possibly captured pieces and/or pieces yet to be played,
    or any other information that may be required, depending on the game.
*/
initial_state(+GameConfig, -GameState).

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
