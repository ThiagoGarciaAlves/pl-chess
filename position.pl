
:- module(position, [position_parts/2, position_board/2, board_occupants/2, board_occupant/3]).

position_parts([position | Parts], Parts) :- length(Parts, 6).


position_board(Position, Board) :- 
    position_parts(Position, Parts), 
    nth0(0, Parts, Board).


position_turn(Position, Turn) :- 
    position_parts(Position, Parts), 
    nth(1, Parts, Turn).


board_occupants([board | Occupants], Occupants) :- length(Occupants, 64).
board_occupants(Position, Occupants) :- % shortcut: treat position as board 
    position_board(Position, Board), 
    board_occupants(Board, Occupants).


board_occupant(Board, Square, Piece) :- 
    board_occupants(Board, Occupants),
    square_index(Square, Index),
    nth0(Index, Occupants, Piece).
