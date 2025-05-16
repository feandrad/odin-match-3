package play

import b "../board"
import c "../collection"
import i "../input"

GemMovement :: struct {
    from: i.GridPosition,
    to:   i.GridPosition,
    gem:  b.GemType,
}

detect_column_fall :: proc(board: ^b.Board, x: int) -> [dynamic]GemMovement {
    movements: [dynamic]GemMovement
    empty_slots := 0

    for y in 0 ..< b.GRID_HEIGHT {
        gem := board.slots[y][x]
        if gem == .None {
            empty_slots += 1
        } else if empty_slots > 0 {
            from := i.GridPosition{x, y}
            to   := i.GridPosition{x, y + empty_slots}
            append(&movements, GemMovement{from, to, gem})
            board.slots[to.y][to.x] = gem
            board.slots[y][x] = .None
        }
    }

    return movements
}

handle_falls :: proc(board: ^b.Board) -> [dynamic]GemMovement {
    movements: [dynamic]GemMovement
    for x in 0 ..< b.GRID_WIDTH {
        col_moves := detect_column_fall(board, x)
        c.append_all(GemMovement, &movements, col_moves)
    }
    return movements
}
