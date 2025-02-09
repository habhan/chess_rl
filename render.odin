package chess

import "core:fmt"
import rl "vendor:raylib"

// NOTE: Setting up variable for rendering
SCREEN_HEIGHT: i32
SCREEN_WIDTH: i32
SQUARE_SIDE_LENGTH: i32

PIECE_COLOR1: rl.Color
PIECE_COLOR2: rl.Color
BOARD_COLOR1: rl.Color
BOARD_COLOR2: rl.Color
TEXTURE_SIDE_LENGTH :: 270

PieceTypeTexture :: [PieceType]cstring {
	.King   = "./assets/King_White.png",
	.Pawn   = "./assets/Pawn_White.png",
	.Knight = "./assets/Knight_White.png",
	.Bishop = "./assets/Bishop_White.png",
	.Rook   = "./assets/Rook_White.png",
	.Queen  = "./assets/Queen_White.png",
}
render :: proc(board: ^Board, moveList: ^[dynamic]u8) {

	// NOTE: RL Setup stuff
	rl.InitWindow(1280, 1280, "Chess")
	defer rl.CloseWindow()
	rl.SetWindowState({.WINDOW_RESIZABLE})
	rl.SetTargetFPS(100.0)

	// NOTE: Rendering Setup stuff
	SCREEN_WIDTH = rl.GetScreenWidth()
	SCREEN_HEIGHT = rl.GetScreenHeight()
	SQUARE_SIDE_LENGTH = min(SCREEN_HEIGHT, SCREEN_WIDTH) / 8
	board_color1 := rl.LIGHTGRAY
	board_color2 := rl.DARKGRAY
	PIECE_COLOR1 = rl.RED
	PIECE_COLOR2 = rl.Color{30, 30, 30, 255}
	textures: [6]rl.Texture
	for v, i in PieceTypeTexture {
		textures[i] = rl.LoadTextureFromImage(rl.LoadImage(v))
	}
	defer {for _, i in textures {
			rl.UnloadTexture(textures[i])
		}
	}
	cam := rl.Camera2D {
		offset   = rl.Vector2{f32(SCREEN_WIDTH / 2), f32(SCREEN_HEIGHT / 2)},
		target   = rl.Vector2{f32(SQUARE_SIDE_LENGTH * 4), f32(SQUARE_SIDE_LENGTH * 4)},
		rotation = 0.0,
		zoom     = 1.0,
	}
	//flipCamera(&cam)
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.BeginMode2D(cam)
		rl.ClearBackground(rl.BLACK)
		drawBoard(board_color1, board_color2, &cam)
		for _, i in board.pieces {
			p := board.pieces[i]
			if (p.col < 8 && p.col >= 0) && (p.row < 8 && p.row >= 0) {
				if i < 16 {
					if cam.rotation == 180 {
						rl.DrawTexturePro(
							textures[p.piece_type],
							rl.Rectangle{0, 0, 270, 270},
							rl.Rectangle {
								f32(SQUARE_SIDE_LENGTH),
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

						rl.DrawTexturePro(
							textures[p.piece_type],
							rl.Rectangle{0, 0, 270, 270},
							rl.Rectangle {
								f32(SQUARE_SIDE_LENGTH),
								f32(SQUARE_SIDE_LENGTH),
								f32(SQUARE_SIDE_LENGTH),
								f32(SQUARE_SIDE_LENGTH),
							},
							rl.Vector2 {
								f32(SQUARE_SIDE_LENGTH - i32(p.col) * SQUARE_SIDE_LENGTH),
								f32(SQUARE_SIDE_LENGTH - (i32(p.row) * SQUARE_SIDE_LENGTH)),
							},
							0,
							PIECE_COLOR1,
						)
					}
				} else {
					//rl.DrawCircle(
					//	i32(p.col) * SQUARE_SIDE_LENGTH + SQUARE_SIDE_LENGTH / 2,
					//	i32(p.row) * SQUARE_SIDE_LENGTH + SQUARE_SIDE_LENGTH / 2,
					//	f32(SQUARE_SIDE_LENGTH) / 4,
					//	PIECE_COLOR2,
					//)
					// https://zylinski.se/posts/gamedev-for-beginners-using-odin-and-raylib-3/
					if cam.rotation == 180 {
						rl.DrawTexturePro(
							textures[p.piece_type],
							rl.Rectangle{0, 0, 256, 256},
							rl.Rectangle {
								f32(SQUARE_SIDE_LENGTH),
								f32(SQUARE_SIDE_LENGTH),
								f32(SQUARE_SIDE_LENGTH),
								f32(SQUARE_SIDE_LENGTH),
							},
							rl.Vector2 {
								f32(i32(p.col) * SQUARE_SIDE_LENGTH),
								f32((i32(p.row) * SQUARE_SIDE_LENGTH)),
							},
							180,
							PIECE_COLOR2,
						)
					} else {

						rl.DrawTexturePro(
							textures[p.piece_type],
							rl.Rectangle{0, 0, 256, 256},
							rl.Rectangle {
								f32(SQUARE_SIDE_LENGTH),
								f32(SQUARE_SIDE_LENGTH),
								f32(SQUARE_SIDE_LENGTH),
								f32(SQUARE_SIDE_LENGTH),
							},
							rl.Vector2 {
								f32(SQUARE_SIDE_LENGTH - i32(p.col) * SQUARE_SIDE_LENGTH),
								f32(SQUARE_SIDE_LENGTH - (i32(p.row) * SQUARE_SIDE_LENGTH)),
							},
							0,
							PIECE_COLOR2,
						)
					}
				}
			}
		}
		if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
			fmt.println("This piece has the following available:")
			for move in availableMoves(board, getPiece(board, clickedSquare(&cam)), moveList) {
				fmt.println(moveClassification(board, move, getPiece(board, clickedSquare(&cam))))
			}
		}

		rl.EndMode2D()
		rl.EndDrawing()
	}
}
drawBoard :: proc(board_color1, board_color2: rl.Color, cam: ^rl.Camera2D) {
	SCREEN_WIDTH = rl.GetScreenWidth()
	SCREEN_HEIGHT = rl.GetScreenHeight()

	SQUARE_SIDE_LENGTH = min(SCREEN_HEIGHT, SCREEN_WIDTH) / 8
	cam.offset = rl.Vector2{f32(SCREEN_WIDTH / 2), f32(SCREEN_HEIGHT / 2)}
	cam.target = rl.Vector2{f32(SQUARE_SIDE_LENGTH * 4), f32(SQUARE_SIDE_LENGTH * 4)}
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
		return INVALID_INDEX
	}
	if m_y < offset_y || m_y > board_size + offset_y {
		return INVALID_INDEX
	}
	row := (m_y - offset_y) / SQUARE_SIDE_LENGTH
	col := (m_x - offset_x) / SQUARE_SIDE_LENGTH

	if cam.rotation == 0 {
		return u8(8 * row + col)
	} else if cam.rotation == 180 {
		return u8(64 - (8 * row + col) - 1)
	}
	return 255
}
