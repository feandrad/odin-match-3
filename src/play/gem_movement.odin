package play

import b "../board"
import c "../collection"
import i "../input"
import rl "vendor:raylib"

GemMovement :: struct {
    from: i.GridPosition,
    to: i.GridPosition,
    gem: b.GemType,
}

detect_column_fall :: proc(board: ^b.Board, col: int) -> [dynamic]GemMovement {
    movements: [dynamic]GemMovement
    empty_slots := 0

    for row := (b.GRID_HEIGHT - 1) ; row >= 0 ; row -= 1 {
        gem := board.slots[row][col].gem
        if gem == .None {
            empty_slots += 1
            rl.TraceLog(.DEBUG, "Column %d, row %d is empty. Empty count: %d", col, row, empty_slots)
        } else if empty_slots > 0 {
            from := i.GridPosition{ col, row }
            to := i.GridPosition{ col, row + empty_slots }
            rl.TraceLog(.DEBUG, "Gem %v at (%d, %d) will fall to (%d, %d)", gem, from.x, from.y, to.x, to.y)

            append(&movements, GemMovement{ from, to, gem })
            b.mark_slot_to_move(board, to.y,to.x)
            b.mark_slot_to_move(board, row, col)

            rl.TraceLog(.DEBUG, "Marked gem %v to move to slot[%d][%d]", gem, to.y, to.x)
        }
    }

    rl.TraceLog(.DEBUG, "Column %d completed with %d movements", col, len(movements))
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
