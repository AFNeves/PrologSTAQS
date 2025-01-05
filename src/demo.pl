% -------------------- %
% Play Move Predicates %
% -------------------- %

% play_move(+GameMode, +Level)
% Predicate to demo the move stage of the game.
play_move(1) :- play_move(1, 0).
play_move(1, 0) :-
    play_move_board(Board),
    GameConfig = [1, 0, 'Blue', 'White'],
    GameState = [Board, blue, [human, 'Blue'], [human, 'White'], 0, 0],
    game_loop(GameConfig, GameState).
play_move(2, Level) :-
    play_move_board(Board),
    GameConfig = [2, Level, 'Blue', 'White'],
    GameState = [Board, blue, [human, 'Player'], [computer, 'Computer'], 0, 0],
    game_loop(GameConfig, GameState).
play_move(3, Level) :-
    play_move_board(Board),
    GameConfig = [3, Level, 'Blue', 'White'],
    GameState = [Board, blue, [computer, 'Computer'], [human, 'Player'], 0, 0],
    game_loop(GameConfig, GameState).
play_move(4, Level) :-
    play_move_board(Board),
    GameConfig = [4, Level, 'Blue', 'White'],
    GameState = [Board, blue, [computer, 'Blue'], [computer, 'White'], 0, 0],
    game_loop(GameConfig, GameState).

% --------------------- %
% Play Final Predicates %
% --------------------- %

% play_final(+GameMode, +Level)
% Predicate to demo the final stage of the game.
play_final(1) :- play_final(1, 0).
play_final_(1, 0) :-
    play_final_board(Board),
    GameConfig = [1, 0, 'Blue', 'White'],
    GameState = [Board, blue, [human, 'Blue'], [human, 'White'], 0, 0],
    game_loop(GameConfig, GameState).
play_final(2, Level) :-
    play_final_board(Board),
    GameConfig = [2, Level, 'Blue', 'White'],
    GameState = [Board, blue, [human, 'Player'], [computer, 'Computer'], 0, 0],
    game_loop(GameConfig, GameState).
play_final(3, Level) :-
    play_final_board(Board),
    GameConfig = [3, Level, 'Blue', 'White'],
    GameState = [Board, blue, [computer, 'Computer'], [human, 'Player'], 0, 0],
    game_loop(GameConfig, GameState).
play_final(4, Level) :-
    play_final_board(Board),
    GameConfig = [4, Level, 'Blue', 'White'],
    GameState = [Board, blue, [computer, 'Blue'], [computer, 'White'], 0, 0],
    game_loop(GameConfig, GameState).
