package input

import rl "vendor:raylib"

GridPosition :: struct {
    x: int,
    y: int,
}

DragState :: struct {
    dragging   : bool,
    start_grid : GridPosition,
    start_world: rl.Vector2,
    offset     : rl.Vector2,
} 