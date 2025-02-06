package chess

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"


main :: proc() {
	// NOTE: Odin setup stuff
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	defer {
		for _, entry in track.allocation_map {
			fmt.eprintf("%v leaked %v bytes\n", entry.location, entry.size)
		}
		for entry in track.bad_free_array {
			fmt.eprintf("%v bad free\n", entry.location)
		}
		mem.tracking_allocator_destroy(&track)
	}

	// NOTE: Chess setup stuff
	board := newGame()
	// NOTE: Start of rendering
	render(&board)
	fmt.printf("\tH\tG\tF\tE\tD\tC\tB\tA\n")
	for p, i in board.squares {
		if i % 8 == 0 {fmt.printf("\n")}
		if p != 255 {
			fmt.printf("\t%v", board.pieces[p].piece_type)
		} else {
			fmt.printf("\t*")
		}
		if i == 63 {fmt.printf("\n")}

	}
	fmt.println()
	fmt.println("Queen d8:")
	for p in availableMoves(&board, getPiece(&board, getSquareIndex({d, 7}))) {
		fmt.printf("Col: %v ", p % 8)
		fmt.printf("Row: %v\n", p / 8)
	}
}
Board :: struct {
	// 0-15 White , 16-31 Black
	// rook,knigt,bishop,queen,king,bishop,knight,rook
	// pawn,pawn,pawn,pawn,pawn,pawn,pawn,pawn
	// rook,knigt,bishop,queen,king,bishop,knight,rook
	// pawn,pawn,pawn,pawn,pawn,pawn,pawn,pawn
	pieces:  [32]Piece,
	// Contains a Piece_Index or 255
	squares: [64]u8,
}

Piece :: struct {
	piece_type:      PieceType,
	col, row, index: u8,
	alive:           bool,
}
PieceType :: enum {
	King,
	Pawn,
	Knight,
	Bishop,
	Rook,
	Queen,
}

// INFO: Since we made white the top, we have to reverse which column has what letter assigned to it
a :: 7
b :: 6
c :: 5
d :: 4
e :: 3
f :: 2
g :: 1
h :: 0

INVALID_INDEX :: 255

newGame :: proc() -> Board {
	//NOTE: newGame()
	reset_board: Board
	resetPieces(&reset_board)
	resetSquares(&reset_board)
	return reset_board
}


resetPieces :: proc(board: ^Board) {
	//NOTE: resetPieces()
	board.pieces = {
		Piece{piece_type = PieceType.Rook, col = 0, row = 0, index = 0, alive = true},
		Piece{PieceType.Knight, 1, 0, 1, true},
		Piece{PieceType.Bishop, 2, 0, 2, true},
		Piece{PieceType.King, 3, 0, 3, true},
		Piece{PieceType.Queen, 4, 0, 4, true},
		Piece{PieceType.Bishop, 5, 0, 5, true},
		Piece{PieceType.Knight, 6, 0, 6, true},
		Piece{PieceType.Rook, 7, 0, 7, true},
		Piece{piece_type = PieceType.Pawn, col = 0, row = 1, index = 8, alive = true},
		Piece{PieceType.Pawn, 1, 1, 9, true},
		Piece{PieceType.Pawn, 2, 1, 10, true},
		Piece{PieceType.Pawn, 3, 1, 11, true},
		Piece{PieceType.Pawn, 4, 1, 12, true},
		Piece{PieceType.Pawn, 5, 1, 13, true},
		Piece{PieceType.Pawn, 6, 1, 14, true},
		Piece{PieceType.Pawn, 7, 1, 15, true},
		Piece{piece_type = PieceType.Rook, col = 0, row = 7, index = 16, alive = true},
		Piece{PieceType.Knight, 1, 7, 17, true},
		Piece{PieceType.Bishop, 2, 7, 18, true},
		Piece{PieceType.King, 3, 7, 19, true},
		Piece{PieceType.Queen, 4, 7, 20, true},
		Piece{PieceType.Bishop, 5, 7, 21, true},
		Piece{PieceType.Knight, 6, 7, 22, true},
		Piece{PieceType.Rook, 7, 7, 23, true},
		Piece{piece_type = PieceType.Pawn, col = 0, row = 6, index = 24, alive = true},
		Piece{PieceType.Pawn, 1, 6, 25, true},
		Piece{PieceType.Pawn, 2, 6, 26, true},
		Piece{PieceType.Pawn, 3, 6, 27, true},
		Piece{PieceType.Pawn, 4, 6, 28, true},
		Piece{PieceType.Pawn, 5, 6, 29, true},
		Piece{PieceType.Pawn, 6, 6, 30, true},
		Piece{PieceType.Pawn, 7, 6, 31, true},
	}

}

