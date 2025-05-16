package play

import b "../board"
import i "../input"
import rl "vendor:raylib"

GAME_TITLE :: cstring("MATCH‑3 GAME")
INSTRUCTIONS_C :: cstring("Drag gems to swap them")

GameData :: struct {
    board      : b.Board,
    drag_state : i.DragState,
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
    }
}

Update :: proc() -> bool {
    if rl.IsKeyPressed(.ESCAPE) {
        return true
    }
    update_drag(&game.board, &game.drag_state, on_gem_swap)
    return false
}

Draw :: proc() {
    rl.ClearBackground(rl.DARKBLUE)
    //    c.draw_centered_text(GAME_TITLE, 30, 30, c.COLOR_TEXT)
    b.draw_board(game.board, game.drag_state)
    draw_drag(game.board, game.drag_state)
//    c.draw_centered_text(INSTRUCTIONS_C, c.SCREEN_HEIGHT-80, 20, c.COLOR_TEXT)
//    c.draw_centered_text(c.HELP_ESC_C,   c.SCREEN_HEIGHT-40, 20, c.COLOR_TEXT_HELP)
}
