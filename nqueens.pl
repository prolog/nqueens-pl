% Search-based N-QUEENS.
%
% Copyright 2012 Julian Day <jcd748@mail.usask.ca>
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%
%
%
% Find a series of placements for N queens on a chessboard such that no queen attacks another
% queen, as per the rules of chess.
%
% To run, use nqueens/2.
%
% E.g.: ?- nqueens(6, Solution).

%
%%%% N-Queens logic predicates.
%

% init/3 succeeds if the chessboard squares can be initialized.
init(1, 1, _Max) :- assert(square(1, 1)).
init(N, 1, MaxM) :- N > 1, assert(square(N, 1)), NewN is N - 1, init(NewN, MaxM, MaxM).
init(N, M, MaxM) :- N > 0, M > 1, assert(square(N, M)), NewM is M - 1, init(N, NewM, MaxM).
initialize_squares(N) :- init(N, N, N).

% not_a_rearrangement/1 succeeds iff the sorted solution has not already been examined.
% This essentially treats all queens as equal, and ignores the concept of "queen 1", "queen 2", etc,
% so that I can see different chessboards each time.
not_a_rearrangement(Solution) :- not(solution(Solution)).

% setup/1 succeeds if the previous gameboard and solutions can be cleared, and the gameboard re-initialized.
setup(N) :- retractall(square(_X, _Y)), retractall(solution(_Sol)), initialize_squares(N).

% no_attack/2 succeeds iff the square given by the first parameter does not attack any other square in the list provided as
% the second parameter.
%
% A square, A,  attacks another square, B, if:
%  - they are on the same row (same X)
%  - they are on the same col (same Y)
%  - they are on the same diagonal (absolute values of row and col are both 0)
no_attack(square(_X, _Y), []).
no_attack(square(X, Y), [square(X2, Y2)|T]) :- AbsFirst is abs(X - X2), AbsSecond is abs(Y - Y2), AbsFirst > 0, AbsSecond > 0, AbsFirst \= AbsSecond, no_attack(square(X, Y), T).

% place_queen/2 succeeds iff a queen can be placed on the square if a square can be found, 
% and if that square does not attack any of the current queen placements.
place_queen([square(X, Y)], CurrentQueenPlacements) :- square(X, Y), no_attack(square(X, Y), CurrentQueenPlacements).

% find_solution/3 succeeds iff a series of placements of queens can be found, such that no placement "attacks" another placement.
find_solution(0, _X, []).
find_solution(CurrentQueen, CurrentQueenPlacements, [FirstPlacement|RemainingPlacements]) :- CurrentQueen > 0, place_queen(FirstPlacement, CurrentQueenPlacements), NextQueen is CurrentQueen - 1, append(CurrentQueenPlacements, FirstPlacement, NewQueenPlacements), find_solution(NextQueen, NewQueenPlacements, RemainingPlacements).


%
%%%% IO predicates
%

% print_square/3 succeeds iff:
%  - 'Q ' can be printed if the square predicate based on the current row/col is in the list (i.e., "a queen exists at that square")
%  = 'X ' can be printed if the square predicate based on the current row/col is not in the list ("a queen does not exist at that square")
print_square(CurrentRow, CurrentColumn, Solution) :- member([square(CurrentRow, CurrentColumn)], Solution), write('Q ').
print_square(CurrentRow, CurrentColumn, Solution) :- not(member([square(CurrentRow, CurrentColumn)], Solution)), write('X ').

% print_column/4 succeeds iff a the current column can be printed, and the remaining columns in the sequence printed.
print_column(CurrentRow, MaxSize, MaxSize, Solution) :- print_square(CurrentRow, MaxSize, Solution).
print_column(CurrentRow, CurrentColumn, MaxSize, Solution) :- CurrentRow =< MaxSize, print_square(CurrentRow, CurrentColumn, Solution), NextColumn is CurrentColumn + 1, print_column(CurrentRow, NextColumn, MaxSize, Solution).

% print_row/3 succeeds iff a row showing the queen placement can be printed.  A row can only be printed one way, so a cut is used.
print_row(MaxSize, MaxSize, Solution) :- print_column(MaxSize, 1, MaxSize, Solution), !.
print_row(CurrentRow, MaxSize, Solution) :- CurrentRow < MaxSize, print_column(CurrentRow, 1, MaxSize, Solution), nl, NextRow is CurrentRow + 1, print_row(NextRow, MaxSize, Solution), !.

% print_solution/2 succeeds iff a simple chessboard showing the queen placement can be printed.
print_solution(Size, Solution) :- print_row(1, Size, Solution).

% A solution for NQUEENS/2 exists iff a gameboard can be cleared, then initialized, a solution can be found, 
% and that solution can be printed.
nqueens(N, Solution) :-  setup(N), find_solution(N, [], Solution), sort(Solution, SortedSolution), not_a_rearrangement(SortedSolution), assert(solution(SortedSolution)), print_solution(N, SortedSolution).

