package play

import b "../board"
import i "../input"
import rl "vendor:raylib"

GAME_TITLE :: cstring("MATCH‑3 GAME")
INSTRUCTIONS_C :: cstring("Drag gems to swap them")

GamePhase :: enum {
    Idle,
    AnimatingFall,
}

GameData :: struct {
    board      : b.Board,
    drag_state : i.DragState,
    phase      : GamePhase,
    movements  : [dynamic]GemMovement,
    timer      : f32,
}

game : GameData

on_gem_swap :: proc(a, b: i.GridPosition) {
    on_match(&game.board, []i.GridPosition{a, b})
}

Init :: proc() {
    rl.SetTraceLogLevel(.ALL)
    game = GameData{
        board      = b.init_board(),
        drag_state = init_drag_state(),
        phase      = .Idle,
        movements  = make([dynamic]GemMovement, 0),
        timer      = 0.0,
    }
}

Update :: proc() -> bool {
    if rl.IsKeyPressed(.ESCAPE) {
        return true
    }

    switch game.phase {
    case .Idle:
        update_drag(&game.board, &game.drag_state, on_gem_swap)

    case .AnimatingFall:
        update_fall_animation(&game, rl.GetFrameTime())
    }

    return false
}

Draw :: proc() {
    rl.ClearBackground(rl.DARKBLUE)
    //    c.draw_centered_text(GAME_TITLE, 30, 30, c.COLOR_TEXT)
    b.draw_board(game.board, game.drag_state)
    draw_falling_gems(game.board, game.movements[:])
    draw_drag(game.board, game.drag_state)
//    c.draw_centered_text(INSTRUCTIONS_C, c.SCREEN_HEIGHT-80, 20, c.COLOR_TEXT)
//    c.draw_centered_text(c.HELP_ESC_C,   c.SCREEN_HEIGHT-40, 20, c.COLOR_TEXT_HELP)
}

update_fall_animation :: proc(game: ^GameData, delta: f32) {
    speed := f32(400.0) // pixels por segundo
    still_moving := false

    for i in 0 ..< len(game.movements) {
        m := &game.movements[i]
        dest := b.grid_to_world(game.board, m.to)
        dir := dest - m.global_position
        dist := rl.Vector2Length(dir)

        if dist > 1.0 {
            dir = rl.Vector2Normalize(dir)
            move_step := dir * (speed * delta)
            if rl.Vector2Length(move_step) > dist {
                m.global_position = dest
            } else {
                m.global_position = m.global_position + move_step
                still_moving = true
            }
        } else {
            m.global_position = dest
        }
    }

    // Remove gems that have arrived
    new_movements: [dynamic]GemMovement
    for m in game.movements {
        if rl.Vector2Length(m.global_position - b.grid_to_world(game.board, m.to)) > 0.5 {
            _ = append(&new_movements, m)
        } else {
            // Clear the moving flag and ensure the gem is in the correct position
            game.board.slots[m.from.y][m.from.x].moving = false
            game.board.slots[m.to.y][m.to.x].gem = m.gem
            game.board.slots[m.to.y][m.to.x].moving = false
        }
    }

    game.movements = new_movements

    if len(game.movements) == 0 {
        game.phase = .Idle
    }
}

next_positions :: proc(movements: []GemMovement) -> []i.GridPosition {
    positions : [dynamic]i.GridPosition
    for m in movements {
        _ = append_elem(&positions, m.to)
    }
    return positions[:]
}


draw_falling_gems :: proc(board: b.Board, movements: []GemMovement) {
    padding := b.CELL_SIZE * 0.1
    for m in movements {
        pos := m.global_position
        rl.DrawRectangle(
        i32(pos.x + padding), i32(pos.y + padding),
        i32(b.CELL_SIZE - padding * 2), i32(b.CELL_SIZE - padding * 2),
        b.gem_color(m.gem),
        )
    }
}