resetSquares :: proc(board: ^Board) {
	//NOTE: resetSquares()
	for _, i in board.squares {
		board.squares[i] = INVALID_INDEX
	}
	board.squares[0] = board.pieces[0].index
	board.squares[1] = board.pieces[1].index
	board.squares[2] = board.pieces[2].index
	board.squares[3] = board.pieces[3].index
	board.squares[4] = board.pieces[4].index
	board.squares[5] = board.pieces[5].index
	board.squares[6] = board.pieces[6].index
	board.squares[7] = board.pieces[7].index
	board.squares[8] = board.pieces[8].index
	board.squares[9] = board.pieces[9].index
	board.squares[10] = board.pieces[10].index
	board.squares[11] = board.pieces[11].index
	board.squares[12] = board.pieces[12].index
	board.squares[13] = board.pieces[13].index
	board.squares[14] = board.pieces[14].index
	board.squares[15] = board.pieces[15].index
	board.squares[48] = board.pieces[24].index
	board.squares[49] = board.pieces[25].index
	board.squares[50] = board.pieces[26].index
	board.squares[51] = board.pieces[27].index
	board.squares[52] = board.pieces[28].index
	board.squares[53] = board.pieces[29].index
	board.squares[54] = board.pieces[30].index
	board.squares[55] = board.pieces[31].index
	board.squares[56] = board.pieces[16].index
	board.squares[57] = board.pieces[17].index
	board.squares[58] = board.pieces[18].index
	board.squares[59] = board.pieces[19].index
	board.squares[60] = board.pieces[20].index
	board.squares[61] = board.pieces[21].index
	board.squares[62] = board.pieces[22].index
	board.squares[63] = board.pieces[23].index
}


// As is chess standard, toSquare is [col,row] (ie. [d,4])
// The piece passed is just the index of the piece in question
movePiece :: proc(board: ^Board, piece: u8, toSquare: u8) {
	//NOTE: movePiece()

	if board.squares[toSquare] == INVALID_INDEX {
		board.squares[board.pieces[piece].row * 8 + board.pieces[piece].col] = INVALID_INDEX
		board.pieces[piece].col = toSquare % 8
		board.pieces[piece].row = toSquare / 8
		board.squares[toSquare] = board.pieces[piece].index
		return
	} else {
		killPiece(board, board.pieces[board.squares[toSquare]].index)
		board.squares[board.pieces[piece].row * 8 + board.pieces[piece].col] = INVALID_INDEX
		board.pieces[piece].col = toSquare % 8
		board.pieces[piece].row = toSquare / 8
		board.squares[toSquare] = board.pieces[piece].index
		return
	}

}

killPiece :: proc(board: ^Board, piece: u8) {
	//NOTE: killPiece()
	board.pieces[piece].alive = false
}

getSquareIndex :: proc(square: [2]u8) -> u8 {
	//NOTE: getSquareIndex()

	return (square.y * 8) + square.x
}

getPiece :: proc(board: ^Board, square: u8) -> u8 {
	//NOTE: getPiece()
	if square > 63 {
		return INVALID_INDEX
	}
	if board.squares[square] == INVALID_INDEX {
		return INVALID_INDEX
	}
	return board.pieces[board.squares[square]].index
}

