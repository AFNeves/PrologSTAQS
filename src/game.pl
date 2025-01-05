:- use_module(library(lists)).
:- use_module(library(random)).
:- use_module(library(between)).
:- use_module(library(samsort)).

:- include('demo.pl').
:- include('utils.pl').
:- include('input.pl').
:- include('board.pl').
:- include('config.pl').
:- include('layouts.pl').

% -------------- %
% PLAY Predicate %
% -------------- %

% play/0
% Main predicate to start the game.
play :-
    % Create the GameConfig and initial GameState.
    create_config(GameConfig),
    initial_state(GameConfig, GameState),
    % Clear input stream.
    skip_line,
    % Run the game loop.
    game_loop(GameConfig, GameState).

% -------------------- %
% Game Loop Predicates %
% -------------------- %

% game_loop(+GameConfig, +GameState)
% Main game loop that controls the game flow.
game_loop(GameConfig, GameState) :-
    % Check if the game is over.
    game_over(GameState, Winner),
    % Display the game state.
    display_game(GameState),
    (
        % Players are placing their pieces.
        Winner == 0 -> place_loop(GameConfig, GameState, NewGameState), game_loop(GameConfig, NewGameState) ;
        % Players are moving their pieces.
        Winner == 1 -> move_loop(GameConfig, GameState, NewGameState), game_loop(GameConfig, NewGameState) ;
        % Player is out of possible moves.
        Winner == 2 -> pass_move(GameState, NewGameState), game_loop(GameConfig, NewGameState) ;
        % Game is over, time to display the winner.
        display_winner(GameState, Winner)
    ).

% place_loop(+GameConfig, +GameState, -NewGameState)
% Loop that is executed while the players are placing their initial pieces.
place_loop([_, Difficulty, _, _], GameState, NewGameState) :-
    % GameState expansion for easier access.
    GameState = [Board, CurrentPlayer, [BType, BPlayerName], [WType, WPlayerName], RemainingBlue, RemainingWhite],
    % Display the current player and the remaining pieces.
    current_player(GameState),
    % Choose the move for the current player.
    (CurrentPlayer == blue, BType == human -> choose_move(GameState, 0, Move) ;
     CurrentPlayer == white, WType == human -> choose_move(GameState, 0, Move) ;
     CurrentPlayer == blue, BType == computer -> choose_move(GameState, Difficulty, Move) ;
     CurrentPlayer == white, WType == computer -> choose_move(GameState, Difficulty, Move)),
    % Place the piece.
    move(GameState, Move, [NewBoard, NewCurrentPlayer, _, _, _, _]),
    (CurrentPlayer == blue -> NewRemainingBlue is RemainingBlue - 1, NewRemainingWhite = RemainingWhite ;
     CurrentPlayer == white -> NewRemainingWhite is RemainingWhite - 1, NewRemainingBlue = RemainingBlue),
    NewGameState = [NewBoard, NewCurrentPlayer, [BType, BPlayerName], [WType, WPlayerName], NewRemainingBlue, NewRemainingWhite].

% move_loop(+GameConfig, +GameState, -NewGameState)
% Loop that is executed while the players are moving their pieces.
move_loop([_, Difficulty, _, _], GameState, NewGameState) :-
    % GameState expansion for easier access.
    GameState = [Board, CurrentPlayer, [BType, BPlayerName], [WType, WPlayerName], RemainingBlue, RemainingWhite],
    % Display the current player.
    current_player(GameState),
    % Display the current player's pieces.
    show_player_pieces(Board, CurrentPlayer, BPlayerName, WPlayerName),
    % Choose the move for the current player.
    (CurrentPlayer == blue, BType == human -> choose_move(GameState, 0, Move) ;
     CurrentPlayer == white, WType == human -> choose_move(GameState, 0, Move) ;
     CurrentPlayer == blue, BType == computer -> choose_move(GameState, Difficulty, Move) ;
     CurrentPlayer == white, WType == computer -> choose_move(GameState, Difficulty, Move)),
    % Place the piece.
    move(GameState, Move, NewGameState).

% pass_move(+GameState, -NewGameState)
% Predicate that is executed when the player is out of moves.
pass_move(GameState, NewGameState) :-
    % GameState expansion for easier access.
    GameState = [Board, CurrentPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite],
    % Display the current player and the remaining pieces.
    current_player(GameState),
    % Display the pass message.
    nl, nl, write('Looks like you are out of moves!'),
    nl, nl, write('Press any key to continue...'), skip_line,
    % Change the player.
    change_player(CurrentPlayer, NewCurrentPlayer),
    NewGameState = [Board, NewCurrentPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite].

