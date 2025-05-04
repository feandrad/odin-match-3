package common

import rl "vendor:raylib"

// Screen dimensions
SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600

// Window title
TITLE_C :: cstring("Game Menu in Odin + Raylib")

// Theme colors
COLOR_BG :: rl.DARKGRAY
COLOR_BUTTON :: rl.DARKGRAY
COLOR_BUTTON_HOVER :: rl.GRAY
COLOR_BUTTON_SELECTED :: rl.DARKBLUE
COLOR_BUTTON_SELECTED_HOVER :: rl.BLUE
COLOR_TEXT :: rl.RAYWHITE
COLOR_TEXT_SELECTED :: rl.YELLOW
COLOR_TEXT_HELP :: rl.LIGHTGRAY

// Text constants
HELP_MENU_NAV_C :: cstring("Use UP/DOWN arrows to navigate, ENTER to select")
HELP_ESC_C :: cstring("Press ESC to return to main menu")

// Game states enum - shared between packages
GameState :: enum {
    MainMenu,
    Game,
    Options,
}

// Utility to draw centered text
draw_centered_text :: proc(text: cstring, y: i32, size: i32, color: rl.Color) {
    text_width := rl.MeasureText(text, size)
    rl.DrawText(text, SCREEN_WIDTH/2 - text_width/2, y, size, color)
}
