package gameplay

import c "../common"
import rl "vendor:raylib"

// Game data structure
GameData :: struct {
    score: int,
    level: int,
    player_x: f32,
    player_y: f32,
    player_speed: f32,
}

// Internal state
game: GameData

// Initialize gameplay - call once when entering game state
Init :: proc() {
    game = GameData{
        score = 0,
        level = 1,
        player_x = c.SCREEN_WIDTH / 2,
        player_y = c.SCREEN_HEIGHT / 2,
        player_speed = 5.0,
    }
}

// Update game state - call every frame
// Returns true if the player wants to return to main menu
Update :: proc() -> bool {
    // Check for ESC key to return to main menu
    if rl.IsKeyPressed(.ESCAPE) {
        return true // Return to main menu
    }
    
    // Player movement
    if rl.IsKeyDown(rl.KeyboardKey.RIGHT) do game.player_x += game.player_speed
    if rl.IsKeyDown(rl.KeyboardKey.LEFT) do game.player_x -= game.player_speed
    if rl.IsKeyDown(rl.KeyboardKey.DOWN) do game.player_y += game.player_speed
    if rl.IsKeyDown(rl.KeyboardKey.UP) do game.player_y -= game.player_speed
    
    // Keep player within bounds
    game.player_x = rl.Clamp(game.player_x, 25, c.SCREEN_WIDTH - 25)
    game.player_y = rl.Clamp(game.player_y, 25, c.SCREEN_HEIGHT - 25)
    
    // Score increases over time
    if rl.GetFrameTime() % 60 == 0 {
        game.score += 1
    }
    
    return false // Continue game
}

// Draw game - call every frame
Draw :: proc() {
    // Draw game background
    rl.DrawRectangle(50, 50, c.SCREEN_WIDTH-100, c.SCREEN_HEIGHT-100, rl.DARKBLUE)
    
    // Draw player
    rl.DrawCircle(i32(game.player_x), i32(game.player_y), 20, rl.RED)
    
    // Draw game info
    game_title := "GAME SCREEN"
    c.draw_centered_text(cstring(game_title), 30, 30, c.COLOR_TEXT)
    
    // Draw score
    score_text := string(rl.TextFormat("Score: %d - Level: %d", game.score, game.level))
    rl.DrawText(cstring(score_text), 60, 80, 20, rl.GOLD)
    
    // Draw instructions
    instructions := "Use arrow keys to move"
    c.draw_centered_text(cstring(instructions), c.SCREEN_HEIGHT - 80, 20, c.COLOR_TEXT)
    
    // Draw help text for returning to menu
    c.draw_centered_text(c.HELP_ESC_C, c.SCREEN_HEIGHT - 40, 20, c.COLOR_TEXT_HELP)
}
