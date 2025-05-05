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

begin_drag :: proc(b: Board, s: ^DragState, m: rl.Vector2) {
    if s.dragging {
        return
    }
    if rl.IsMouseButtonPressed(.LEFT) {
        if gp, ok := world_to_grid(b, m); ok {
            s.dragging = true
            s.start_grid = gp
            s.start_world = grid_to_world(b, gp)
            s.offset = rl.Vector2{ }
        }
    }
}

axis_offset :: proc(dx, dy: f32, s: DragState) -> rl.Vector2 {
    if rl.Vector2Length(rl.Vector2{ dx, dy }) < CELL_SIZE * 0.5 {
        return rl.Vector2{ dx, dy }
    }

    max_drag : f32 = CELL_SIZE

    if abs(dx) > abs(dy) {
    // horizontal
        lo : f32 = 0.0 if s.start_grid.x == 0 else -max_drag
        hi : f32 = 0.0 if s.start_grid.x == GRID_WIDTH - 1 else max_drag
        return rl.Vector2{ clamp(dx, lo, hi), 0 }
    } else {
    // vertical
        lo : f32 = 0.0 if s.start_grid.y == 0 else -max_drag
        hi : f32 = 0.0 if s.start_grid.y == GRID_HEIGHT - 1 else max_drag
        return rl.Vector2{ 0, clamp(dy, lo, hi) }
    }
}

end_drag :: proc(b: ^Board, s: ^DragState, on_swap: proc(a, b: GridPosition)) {
    if !rl.IsMouseButtonReleased(.LEFT) {
        return
    }
    end_world := s.start_world + s.offset
    if gp, ok := world_to_grid(b^, end_world); ok &&
    are_adjacent(s.start_grid, gp) && s.start_grid != gp {
        swap_gems(b, s.start_grid, gp)
        if on_swap != nil {
            on_swap(s.start_grid, gp)
        }
    }
    s^ = DragState{ }
}

update_drag :: proc(b: ^Board, s: ^DragState, on_swap: proc(a, b: GridPosition)) {
    m := rl.GetMousePosition()
    begin_drag(b^, s, m)

    if s.dragging {
        dx := m.x - s.start_world.x
        dy := m.y - s.start_world.y
        s.offset = axis_offset(dx, dy, s^)
        end_drag(b, s, on_swap)
    }
}

draw_drag :: proc(b: Board, s: DragState) {
    if !s.dragging {
        return
    }
    g := get_gem(b, s.start_grid)
    if g == .None {
        return
    }
    pos := s.start_world + s.offset
    padding := CELL_SIZE * 0.1
    rl.DrawRectangle(i32(pos.x + padding), i32(pos.y + padding),
    i32(CELL_SIZE - padding * 2), i32(CELL_SIZE - padding * 2),
    gem_color(g))
    rl.DrawRectangleLines(i32(pos.x), i32(pos.y), i32(CELL_SIZE), i32(CELL_SIZE), rl.WHITE)
}

LIGHT_BLUE_GRAY :: rl.Color{ 0xB0, 0xC4, 0xDE, 0xFF }

draw_hover :: proc(b: Board, s: DragState) {
    if gp, ok := world_to_grid(b, rl.GetMousePosition()); ok {
        pos := grid_to_world(b, gp)
        rl.DrawRectangleLines(i32(pos.x), i32(pos.y), i32(CELL_SIZE), i32(CELL_SIZE), LIGHT_BLUE_GRAY)
    }
}
