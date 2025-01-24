package chess

import "core:fmt"
import "core:mem"
import "core:os"
import rl "vendor:raylib"


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

	// NOTE: RL Setup stuff
	rl.InitWindow(1280, 720, "Chess")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60.0)

	// NOTE: Rendering Setup stuff
	SCREEN_WIDTH = rl.GetScreenWidth()
	SCREEN_HEIGHT = rl.GetScreenHeight()
	SQUARE_SIDE_LENGTH = min(SCREEN_HEIGHT, SCREEN_WIDTH) / 8
	board_color1 := rl.LIGHTGRAY
	board_color2 := rl.DARKGRAY
	PIECE_COLOR1 = rl.WHITE
	PIECE_COLOR2 = rl.Color{30, 30, 30, 255}
	king_texture := rl.LoadTextureFromImage(rl.LoadImage("./assets/King_White.png"))
	kt := rl.LoadTexture("./assets/King_White.png")
	TEXTURE_SCALE = f32(SQUARE_SIDE_LENGTH) / 270.0
	defer rl.UnloadTexture(king_texture)
	cam := rl.Camera2D {
		offset   = rl.Vector2{f32(SCREEN_WIDTH / 2), f32(SCREEN_HEIGHT / 2)},
		target   = rl.Vector2{f32(SQUARE_SIDE_LENGTH * 4), f32(SQUARE_SIDE_LENGTH * 4)},
		rotation = 0.0,
		zoom     = 1.0,
	}
	flipCamera(&cam)

	// NOTE: Chess setup stuff
	board := newGame()
	p := Piece{}
	//movePiece(&board, 12, {d, 4})
	fmt.printf("\nTHE PIECE IS :%v\n", getPiece(&board, getSquareIndex({d, 6})))

	// NOTE: Start of rendering
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.BeginMode2D(cam)
		drawBoard(board_color1, board_color2)
		for _, i in board.pieces {
			p = board.pieces[i]
			if (p.col < 8 && p.col >= 0) && (p.row < 8 && p.row >= 0) {
				if i < 16 {
					rl.DrawTexturePro(
						kt,
						rl.Rectangle{0, 0, 256, 256},
						rl.Rectangle {
							f32(SQUARE_SIDE_LENGTH + 2),
							f32(SQUARE_SIDE_LENGTH),
							f32(SQUARE_SIDE_LENGTH),
							f32(SQUARE_SIDE_LENGTH),
						},
						rl.Vector2 {
							f32(i32(p.col) * SQUARE_SIDE_LENGTH),
							f32(i32(p.row) * SQUARE_SIDE_LENGTH),
						},
						180,
						PIECE_COLOR1,
					)
				} else {
					//rl.DrawCircle(
					//	i32(p.col) * SQUARE_SIDE_LENGTH + SQUARE_SIDE_LENGTH / 2,
					//	i32(p.row) * SQUARE_SIDE_LENGTH + SQUARE_SIDE_LENGTH / 2,
					//	f32(SQUARE_SIDE_LENGTH) / 4,
					//	PIECE_COLOR2,
					//)
					// TODO: Need to rewatch the tutorial for how to draw these
					// https://zylinski.se/posts/gamedev-for-beginners-using-odin-and-raylib-3/
					rl.DrawTexturePro(
						kt,
						rl.Rectangle{0, 0, 256, 256},
						rl.Rectangle {
							f32(SQUARE_SIDE_LENGTH - 2),
							f32(SQUARE_SIDE_LENGTH),
							f32(SQUARE_SIDE_LENGTH),
							f32(SQUARE_SIDE_LENGTH),
						},
						rl.Vector2 {
							f32(i32(p.col) * SQUARE_SIDE_LENGTH - SQUARE_SIDE_LENGTH * 6),
							f32(SQUARE_SIDE_LENGTH - (i32(p.row) * SQUARE_SIDE_LENGTH)),
						},
						0,
						PIECE_COLOR2,
					)
				}
			}
		}
		if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
			fmt.println(getPiece(&board, clickedSquare(&cam)))
		}
		rl.EndMode2D()
		rl.EndDrawing()
	}
	for p in board.squares {
		if p != nil {
			fmt.println(p^)
		}
	}
}
// INFO: Setting up variable for rendering
SCREEN_HEIGHT: i32
SCREEN_WIDTH: i32
SQUARE_SIDE_LENGTH: i32

PIECE_COLOR1: rl.Color
PIECE_COLOR2: rl.Color
BOARD_COLOR1: rl.Color
BOARD_COLOR2: rl.Color
TEXTURE_SCALE: f32