// Generates a slice of moves that a piece can make
availableMoves :: proc(board: ^Board, piece: u8) -> []u8 {
	//NOTE: availableMoves()
	// Setup return value
	validSquares: [dynamic]u8
	defer delete(validSquares)

	// Logic
	if piece > 32 {return {}}
	p := board.pieces[piece]
	switch p.piece_type {
	case .King:
		// up left
		if p.col > 0 && p.row > 0 {
			append(&validSquares, getSquareIndex({p.col - 1, p.row - 1}))
		}
		// up
		if p.row > 0 {
			append(&validSquares, getSquareIndex({p.col, p.row - 1}))
		}
		// right up
		if p.col < 7 && p.row > 0 {
			append(&validSquares, getSquareIndex({p.col + 1, p.row - 1}))
		}
		// left
		if p.col > 0 {
			append(&validSquares, getSquareIndex({p.col - 1, p.row}))
		}
		// right
		if p.col < 7 {
			append(&validSquares, getSquareIndex({p.col + 1, p.row}))
		}
		// left down
		if p.col > 0 && p.row < 7 {
			append(&validSquares, getSquareIndex({p.col - 1, p.row + 1}))
		}
		// down
		if p.row < 7 {
			append(&validSquares, getSquareIndex({p.col, p.row + 1}))
		}
		// down right
		if p.col < 7 && p.row < 7 {
			append(&validSquares, getSquareIndex({p.col + 1, p.row + 1}))
		}
	case .Pawn:
		if piece < 16 {
			if p.row == 1 {
				append(&validSquares, getSquareIndex({p.col, p.row + 2}))
			}
			append(&validSquares, getSquareIndex({p.col, p.row + 1}))
			if p.col < 7 {
				append(&validSquares, getSquareIndex({p.col + 1, p.row + 1}))
			}
			if p.col > 0 {
				append(&validSquares, getSquareIndex({p.col - 1, p.row + 1}))
			}
		} else {
			if p.row == 6 {
				append(&validSquares, getSquareIndex({p.col, p.row - 2}))
			}
			append(&validSquares, getSquareIndex({p.col, p.row - 1}))
		}
	case .Knight:
		// 2 up 1 left
		if p.col + 1 <= 7 && p.row + 2 <= 7 {
			append(&validSquares, getSquareIndex({p.col + 1, p.row + 2}))
		}
		// 1 up 2 left
		if p.col + 2 <= 7 && p.row + 1 <= 7 {
			append(&validSquares, getSquareIndex({p.col + 2, p.row + 1}))
		}
		// 2 up 1 right
		if p.col >= 1 && p.row + 2 <= 7 {
			append(&validSquares, getSquareIndex({p.col - 1, p.row + 2}))
		}
		// 1 up 2 right
		if p.col >= 2 && p.row + 1 <= 7 {
			append(&validSquares, getSquareIndex({p.col - 2, p.row + 1}))
		}
		// 2 down 1 left
		if p.col + 1 >= 7 && p.row >= 2 {
			append(&validSquares, getSquareIndex({p.col + 1, p.row - 2}))
		}
		// 1 down 2 left
		if p.col + 2 <= 7 && p.row >= 1 {
			append(&validSquares, getSquareIndex({p.col + 2, p.row - 1}))
		}
		// 2 down 1 right
		if p.col >= 1 && p.row >= 2 {
			append(&validSquares, getSquareIndex({p.col - 1, p.row - 2}))
		}
		// 1 down 2 right
		if p.col >= 2 && p.row >= 2 {
			append(&validSquares, getSquareIndex({p.col - 2, p.row - 1}))
		}
	case .Bishop:
		dist_bot := 7 - p.row
		dist_top := p.row
		dist_left := p.col
		dist_right := 7 - p.col
		fmt.printf("db: %v\tdt: %v\tdl: %v\tdr: %v\n", dist_bot, dist_top, dist_left, dist_right)
		// Up and left
		for i: u8 = 1; i <= min(dist_top, dist_left); i += 1 {
			append(&validSquares, getSquareIndex({p.col - i, p.row - i}))
		}
		// up and right
		for i: u8 = 1; i <= min(dist_top, dist_right); i += 1 {
			append(&validSquares, getSquareIndex({p.col + i, p.row - i}))
		}
		//down and left
		for i: u8 = 1; i <= min(dist_bot, dist_left); i += 1 {
			append(&validSquares, getSquareIndex({p.col - i, p.row + i}))
		}
		// down and right
		for i: u8 = 1; i <= min(dist_bot, dist_right); i += 1 {
			append(&validSquares, getSquareIndex({p.col + i, p.row + i}))
		}
	case .Rook:
		dist_bot := 7 - p.row
		dist_top := p.row
		dist_left := p.col
		dist_right := 7 - p.col
		fmt.printf("db: %v\tdt: %v\tdl: %v\tdr: %v\n", dist_bot, dist_top, dist_left, dist_right)
		// Up
		for i: u8 = 1; i <= dist_top; i += 1 {
			append(&validSquares, getSquareIndex({p.col, p.row - i}))
		}
		// Down
		for i: u8 = 1; i <= dist_bot; i += 1 {
			append(&validSquares, getSquareIndex({p.col, p.row + i}))
		}
		//left
		for i: u8 = 1; i <= dist_left; i += 1 {
			append(&validSquares, getSquareIndex({p.col - i, p.row}))
		}
		// right
		for i: u8 = 1; i <= dist_right; i += 1 {
			append(&validSquares, getSquareIndex({p.col + i, p.row}))
		}
	case .Queen:
		dist_bot := 7 - p.row
		dist_top := p.row
		dist_left := p.col
		dist_right := 7 - p.col
		fmt.printf("db: %v\tdt: %v\tdl: %v\tdr: %v\n", dist_bot, dist_top, dist_left, dist_right)
		// Up
		for i: u8 = 1; i <= dist_top; i += 1 {
			append(&validSquares, getSquareIndex({p.col, p.row - i}))
		}
		// Down
		for i: u8 = 1; i <= dist_bot; i += 1 {
			append(&validSquares, getSquareIndex({p.col, p.row + i}))
		}
		// Left
		for i: u8 = 1; i <= dist_left; i += 1 {
			append(&validSquares, getSquareIndex({p.col - i, p.row}))
		}
		// Right
		for i: u8 = 1; i <= dist_right; i += 1 {
			append(&validSquares, getSquareIndex({p.col + i, p.row}))
		}
		for i: u8 = 1; i <= min(dist_top, dist_left); i += 1 {
			append(&validSquares, getSquareIndex({p.col - i, p.row - i}))
		}
		// up and right
		for i: u8 = 1; i <= min(dist_top, dist_right); i += 1 {
			append(&validSquares, getSquareIndex({p.col + i, p.row - i}))
		}
		//down and left
		for i: u8 = 1; i <= min(dist_bot, dist_left); i += 1 {
			append(&validSquares, getSquareIndex({p.col - i, p.row + i}))
		}
		// down and right
		for i: u8 = 1; i <= min(dist_bot, dist_right); i += 1 {
			append(&validSquares, getSquareIndex({p.col + i, p.row + i}))
		}
	}
	// Return a slice of the whole the underlying array
	return validSquares[:]
}
moveLegality :: proc(board: ^Board, piece: u8, square: u8) {
	// NOTE: moveLegality()
}
