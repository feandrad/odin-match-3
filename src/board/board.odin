package board

import c  "../common"
import input "../input"
import rl "vendor:raylib"

GRID_WIDTH :: 6
GRID_HEIGHT :: 8
CELL_SIZE :: f32(64.0)

Board :: struct {
    slots  : [GRID_HEIGHT][GRID_WIDTH]Slot,
    start_x: f32,
    start_y: f32,
}

Slot :: struct {
    gem   : GemType,
    moving: bool,
}

is_valid :: proc(p: input.GridPosition) -> bool {
    return p.x >= 0 && p.x < GRID_WIDTH &&
    p.y >= 0 && p.y < GRID_HEIGHT
}

set_slot :: proc(b: ^Board, p: input.GridPosition, gem: GemType) {
    if is_valid(p) {
        b.slots[p.y][p.x].gem = gem
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
            b.slots[y][x].gem = gem
            rl.TraceLog(.DEBUG, "init_board: slot[%d][%d] = %s", y, x, gem_to_string(gem))
        }
    }
    return b
}

is_in_bounds :: proc(p: input.GridPosition) -> bool {
    return 0 <= p.x && p.x < GRID_WIDTH && 0 <= p.y && p.y < GRID_HEIGHT
}

grid_to_world :: proc(b: Board, p: input.GridPosition) -> rl.Vector2 {
    return rl.Vector2{ b.start_x + f32(p.x) * CELL_SIZE, b.start_y + f32(p.y) * CELL_SIZE }
}

world_to_grid :: proc(b: Board, w: rl.Vector2) -> (input.GridPosition, bool) {
    g := input.GridPosition{ int((w.x - b.start_x) / CELL_SIZE), int((w.y - b.start_y) / CELL_SIZE) }
    return g, is_in_bounds(g)
}

get_gem :: proc(b: Board, p: input.GridPosition) -> GemType {
    if !is_in_bounds(p) { return .None }
    return b.slots[p.y][p.x].gem
}

set_gem :: proc(b: ^Board, p: input.GridPosition, g: GemType) {
    if is_in_bounds(p) {
        b.slots[p.y][p.x].gem = g
    }
}

are_adjacent :: proc(a, b: input.GridPosition) -> bool {
    dx := abs(a.x - b.x)
    dy := abs(a.y - b.y)
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1)
}

get_slot :: proc(board: Board, gridPos: input.GridPosition) -> Slot {
    if is_valid(gridPos) {
        return board.slots[gridPos.y][gridPos.x]
    }
    rl.TraceLog(.ERROR, "get_slot: invalid GridPosition (%d, %d)", gridPos.x, gridPos.y)
    return Slot{ .None, false }
}

swap_slots :: proc(b: ^Board, a, b_: input.GridPosition) {
    if is_valid(a) && is_valid(b_) {
        tmp := b.slots[a.y][a.x]
        b.slots[a.y][a.x] = b.slots[b_.y][b_.x]
        b.slots[b_.y][b_.x] = tmp
    } else {
        rl.TraceLog(.ERROR, "swap_slots: invalid GridPositions (%d, %d) <-> (%d, %d)",
        a.x, a.y, b_.x, b_.y)
    }
}

mark_slot_to_move :: proc(board: ^Board, y : int, x : int) {
    board.slots[y][x].moving = true
}

draw_board :: proc(board: Board, drag: input.DragState) {
    rl.DrawRectangle(i32(board.start_x), i32(board.start_y),
    i32(GRID_WIDTH * CELL_SIZE), i32(GRID_HEIGHT * CELL_SIZE),
    rl.DARKBROWN)

    for i in 0 ..= GRID_WIDTH {
        rl.DrawLineEx(rl.Vector2{ board.start_x + f32(i) * CELL_SIZE, board.start_y },
        rl.Vector2{ board.start_x + f32(i) * CELL_SIZE, board.start_y + f32(GRID_HEIGHT) * CELL_SIZE },
        1, rl.LIGHTGRAY)
    }
    for i in 0 ..= GRID_HEIGHT {
        rl.DrawLineEx(rl.Vector2{ board.start_x, board.start_y + f32(i) * CELL_SIZE },
        rl.Vector2{ board.start_x + f32(GRID_WIDTH) * CELL_SIZE, board.start_y + f32(i) * CELL_SIZE },
        1, rl.LIGHTGRAY)
    }

    padding := CELL_SIZE * 0.1
    for y in 0 ..< GRID_HEIGHT {
        for x in 0 ..< GRID_WIDTH {
            if drag.dragging && x == drag.start_grid.x && y == drag.start_grid.y { continue }

            slot := get_slot(board, input.GridPosition{ x, y })
            if slot.gem == .None || slot.moving { continue }

            p := grid_to_world(board, input.GridPosition{ x, y })

            rl.DrawRectangle(i32(p.x + padding), i32(p.y + padding),
            i32(CELL_SIZE - padding * 2), i32(CELL_SIZE - padding * 2),
            gem_color(slot.gem))
        }
    }
}