// INFO: Creating types for Chess
Board :: struct {
	// 0-15 White , 16-31 Black
	// rook,knigt,bishop,queen,king,bishop,knight,rook
	// pawn,pawn,pawn,pawn,pawn,pawn,pawn,pawn
	// rook,knigt,bishop,queen,king,bishop,knight,rook
	// pawn,pawn,pawn,pawn,pawn,pawn,pawn,pawn
	pieces:  [32]Piece,
	squares: [64]^Piece,
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

// INFO: Creating variables and constants for chess

// NOTE: Since we made white the top, we have to reverse which column has what letter assigned to it
a :: 7
b :: 6
c :: 5
d :: 4
e :: 3
f :: 2
g :: 1
h :: 0

newGame :: proc() -> Board {
	reset_board: Board
	resetPieces(&reset_board)
	resetSquares(&reset_board)
	return reset_board
}


resetPieces :: proc(board: ^Board) {
	board.pieces = {
		Piece{piece_type = PieceType.Rook, col = 0, row = 0, index = 0, alive = true},
		Piece{PieceType.Knight, 1, 0, 0, true},
		Piece{PieceType.Bishop, 2, 0, 0, true},
		Piece{PieceType.Queen, 3, 0, 0, true},
		Piece{PieceType.King, 4, 0, 0, true},
		Piece{PieceType.Bishop, 5, 0, 0, true},
		Piece{PieceType.Knight, 6, 0, 0, true},
		Piece{PieceType.Rook, 7, 0, 0, true},
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
		Piece{PieceType.Queen, 3, 7, 19, true},
		Piece{PieceType.King, 4, 7, 20, true},
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

// BUG: THIS DOES NOT WORK
resetSquares :: proc(board: ^Board) {
	board.squares[0] = &board.pieces[0]
	board.squares[1] = &board.pieces[1]
	board.squares[2] = &board.pieces[2]
	board.squares[3] = &board.pieces[3]
	board.squares[4] = &board.pieces[4]
	board.squares[5] = &board.pieces[5]
	board.squares[6] = &board.pieces[6]
	board.squares[7] = &board.pieces[7]
	board.squares[8] = &board.pieces[8]
	board.squares[9] = &board.pieces[9]
	board.squares[10] = &board.pieces[10]
	board.squares[11] = &board.pieces[11]
	board.squares[12] = &board.pieces[12]
	board.squares[13] = &board.pieces[13]
	board.squares[14] = &board.pieces[14]
	board.squares[15] = &board.pieces[15]
	board.squares[48] = &board.pieces[24]
	board.squares[49] = &board.pieces[25]
	board.squares[50] = &board.pieces[26]
	board.squares[51] = &board.pieces[27]
	board.squares[52] = &board.pieces[28]
	board.squares[53] = &board.pieces[29]
	board.squares[54] = &board.pieces[30]
	board.squares[55] = &board.pieces[31]
	board.squares[56] = &board.pieces[16]
	board.squares[57] = &board.pieces[17]
	board.squares[58] = &board.pieces[18]
	board.squares[59] = &board.pieces[19]
	board.squares[60] = &board.pieces[20]
	board.squares[61] = &board.pieces[21]
	board.squares[62] = &board.pieces[22]
	board.squares[63] = &board.pieces[23]
}

drawBoard :: proc(board_color1, board_color2: rl.Color) {
	for y: i32 = 0; y < 8; y += 1 {
		for x: i32 = 0; x < 8; x += 1 {
			if (x % 2 + y % 2) % 2 == 0 {
				rl.DrawRectangle(
					x * SQUARE_SIDE_LENGTH,
					y * SQUARE_SIDE_LENGTH,
					SQUARE_SIDE_LENGTH,
					SQUARE_SIDE_LENGTH,
					board_color1,
				)
			} else {
				rl.DrawRectangle(
					x * SQUARE_SIDE_LENGTH,
					y * SQUARE_SIDE_LENGTH,
					SQUARE_SIDE_LENGTH,
					SQUARE_SIDE_LENGTH,
					board_color2,
				)
			}
		}
	}
}

flipCamera :: proc(cam: ^rl.Camera2D) {
	if cam.rotation == 0 {
		cam.rotation = 180
	} else {
		cam.rotation = 0
	}
}

clickedSquare :: proc(cam: ^rl.Camera2D) -> u8 {
	m_x := rl.GetMouseX()
	m_y := rl.GetMouseY()
	board_size := 8 * SQUARE_SIDE_LENGTH
	offset_x := (SCREEN_WIDTH - board_size) / 2
	offset_y := (SCREEN_HEIGHT - board_size) / 2
	if m_x < offset_x || m_x > board_size + offset_x {
		return 255
	}
	if m_y < offset_y || m_y > board_size + offset_y {
		return 255
	}
	row := (m_y - offset_y) / SQUARE_SIDE_LENGTH
	col := (m_x - offset_x) / SQUARE_SIDE_LENGTH

	if cam.rotation == 0 {
		fmt.printf("Clicked Square is %v\n", 8 * row + col)
	} else if cam.rotation == 180 {
		fmt.printf("Clicked Square is %v\n", 64 - (8 * row + col) - 1)
	}
	return 0
}

// NOTE: As is chess standard, toSquare is [col,row] (ie. [d,4])
// The piece passed is just the index of the piece in question
movePiece :: proc(board: ^Board, piece: u8, toSquare: u8) {

	if board.squares[toSquare] == nil {
		board.squares[board.pieces[piece].row * 8 + board.pieces[piece].col] = nil
		board.pieces[piece].col = toSquare % 8
		board.pieces[piece].row = toSquare / 8
		board.squares[toSquare] = &board.pieces[piece]
		return
	} else {
		killPiece(board, board.squares[toSquare].index)
		board.squares[board.pieces[piece].row * 8 + board.pieces[piece].col] = nil
		board.pieces[piece].col = toSquare % 8
		board.pieces[piece].row = toSquare / 8
		board.squares[toSquare] = &board.pieces[piece]
		return
	}

}

killPiece :: proc(board: ^Board, piece: u8) {
	board.pieces[piece].alive = false
}

getSquareIndex :: proc(square: [2]u8) -> u8 {
	answer := ((square.y - 1) * 8) + square.x
	fmt.println(answer)

	return answer
}

getPiece :: proc(board: ^Board, square: u8) -> u8 {
	if square > 63 {
		return 255
	}
	if board.squares[square] == nil {
		return 254
	}
	return board.squares[square].index
}
