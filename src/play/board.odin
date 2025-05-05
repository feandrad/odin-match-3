package play

import c  "../common"
import rl "vendor:raylib"

GRID_WIDTH :: 6
GRID_HEIGHT :: 8
CELL_SIZE :: f32(64.0)

GridPosition :: struct {
    x: int,
    y: int,
}

Board :: struct {
    slots  : [GRID_HEIGHT][GRID_WIDTH]GemType,
    start_x: f32,
    start_y: f32,
}

is_valid :: proc(p: GridPosition) -> bool {
    return p.x >= 0 && p.x < GRID_WIDTH &&
    p.y >= 0 && p.y < GRID_HEIGHT
}

set_slot :: proc(b: ^Board, p: GridPosition, gem: GemType) {
    if is_valid(p) {
        b.slots[p.y][p.x] = gem
    } else {
        rl.TraceLog(.ERROR, "set_slot: invalid GridPosition (%d, %d)", p.x, p.y)
    }
}

gem_color :: proc(g: GemType) -> rl.Color {
    #partial switch g {
    case .Red: return rl.RED
    case .Blue: return rl.BLUE
    case .Green: return rl.GREEN
    case .Yellow: return rl.YELLOW
    case .Purple: return rl.PURPLE
    case .Orange: return rl.ORANGE
    case .White: return rl.WHITE
    case .Black: return rl.BLACK
    }
    return rl.WHITE
}

init_board :: proc() -> Board {
    b := Board { }
    b.start_x = f32(c.SCREEN_WIDTH - int(GRID_WIDTH * CELL_SIZE)) / 2
    b.start_y = f32(c.SCREEN_HEIGHT - int(GRID_HEIGHT * CELL_SIZE)) / 2
    for y in 0 ..< GRID_HEIGHT {
        for x in 0 ..< GRID_WIDTH {
            r := rl.GetRandomValue(i32(GemType.Red), i32(GemType.Orange))
            gem := GemType(r)
            b.slots[y][x] = gem
            rl.TraceLog(.DEBUG, "init_board: slot[%d][%d] = %s", y, x, gem_to_string(gem))
        }
    }
    return b
}

is_in_bounds :: proc(p: GridPosition) -> bool {
    return 0 <= p.x && p.x < GRID_WIDTH && 0 <= p.y && p.y < GRID_HEIGHT
}

grid_to_world :: proc(b: Board, p: GridPosition) -> rl.Vector2 {
    return rl.Vector2{ b.start_x + f32(p.x) * CELL_SIZE, b.start_y + f32(p.y) * CELL_SIZE }
}

world_to_grid :: proc(b: Board, w: rl.Vector2) -> (GridPosition, bool) {
    g := GridPosition{ int((w.x - b.start_x) / CELL_SIZE), int((w.y - b.start_y) / CELL_SIZE) }
    return g, is_in_bounds(g)
}

get_gem :: proc(b: Board, p: GridPosition) -> GemType {
    if !is_in_bounds(p) { return .None }
    return b.slots[p.y][p.x]
}

set_gem :: proc(b: ^Board, p: GridPosition, g: GemType) {
    if is_in_bounds(p) {
        b.slots[p.y][p.x] = g
    }
}

are_adjacent :: proc(a, b: GridPosition) -> bool {
    dx := abs(a.x - b.x)
    dy := abs(a.y - b.y)
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1)
}

get_slot :: proc(b: Board, p: GridPosition) -> GemType {
    if is_valid(p) {
        return b.slots[p.y][p.x]
    }
    rl.TraceLog(.ERROR, "get_slot: invalid GridPosition (%d, %d)", p.x, p.y)
    return .None
}

swap_slots :: proc(b: ^Board, a, b_: GridPosition) {
    if is_valid(a) && is_valid(b_) {
        tmp := b.slots[a.y][a.x]
        b.slots[a.y][a.x] = b.slots[b_.y][b_.x]
        b.slots[b_.y][b_.x] = tmp
    } else {
        rl.TraceLog(.ERROR, "swap_slots: invalid GridPositions (%d, %d) <-> (%d, %d)",
        a.x, a.y, b_.x, b_.y)
    }
}

draw_board :: proc(b: Board, s: DragState) {
    rl.DrawRectangle(i32(b.start_x), i32(b.start_y),
    i32(GRID_WIDTH * CELL_SIZE), i32(GRID_HEIGHT * CELL_SIZE),
    rl.DARKBROWN)

    for i in 0 ..= GRID_WIDTH {
        rl.DrawLineEx(rl.Vector2{ b.start_x + f32(i) * CELL_SIZE, b.start_y },
        rl.Vector2{ b.start_x + f32(i) * CELL_SIZE, b.start_y + f32(GRID_HEIGHT) * CELL_SIZE },
        1, rl.LIGHTGRAY)
    }
    for i in 0 ..= GRID_HEIGHT {
        rl.DrawLineEx(rl.Vector2{ b.start_x, b.start_y + f32(i) * CELL_SIZE },
        rl.Vector2{ b.start_x + f32(GRID_WIDTH) * CELL_SIZE, b.start_y + f32(i) * CELL_SIZE },
        1, rl.LIGHTGRAY)
    }

    padding := CELL_SIZE * 0.1
    for y in 0 ..< GRID_HEIGHT {
        for x in 0 ..< GRID_WIDTH {
            if s.dragging && x == s.start_grid.x && y == s.start_grid.y { continue }
            g := b.slots[y][x]
            if g == .None { continue }
            p := grid_to_world(b, GridPosition{ x, y })
            rl.DrawRectangle(i32(p.x + padding), i32(p.y + padding),
            i32(CELL_SIZE - padding * 2), i32(CELL_SIZE - padding * 2),
            gem_color(g))
        }
    }
}
