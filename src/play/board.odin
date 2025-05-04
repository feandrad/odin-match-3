package gameplay

import c "../common"
import rl "vendor:raylib"

// Board dimensions
GRID_WIDTH  :: 6
GRID_HEIGHT :: 8
CELL_SIZE   :: f32(64.0)  // Cell size in pixels

// Grid position representation
GridPosition :: struct {
    x: int,
    y: int,
}

// Board state
// -1 = empty slot, >= 0 = gem type/color index
Board :: struct {
    slots:    [GRID_HEIGHT][GRID_WIDTH]int,
    start_x:  f32,  // Board position
    start_y:  f32,
}

// Initialize a new board
init_board :: proc() -> Board {
    board := Board{}
    
    // Calculate centered position for board
    board.start_x = f32(c.SCREEN_WIDTH - int(GRID_WIDTH * CELL_SIZE)) / 2
    board.start_y = f32(c.SCREEN_HEIGHT - int(GRID_HEIGHT * CELL_SIZE)) / 2
    
    // Fill board with random gems
    for y in 0..<GRID_HEIGHT {
        for x in 0..<GRID_WIDTH {
            board.slots[y][x] = int(rl.GetRandomValue(0, 5)) // 6 different gem types (0-5)
        }
    }
    
    return board
}

// Check if position is within board bounds
is_in_bounds :: proc(pos: GridPosition) -> bool {
    return 0 <= pos.x && pos.x < GRID_WIDTH && 
           0 <= pos.y && pos.y < GRID_HEIGHT
}

// Convert grid position to screen coordinates
grid_to_world :: proc(b: Board, pos: GridPosition) -> rl.Vector2 {
    return rl.Vector2{
        b.start_x + f32(pos.x) * CELL_SIZE,
        b.start_y + f32(pos.y) * CELL_SIZE,
    }
}

// Convert screen coordinates to grid position
// Returns the position and whether it's valid
world_to_grid :: proc(b: Board, world_pos: rl.Vector2) -> (GridPosition, bool) {
    gx := int((world_pos.x - b.start_x) / CELL_SIZE)
    gy := int((world_pos.y - b.start_y) / CELL_SIZE)
    pos := GridPosition{gx, gy}
    return pos, is_in_bounds(pos)
}

// Get the gem at a specific grid position
get_gem :: proc(b: Board, pos: GridPosition) -> int {
    if !is_in_bounds(pos) {
        return -1
    }
    return b.slots[pos.y][pos.x]
}

// Set a gem at a specific grid position
set_gem :: proc(b: ^Board, pos: GridPosition, gem_type: int) {
    if is_in_bounds(pos) {
        b.slots[pos.y][pos.x] = gem_type
    }
}

// Check if two positions are adjacent
are_adjacent :: proc(a, b: GridPosition) -> bool {
    dx := abs(a.x - b.x)
    dy := abs(a.y - b.y)
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1)
}

// Swap gems at two positions
swap_gems :: proc(b: ^Board, a, b_pos: GridPosition) {
    if !is_in_bounds(a) || !is_in_bounds(b_pos) {
        return
    }
    
    temp := get_gem(b^, a)
    set_gem(b, a, get_gem(b^, b_pos))
    set_gem(b, b_pos, temp)
}

// Draw the board and all gems
draw_board :: proc(b: Board) {
    // Draw board background
    rl.DrawRectangle(
        i32(b.start_x), 
        i32(b.start_y), 
        i32(GRID_WIDTH * CELL_SIZE), 
        i32(GRID_HEIGHT * CELL_SIZE), 
        rl.DARKBROWN
    )
    
    // Draw grid lines
    for i in 0..=GRID_WIDTH {
        rl.DrawLineEx(
            rl.Vector2{b.start_x + f32(i) * CELL_SIZE, b.start_y},
            rl.Vector2{b.start_x + f32(i) * CELL_SIZE, b.start_y + f32(GRID_HEIGHT) * CELL_SIZE},
            1.0,
            rl.LIGHTGRAY
        )
    }
    
    for i in 0..=GRID_HEIGHT {
        rl.DrawLineEx(
            rl.Vector2{b.start_x, b.start_y + f32(i) * CELL_SIZE},
            rl.Vector2{b.start_x + f32(GRID_WIDTH) * CELL_SIZE, b.start_y + f32(i) * CELL_SIZE},
            1.0,
            rl.LIGHTGRAY
        )
    }
    
    // Draw gems
    for y in 0..<GRID_HEIGHT {
        for x in 0..<GRID_WIDTH {
            gem_type := b.slots[y][x]
            if gem_type >= 0 {
                pos := grid_to_world(b, GridPosition{x, y})
                
                // Choose color based on gem type
                gem_color := rl.Color{}
                switch gem_type {
                    case 0: gem_color = rl.RED
                    case 1: gem_color = rl.BLUE
                    case 2: gem_color = rl.GREEN
                    case 3: gem_color = rl.YELLOW
                    case 4: gem_color = rl.PURPLE
                    case 5: gem_color = rl.ORANGE
                    case: gem_color = rl.WHITE
                }
                
                // Draw gem with slight padding
                padding := CELL_SIZE * f32(0.1);
                rl.DrawRectangle(
                    i32(pos.x + padding),
                    i32(pos.y + padding),
                    i32(CELL_SIZE - padding*2),
                    i32(CELL_SIZE - padding*2),
                    gem_color
                )
            }
        }
    }
}
