package gameplay

import c "../common"
import rl "vendor:raylib"

GAME_TITLE :: cstring("MATCH‑3 GAME")
INSTRUCTIONS_C :: cstring("Drag gems to swap them")

GameData :: struct {
    board: Board,
    drag_state: DragState,
    level: int,
}

game: GameData

on_gem_swap :: proc(a, b: GridPosition) {
}

Init :: proc() {
    game = GameData{
        board      = init_board(),
        drag_state = init_drag_state(),
        level      = 1,
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
    c.draw_centered_text(GAME_TITLE, 30, 30, c.COLOR_TEXT)
    draw_board(game.board)
    draw_drag(game.board, game.drag_state)
    c.draw_centered_text(INSTRUCTIONS_C, c.SCREEN_HEIGHT - 80, 20, c.COLOR_TEXT)
    c.draw_centered_text(c.HELP_ESC_C, c.SCREEN_HEIGHT - 40, 20, c.COLOR_TEXT_HELP)
}
