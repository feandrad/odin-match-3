package gameplay

import rl "vendor:raylib"

// Drag state to track gem dragging
DragState :: struct {
    is_dragging:       bool,
    start_position:    GridPosition,
    current_position:  GridPosition,
    initial_mouse_pos: rl.Vector2,
}

// Create a new drag state
init_drag_state :: proc() -> DragState {
    return DragState{
        is_dragging = false,
    }
}

// Handle dragging interaction on the board
update_drag :: proc(
    board: ^Board, 
    drag_state: ^DragState, 
    on_swap: proc(a, b: GridPosition)
) {
    mouse_pos := rl.GetMousePosition()
    
    // Start dragging
    if !drag_state.is_dragging && rl.IsMouseButtonPressed(.LEFT) {
        if grid_pos, is_valid := world_to_grid(board^, mouse_pos); is_valid {
            drag_state.is_dragging = true
            drag_state.start_position = grid_pos
            drag_state.current_position = grid_pos
            drag_state.initial_mouse_pos = mouse_pos
        }
    }
    
    // Handle dragging
    if drag_state.is_dragging {
        if grid_pos, is_valid := world_to_grid(board^, mouse_pos); is_valid {
            // Only process when moving to a new adjacent cell
            if grid_pos.x != drag_state.current_position.x || 
               grid_pos.y != drag_state.current_position.y {
                
                if are_adjacent(drag_state.current_position, grid_pos) {
                    // Swap gems
                    swap_gems(board, drag_state.current_position, grid_pos)
                    
                    // Call the swap callback
                    if on_swap != nil {
                        on_swap(drag_state.current_position, grid_pos)
                    }
                    
                    // Update current position
                    drag_state.current_position = grid_pos
                }
            }
        }
        
        // End dragging
        if rl.IsMouseButtonReleased(.LEFT) {
            drag_state.is_dragging = false
        }
    }
}

// Draw helper for dragging visualization
draw_drag :: proc(board: Board, drag_state: DragState) {
    if drag_state.is_dragging {
        // Highlight the selected gem
        pos := grid_to_world(board, drag_state.current_position)
        rl.DrawRectangleLines(
            i32(pos.x), 
            i32(pos.y), 
            i32(CELL_SIZE), 
            i32(CELL_SIZE), 
            rl.WHITE
        )
    }
}
