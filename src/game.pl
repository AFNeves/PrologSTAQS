:- use_module(library(lists)).
:- use_module(library(between)).

:- include('utils.pl').
:- include('input.pl').
:- include('output.pl').

% --------------- %
% PLAY Predicates %
% --------------- %

% play/0
% Main predicate to start the game.
play :-
    % Create the GameConfig and initial GameState.
    create_config(GameConfig),
    initial_state(GameConfig, GameState), skip_line,
    % Run the game loop.
    game_loop(GameState).

% game_loop(+GameState)
% Main game loop that controls the game flow.
game_loop(GameState) :-
    % Check if the game is over.
    game_over(GameState, Winner),
    % Display the game state.
    display_game(GameState),
    (
        % Players are placing their pieces.
        Winner == 0 -> place_loop(GameState, NewGameState), game_loop(NewGameState, Winner) ;
        % Players are moving their pieces.
        Winner == 1 -> move_loop(GameState, NewGameState), game_loop(NewGameState) ;
        % Game is over, time to display the winner.
        (Winner == draw -> nl, write('The game ended in a draw.'), nl ;
         Winner == blue -> nl, write('The blue player won.'), nl ;
         Winner == white -> nl, write('The white player won.'), nl)
    ).

% place_loop(+GameState, -NewGameState)
% Loop that is executed while the players are placing their initial pieces.
place_loop(GameState, NewGameState) :-
    % GameState expansion for easier access.
    GameState = [Board, CurrentPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite],
    % Display the instructions for placing a new piece.
    nl, write('To place a new piece, enter the coordinates in the format: X Y'), nl,
    % Loop to check for valid placements.
    repeat,
        % Ask the user to enter valid coordinates.
        nl, write('Please enter the coordinates: '),
        % Read and validate the coordinates.
        read_and_validate_place(Move),
        % Validate the move.
        validate_move(Board, CurrentPlayer, Move, Valid),
        (Valid == false ->
            % Invalid move, so display an error message.
            nl, write('Invalid placement.'), nl, fail ;
            % Valid move, so place the piece.
            move(GameState, Move, NewGameState), !).

% move_loop(+GameState, -NewGameState)
% Loop that is executed while the players are moving their pieces.
move_loop(GameState, NewGameState) :-
    % GameState expansion for easier access.
    GameState = [Board, CurrentPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite],
    % Display the instructions for moving a piece.
    nl, write('To move a piece, enter the coordinates of the piece to move and the direction in the format "X Y A/W/S/D".'),
    nl, write('A: Up, W: Down, S: Left, D: Right.'), nl,
    % Loop to check for valid placements.
    repeat,
        % Ask the user for the coordinates.
        nl, write('Please enter the move: '),
        % Read and validate the coordinates.
        read_and_validate_move(Move),
        % Validate the move.
        validate_move(Board, CurrentPlayer, Move, Valid),
        (Valid == false ->
            % Invalid move, so display an error message.
            nl, write('Invalid move.'), nl, fail ;
            % Valid move, so place the piece.
            move(GameState, Move, NewGameState), !, true).

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
    Valid = true,
    PieceRowNumber is 6 - CordY,
    nth1(PieceRowNumber, Board, PieceRow),
    nth1(CordX, PieceRow, Piece),
    (CurrentPlayer == blue, Piece \= [blue, _] ; CurrentPlayer == white, Piece \= [white, _] ; Piece == neutral ; Piece == empty -> Valid = false).

% change_player(+CurrentPlayer, -NextPlayer)
% Changes the current player to the next player.
change_player(CurrentPlayer, NextPlayer) :-
    (CurrentPlayer == blue -> NextPlayer = white ; NextPlayer = blue).

% validate_move(+Board, +CurrentPlayer, +Move, -Valid)
% Validates the given move.
validate_move(Board, CurrentPlayer, [CordX, CordY], Valid) :-
    RowNumber is 6 - CordY,
    nth1(RowNumber, Board, Row),
    nth1(CordX, Row, Cell),
    (Cell == neutral -> Valid = true ; Valid = false).