% --------------------- %
% Move Piece Predicates %
% --------------------- %

% move(+GameState, +Move, -NewGameState)
% Moves the piece to the new coordinates.
move(GameState, Move, NewGameState) :-
    GameState = [Board, CurrentPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite],
    validate_move(Board, CurrentPlayer, Move, Valid),
    (Valid == false -> NewGameState = GameState ;
     execute_move(Board, CurrentPlayer, Move, NewBoard),
     change_player(CurrentPlayer, NextPlayer),
     NewGameState = [NewBoard, NextPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite]).

% check_owner(+Board, +CordX, +CordY, +CurrentPlayer, -Valid)
% Checks if the piece at the given coordinates belongs to the current player.
check_owner(Board, CordX, CordY, CurrentPlayer, Valid) :-
    PieceRowNumber is 6 - CordY,
    nth1(PieceRowNumber, Board, PieceRow),
    nth1(CordX, PieceRow, Piece),
    (Piece == empty -> Valid = false ;
     Piece == neutral -> Valid = false ;
     CurrentPlayer == blue, Piece \= [blue, _] -> Valid = false ;
     CurrentPlayer == white, Piece \= [white, _] -> Valid = false ;
     Valid = true).

% validate_move(+Board, +CurrentPlayer, +Move, -Valid)
% Validates the given move.
validate_move(Board, CurrentPlayer, [CordX, CordY], Valid) :-
    RowNumber is 6 - CordY,
    nth1(RowNumber, Board, Row),
    nth1(CordX, Row, Cell),
    (Cell == neutral -> Valid = true ; Valid = false).
validate_move(Board, CurrentPlayer, [CordX, CordY, Direction], Valid) :-
    check_owner(Board, CordX, CordY, CurrentPlayer, OwnerValid),
    (OwnerValid == false -> Valid = false ;
        (Direction == up    -> NewPieceRowNumber is 6 - CordY - 1, NewPieceColumnNumber is CordX ;
         Direction == down  -> NewPieceRowNumber is 6 - CordY + 1, NewPieceColumnNumber is CordX ;
         Direction == left  -> NewPieceRowNumber is 6 - CordY, NewPieceColumnNumber is CordX - 1 ;
         Direction == right -> NewPieceRowNumber is 6 - CordY, NewPieceColumnNumber is CordX + 1),
        nth1(NewPieceRowNumber, Board, NewPieceRow),
        nth1(NewPieceColumnNumber, NewPieceRow, NewPiece),
        (NewPiece == neutral -> Valid = true ; Valid = false)).

% execute_move(+Board, +CurrentPlayer, +Move, -NewBoard)
% Executes the given move.
execute_move(Board, CurrentPlayer, [CordX, CordY], NewBoard) :-
    (CurrentPlayer == blue -> Piece = [blue, 1] ; Piece = [white, 1]),
    MatrixCordY is 6 - CordY,
    replace(Board, CordX, MatrixCordY, Piece, NewBoard).
execute_move(Board, CurrentPlayer, [CordX, CordY, Direction], NewBoard) :-
    MatrixCordY is 6 - CordY,
    nth1(MatrixCordY, Board, PieceRow),
    nth1(CordX, PieceRow, [Color, Height]), NewHeight is Height + 1,
    replace(Board, CordX, MatrixCordY, empty, CleanedBoard),
    (Direction == up    -> NewCordX = CordX, NewCordY is MatrixCordY - 1 ;
     Direction == down  -> NewCordX = CordX, NewCordY is MatrixCordY + 1 ;
     Direction == left  -> NewCordY = MatrixCordY, NewCordX is CordX - 1 ;
     Direction == right -> NewCordY = MatrixCordY, NewCordX is CordX + 1),
    replace(CleanedBoard, NewCordX, NewCordY, [Color, NewHeight], NewBoard).

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
value_cell([Player, Height], Player, Value) :- Value is Height * Height.
value_cell([Player, Height], NotPlayer, 0) :- Player \= NotPlayer.

% ------------------------ %
% Player Pieces Predicates %
% ------------------------ %

% player_pieces(+Board, +Player, +CordY, -ListOfPieces)
% Returns a list of the player's pieces coordinates and heights.
player_pieces([], _, _, []).
player_pieces([Row | Rest], Player, CordY, ListOfPieces) :-
    NewCordY is CordY + 1,
    player_pieces_row(Row, Player, 1, CordY, RowPieces),
    player_pieces(Rest, Player, NewCordY, RestPieces),
    append(RowPieces, RestPieces, ListOfPieces).

