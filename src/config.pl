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
    CurrentPlayer = blue, RemainingBlue = 4, RemainingWhite = 4,
    initial_board(Board), player_config(GameConfig, BluePlayer, WhitePlayer),
    GameState = [Board, CurrentPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite].

% player_config(+GameConfig, -BluePlayer, -WhitePlayer).
% Returns the player configuration based on the given game configuration.
player_config([1, _, BluePlayerName, WhitePlayerName], ['H', BluePlayerName], ['H', WhitePlayerName]).
player_config([2, _, BluePlayerName, WhitePlayerName], ['H', BluePlayerName], ['C', WhitePlayerName]).
player_config([3, _, BluePlayerName, WhitePlayerName], ['C', BluePlayerName], ['H', WhitePlayerName]).
player_config([4, _, BluePlayerName, WhitePlayerName], ['C', BluePlayerName], ['C', WhitePlayerName]).