validate_move(Board, CurrentPlayer, [CordX, CordY, up], Valid) :-
    (CordY >= 5 -> Valid = false, fail),
    check_owner(Board, CordX, CordY, CurrentPlayer, OwnerValid),
    (OwnerValid == false -> Valid = false, fail),
    NewPieceRowNumber is 6 - CordY - 1,
    nth1(NewPieceRowNumber, Board, NewPieceRow),
    nth1(CordX, NewPieceRow, NewPiece),
    (NewPiece == neutral -> Valid = true ; Valid = false).
validate_move(Board, CurrentPlayer, [CordX, CordY, down], Valid) :-
    (CordY =< 1 -> Valid = false, fail),
    check_owner(Board, CordX, CordY, CurrentPlayer, OwnerValid),
    (OwnerValid == false -> Valid = false, fail),
    NewPieceRowNumber is 6 - CordY + 1,
    nth1(NewPieceRowNumber, Board, NewPieceRow),
    nth1(CordX, NewPieceRow, NewPiece),
    (NewPiece == neutral -> Valid = true ; Valid = false).
validate_move(Board, CurrentPlayer, [CordX, CordY, left], Valid) :-
    (CordX =< 1 -> Valid = false, fail),
    check_owner(Board, CordX, CordY, CurrentPlayer, OwnerValid),
    (OwnerValid == false -> Valid = false, fail),
    NewPieceRowNumber is 6 - CordY,
    NewPieceColumnNumber is CordX - 1,
    nth1(NewPieceRowNumber, Board, NewPieceRow),
    nth1(NewPieceColumnNumber, NewPieceRow, NewPiece),
    (NewPiece == neutral -> Valid = true ; Valid = false).
validate_move(Board, CurrentPlayer, [CordX, CordY, right], Valid) :-
    (CordX >= 5 -> Valid = false, fail),
    check_owner(Board, CordX, CordY, CurrentPlayer, OwnerValid),
    (OwnerValid == false -> Valid = false, fail),
    NewPieceRowNumber is 6 - CordY,
    NewPieceColumnNumber is CordX + 1,
    nth1(NewPieceRowNumber, Board, NewPieceRow),
    nth1(NewPieceColumnNumber, NewPieceRow, NewPiece),
    (NewPiece == neutral -> Valid = true ; Valid = false).

% execute_move(+Board, +CurrentPlayer, +Move, -NewBoard)
% Executes the given move.
execute_move(Board, CurrentPlayer, [CordX, CordY], NewBoard) :-
    (CurrentPlayer == blue -> Piece = [blue, 1] ; Piece = [white, 1]),
    MatrixCordY is 6 - CordY,
    replace(Board, CordX, MatrixCordY, Piece, NewBoard).
execute_move(Board, CurrentPlayer, [CordX, CordY, Direction], NewBoard) :-
    (Direction \= up, Direction \= down, Direction \= left, Direction \= right -> NewBoard = Board, !),
    MatrixCordY is 6 - CordY,
    nth1(MatrixCordY, Board, PieceRow),
    nth1(CordX, PieceRow, Piece),
    replace(Board, CordX, MatrixCordY, neutral, CleanedBoard),
    (Direction == up    -> NewCordX = CordX, NewCordY is MatrixCordY + 1 ;
     Direction == down  -> NewCordX = CordX, NewCordY is MatrixCordY - 1 ;
     Direction == left  -> NewCordY = MatrixCordY, NewCordX is CordX - 1 ;
     Direction == right -> NewCordY = MatrixCordY, NewCordX is CordX + 1),
    replace(CleanedBoard, NewCordX, NewCordY, Piece, NewBoard).

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
    GameState = [Board, CurrentPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite],
    (RemainingBlue \= 0 ; RemainingWhite \= 0 -> Winner = 0, ! ;
        valid_moves(GameState, ListOfMovesP1),
        (CurrentPlayer == blue -> OtherPlayer = white ; OtherPlayer = blue),
        valid_moves([Board, OtherPlayer, BluePlayer, WhitePlayer, RemainingBlue, RemainingWhite], ListOfMovesP2),
        append(ListOfMovesP1, ListOfMovesP2, ListOfMoves),
        (ListOfMoves \= [] -> Winner = 1 , ! ;
         value(GameState, blue, Score),
          (Score > 0 -> Winner = blue, ! ;
           Score < 0 -> Winner = white, ! ;
           Winner = draw))).

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