% player_pieces_row(+Row, +Player, +CordX, +CordY, -ListOfPieces)
% Returns a list of the player's pieces coordinates and heights on a given row.
player_pieces_row([], _, _, _, []).
player_pieces_row([Cell | Rest], Player, CordX, CordY, ListOfPieces) :-
    NewCordX is CordX + 1,
    player_pieces_cell(Cell, Player, CordX, CordY, CellPieces),
    player_pieces_row(Rest, Player, NewCordX, CordY, RestPieces),
    append(CellPieces, RestPieces, ListOfPieces).

% player_pieces_cell(+Cell, +Player, +CordX, +CordY, -ListOfPieces)
% Returns the coordinates and height of a player's piece.
player_pieces_cell(empty, _, _, _, []).
player_pieces_cell(neutral, _, _, _, []).
player_pieces_cell([Player, Height], Player, CordX, CordY, [[CordX, ActualY, Height]]) :- ActualY is 6 - CordY.
player_pieces_cell([OtherPlayer, _], Player, _, _, []) :- OtherPlayer \= Player.

% -------------------- %
% Game Over Predicates %
% -------------------- %

% game_over(+GameState, -Winner)
% Checks if the game is over and returns the winner.
game_over(GameState, Winner) :-
    GameState = [Board, CurrentPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite],
    (RemainingBlue \= 0 -> Winner = 0, ! ;
     RemainingWhite \= 0 -> Winner = 0, ! ;
        valid_moves(GameState, ListOfMovesP1),
        (CurrentPlayer == blue -> OtherPlayer = white ; OtherPlayer = blue),
        valid_moves([Board, OtherPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite], ListOfMovesP2),
        append(ListOfMovesP1, ListOfMovesP2, ListOfMoves),
        (ListOfMovesP1 \= [] -> Winner = 1 , ! ;
         ListOfMovesP1 == [], ListOfMovesP2 \= [] -> Winner = 2, ! ;
         value(GameState, blue, Score),
          (Score > 0 -> Winner = blue, ! ;
           Score < 0 -> Winner = white, ! ;
           Winner = draw))).

% ---------------------- %
% Choose Move Predicates %
% ---------------------- %

% choose_move(+GameState, +Level, -Move)
% Chooses the move for the computer player.
choose_move(GameState, 1, Move) :-
    % Find all valid moves.
    valid_moves(GameState, ListOfMoves),
    % Choose a random move from the list.
    random_member(Move, ListOfMoves).
choose_move(GameState, 2, Move) :-
    % GameState expansion for easier access.
    GameState = [_, CurrentPlayer, _, _, _, _],
    % Find all valid moves.
    valid_moves(GameState, ListOfMoves),
    findall(
        [Value, Move],
        (
            member(Move, ListOfMoves),
            move(GameState, Move, NewGameState),
            value(NewGameState, CurrentPlayer, Value)
        ),
        ListOfValues
    ),
    % Sort the list of values.
    sort(ListOfValues, SortedListOfValues),
    % Get the best move.
    last(SortedListOfValues, [_, Move]).
% Chooses the move for the human player.
choose_move([Board, CurrentPlayer, BluePlayer, WhitePlayer, 0, 0], 0, Move) :-
    % Display the instructions for moving a piece.
    nl, nl, write('To move a piece, enter the coordinates of the piece'), nl,
    write('  to move and the direction in the format "X Y [A/W/S/D]".'), nl,
    % Loop to check for valid placements.
    repeat,
        % Ask the user for the coordinates.
        nl, write('Please enter the move: '),
        % Read and validate the coordinates.
        read_and_validate_move(Move),
        % Validate the move.
        validate_move(Board, CurrentPlayer, Move, Valid),
        (Valid == true -> ! ; nl, write('Invalid move.'), nl, fail).
choose_move([Board, CurrentPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite], 0, Move) :-
    % Display the instructions for placing a new piece.
    nl, nl, write('To place a new piece, enter the coordinates in the format: X Y'), nl,
    % Loop to check for valid placements.
    repeat,
        % Ask the user to enter valid coordinates.
        nl, write('Please enter the coordinates: '),
        % Read and validate the coordinates.
        read_and_validate_place(Move),
        % Validate the move.
        validate_move(Board, CurrentPlayer, Move, Valid),
        (Valid == true -> ! ; nl, write('Invalid placement.'), nl, fail ).
