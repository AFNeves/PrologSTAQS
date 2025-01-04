% --------------- %
% Demo Predicates %
% --------------- %

% play_move\0
% Predicate to demo the move stage of the game.
play_move_0 :-
    play_move_board(Board),
    GameConfig = [1, 0, 'Blue', 'White'],
    GameState = [Board, blue, [human, 'Blue'], [human, 'White'], 0, 0],
    game_loop(GameConfig, GameState).

% play_final\0
% Predicate to demo the final stage of the game.
play_final :-
    play_final_board(Board),
    GameConfig = [1, 0, 'Blue', 'White'],
    GameState = [Board, blue, [human, 'Blue'], [human, 'White'], 0, 0],
    game_loop(GameConfig, GameState).
