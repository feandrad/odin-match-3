package play

import rl "vendor:raylib"

DragState :: struct {
    dragging   : bool,
    start_grid : GridPosition,
    start_world: rl.Vector2,
    offset     : rl.Vector2,
}

init_drag_state :: proc() -> DragState {
    return DragState{ }
}

clamp :: proc(v, lo, hi: f32) -> f32 {
    if v < lo {
        return lo
    }
    if v > hi {
        return hi
    }
    return v
}



update_drag :: proc(b: ^Board, s: ^DragState, on_swap: proc(a, b: GridPosition)) {
    m := rl.GetMousePosition()

    if !s.dragging && rl.IsMouseButtonPressed(.LEFT) {
        if gp, ok := world_to_grid(b^, m); ok {
            s.dragging = true
            s.start_grid = gp
            s.start_world = grid_to_world(b^, gp)
            s.offset = rl.Vector2{ }
        }
    }

    if s.dragging {
        dx := m.x - s.start_world.x
        dy := m.y - s.start_world.y
        dist := rl.Vector2Length(rl.Vector2{ dx, dy })

        if dist < CELL_SIZE * 0.5 {
            s.offset = rl.Vector2{ dx, dy }
        } else {
            max_drag := CELL_SIZE
            if abs(dx) > abs(dy) {
            // lock X
                s.offset.x = clamp(dx, -max_drag, max_drag)
                s.offset.y = 0
            } else {
            // lock Y
                s.offset.y = clamp(dy, -max_drag, max_drag)
                s.offset.x = 0
            }
        }

        if rl.IsMouseButtonReleased(.LEFT) {
            end_world := s.start_world + s.offset
            if end_gp, ok := world_to_grid(b^, end_world); ok &&
            are_adjacent(s.start_grid, end_gp) && s.start_grid != end_gp {
                swap_gems(b, s.start_grid, end_gp)
                if on_swap != nil {
                    on_swap(s.start_grid, end_gp)
                }
            }
            s^ = DragState{ } // reset
        }
    }
}

draw_drag :: proc(b: Board, s: DragState) {
    if !s.dragging {
        return
    }
    pos := s.start_world + s.offset
    rl.DrawRectangleLines(i32(pos.x), i32(pos.y), i32(CELL_SIZE), i32(CELL_SIZE), rl.WHITE)
}

LIGHT_BLUE_GRAY :: rl.Color{0xB0, 0xC4, 0xDE, 0xFF}

draw_hover :: proc(b: Board, s: DragState) {
    if gp, ok := world_to_grid(b, rl.GetMousePosition()); ok {
        pos := grid_to_world(b, gp)
        rl.DrawRectangleLines(i32(pos.x), i32(pos.y), i32(CELL_SIZE), i32(CELL_SIZE), LIGHT_BLUE_GRAY)
    }
}
