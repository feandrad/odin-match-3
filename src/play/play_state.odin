package play

import play "../play"
import rl   "vendor:raylib"

GAME_TITLE :: cstring("MATCH‑3 GAME")
INSTRUCTIONS_C :: cstring("Drag gems to swap them")

GameData :: struct {
    board      : play.Board,
    drag_state : play.DragState,
}

game : GameData

on_gem_swap :: proc(a, b: play.GridPosition) {
    play.on_match(&game.board, []play.GridPosition{a, b})
}

Init :: proc() {
    rl.SetTraceLogLevel(.ALL)
    game = GameData{
        board      = play.init_board(),
        drag_state = play.init_drag_state(),
    }
}

Update :: proc() -> bool {
    if rl.IsKeyPressed(.ESCAPE) {
        return true
    }
    play.update_drag(&game.board, &game.drag_state, on_gem_swap)
    return false
}

Draw :: proc() {
    rl.ClearBackground(rl.DARKBLUE)
    //    c.draw_centered_text(GAME_TITLE, 30, 30, c.COLOR_TEXT)
    play.draw_board(game.board, game.drag_state)
    play.draw_drag(game.board, game.drag_state)
//    c.draw_centered_text(INSTRUCTIONS_C, c.SCREEN_HEIGHT-80, 20, c.COLOR_TEXT)
//    c.draw_centered_text(c.HELP_ESC_C,   c.SCREEN_HEIGHT-40, 20, c.COLOR_TEXT_HELP)
}
