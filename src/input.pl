% --------------------------- %
% Input Validation Predicates %
% --------------------------- %

/* Game Config */

% read_and_validate_int(+MaxValidOption, -Input)
% Reads the input from the user and validates it. Returns the option chosen.
read_and_validate_int(MaxValidOption, Input) :-
    repeat,
        read(Input),
    (between(0, MaxValidOption, Input) -> ! ;
        nl, write('Please enter a valid option.'), nl,
        nl, write('Chosen option: '), fail).

% read_and_validate_string(-PlayerName)
% Reads the input from the user and validates it. Returns the player name.
read_and_validate_string(PlayerName) :-
    repeat,
        read(PlayerName),
    (PlayerName \= '' -> ! ;
        nl, write('Please enter a valid name.'), nl,
        nl, write('Player name: '), fail).

/* Game Loop */

% read_and_validate_place(-Move)
% Reads the input from the user and validates it. Returns a placing move.
read_and_validate_place(Move) :-
    repeat,
        get_code(InputX), get_code(Space), get_code(InputY), skip_line,
        (between(49, 53, InputX), Space == 32, between(49, 53, InputY) -> ! ;
            nl, write('Please enter a valid pair of coordenates.'), nl,
            nl, write('Please enter the coordinates: '), fail),
    X is InputX - 48, Y is InputY - 48, Move = [X, Y].

% read_and_validate_move(-Move)
% Reads the input from the user and validates it. Returns a moving move.
read_and_validate_move(Move) :-
    repeat,
        get_code(InputX), get_code(Space_1), get_code(InputY), get_code(Space_2), get_code(Direction), skip_line,
        (between(49, 53, InputX), Space_1 == 32, between(49, 53, InputY), Space_2 == 32, member(Direction, [65,68,83,87,97,100,115,119]) -> ! ;
            nl, write('Please enter a valid move.'), nl,
            nl, write('Please enter the move: '), fail),
    X is InputX - 48, Y is InputY - 48,
        (Direction == 65 ; Direction == 97 -> Move = [X, Y, up] ;
            (Direction == 68 ; Direction == 100 -> Move = [X, Y, down] ;
                (Direction == 83 ; Direction == 115 -> Move = [X, Y, left] ;
                    Move = [X, Y, right]))).
