package play

import b "../board"
import i "../input"
import rl "vendor:raylib"

DragState :: struct {
    dragging   : bool,
    start_grid : i.GridPosition,
    start_world: rl.Vector2,
    offset     : rl.Vector2,
}

init_drag_state :: proc() -> i.DragState {
    return i.DragState{ }
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

begin_drag :: proc(board: b.Board, s: ^i.DragState, m: rl.Vector2) {
    if s.dragging {
        return
    }
    if rl.IsMouseButtonPressed(.LEFT) {
        if gp, ok := b.world_to_grid(board, m); ok {
            s.dragging = true
            s.start_grid = gp
            s.start_world = b.grid_to_world(board, gp)
            s.offset = rl.Vector2{ }
        }
    }
}

axis_offset :: proc(dx, dy: f32, s: i.DragState) -> rl.Vector2 {
    if rl.Vector2Length(rl.Vector2{ dx, dy }) < b.CELL_SIZE * 0.5 {
        return rl.Vector2{ dx, dy }
    }

    max_drag : f32 = b.CELL_SIZE

    if abs(dx) > abs(dy) {
    // horizontal
        lo : f32 = 0.0 if s.start_grid.x == 0 else -max_drag
        hi : f32 = 0.0 if s.start_grid.x == b.GRID_WIDTH - 1 else max_drag
        return rl.Vector2{ clamp(dx, lo, hi), 0 }
    } else {
    // vertical
        lo : f32 = 0.0 if s.start_grid.y == 0 else -max_drag
        hi : f32 = 0.0 if s.start_grid.y == b.GRID_HEIGHT - 1 else max_drag
        return rl.Vector2{ 0, clamp(dy, lo, hi) }
    }
}

end_drag :: proc(board: ^b.Board, s: ^i.DragState, on_swap: proc(a, b: i.GridPosition)) {
    if !rl.IsMouseButtonReleased(.LEFT) {
        return
    }
    end_world := s.start_world + s.offset
    if gp, ok := b.world_to_grid(board^, end_world); ok {
        if b.is_valid(gp) && b.are_adjacent(s.start_grid, gp) && s.start_grid != gp {
            b.swap_slots(board, s.start_grid, gp)
            if on_swap != nil {
                on_swap(s.start_grid, gp)
            }
        }
    }
    s^ = i.DragState{ }
}

update_drag :: proc(b: ^b.Board, s: ^i.DragState, on_swap: proc(a, b: i.GridPosition)) {
    m := rl.GetMousePosition()
    begin_drag(b^, s, m)

    if s.dragging {
        dx := m.x - s.start_world.x
        dy := m.y - s.start_world.y
        s.offset = axis_offset(dx, dy, s^)
        end_drag(b, s, on_swap)
    }
}

draw_drag :: proc(board: b.Board, s: i.DragState) {
    if !s.dragging {
        return
    }
    g := b.get_gem(board, s.start_grid)
    if g == .None {
        return
    }
    pos := s.start_world + s.offset
    padding := b.CELL_SIZE * 0.1
    rl.DrawRectangle(i32(pos.x + padding), i32(pos.y + padding),
    i32(b.CELL_SIZE - padding * 2), i32(b.CELL_SIZE - padding * 2),
    b.gem_color(g))
    rl.DrawRectangleLines(i32(pos.x), i32(pos.y), i32(b.CELL_SIZE), i32(b.CELL_SIZE), rl.WHITE)
}

LIGHT_BLUE_GRAY :: rl.Color{ 0xB0, 0xC4, 0xDE, 0xFF }

draw_hover :: proc(board: b.Board, s: i.DragState) {
    if gp, ok := b.world_to_grid(board, rl.GetMousePosition()); ok {
        pos := b.grid_to_world(board, gp)
        rl.DrawRectangleLines(i32(pos.x), i32(pos.y), i32(b.CELL_SIZE), i32(b.CELL_SIZE), LIGHT_BLUE_GRAY)
    }
}
