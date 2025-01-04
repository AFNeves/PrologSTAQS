% -------------------- %
% Auxiliary Predicates %
% -------------------- %

% clear/0
% Clears the screen. Found the code in the following link.
% https://stackoverflow.com/questions/53262099/swi-prolog-how-to-clear-terminal-screen-with-a-keyboard-shortcut-or-global-pre
clear :- write('\33\[2J').

% count(+List, -N)
% Counts the number of elements in a list.
count([], 0).
count([H | T], N) :- count(T, N1), N is N1 + 1.

% dup_char(+N, +Char, -Sequence)
% Creates a sequence of n repeated characters.
dup_char(0, _, '').
dup_char(N, Char, Sequence) :-
    N > 0,
    N1 is N - 1,
    dup_char(N1, Char, Sequence1),
    atom_concat(Char, Sequence1, Sequence).

% change_player(+CurrentPlayer, -NextPlayer)
% Changes the current player to the next player.
change_player(CurrentPlayer, NextPlayer) :-
    (CurrentPlayer == blue -> NextPlayer = white ; NextPlayer = blue).
