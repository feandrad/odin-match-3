package main

import gp "play"
import rl "vendor:raylib"

// Game states
GameState :: enum {
    MainMenu,
    Game,
    Options,
}

// Menu options
MenuOption :: enum {
    None = -1,
    StartGame,
    Options,
    Exit,
}

// Screen dimensions
SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600

// Theme colors
COLOR_BG :: rl.DARKGRAY
COLOR_BUTTON :: rl.DARKGRAY
COLOR_BUTTON_HOVER :: rl.GRAY
COLOR_BUTTON_SELECTED :: rl.DARKBLUE
COLOR_BUTTON_SELECTED_HOVER :: rl.BLUE
COLOR_TEXT :: rl.RAYWHITE
COLOR_TEXT_SELECTED :: rl.YELLOW
COLOR_TEXT_HELP :: rl.LIGHTGRAY

// Pre-converted cstring constants for static texts
TITLE_C :: cstring("Game Menu in Odin + Raylib")
MAIN_MENU_C :: cstring("MAIN MENU")
GAME_SCREEN_C :: cstring("GAME SCREEN")
OPTIONS_SCREEN_C :: cstring("OPTIONS SCREEN")
HELP_NAV_C :: cstring("Use UP/DOWN arrows to navigate, ENTER to select")
HELP_ESC_C :: cstring("Press ESC to return to main menu")

// Menu item structure with cstring
MenuItem :: struct {
    text: cstring,
    rect: rl.Rectangle,
    is_hovered: bool,
}

// Global menu items with pre-converted cstrings
MAIN_MENU_ITEMS := [3]MenuItem{
    {text = cstring("Start Game")},
    {text = cstring("Options")},
    {text = cstring("Exit")},
}

// State callbacks structure for cleaner state management
StateCallbacks :: struct {
    update: proc() -> MenuOption,
    draw: proc(),
}

// State management table
STATE_TABLE := [GameState]StateCallbacks{
    GameState.MainMenu = {update = update_main_menu, draw = draw_main_menu},
    GameState.Game     = {update = update_game,     draw = draw_game},
    GameState.Options  = {update = update_options,  draw = draw_options},
}

// Track the currently selected menu item
selected_item: MenuOption = .StartGame

// Helper function to draw centered text
draw_centered_text :: proc(text: cstring, y: i32, size: i32, color: rl.Color) {
    text_width := rl.MeasureText(text, size)
    rl.DrawText(text, SCREEN_WIDTH/2 - text_width/2, y, size, color)
}

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, TITLE_C)
    defer rl.CloseWindow()
    
    rl.SetExitKey(rl.KeyboardKey(0))
    rl.SetTargetFPS(60)
    
    current_state := GameState.MainMenu
    
    for !rl.WindowShouldClose() {
        // Update current state
        if current_state == .MainMenu {
            result := STATE_TABLE[current_state].update()
            if result != .None {
                #partial switch result {
                    case .StartGame: 
                        current_state = .Game
                        gp.Init() // Initialize gameplay when entering game state
                    case .Options: current_state = .Options
                    case .Exit: return // Exit game
                }
            }
        } else {
            // For other states, call their update function and check the result
            result := STATE_TABLE[current_state].update()
            
            // For Game and Options states, None means return to menu
            if result == .None && (current_state == .Game || current_state == .Options) {
                current_state = .MainMenu
            }
        }
        
        // Render current state
        rl.BeginDrawing()
        defer rl.EndDrawing()
        
        rl.ClearBackground(COLOR_BG)
        STATE_TABLE[current_state].draw()
    }
}

update_main_menu :: proc() -> MenuOption {
    // Menu item dimensions
    item_height :: 40
    item_width :: 200
    start_y :: 180
    
    // Update menu item rectangles
    for i in 0..<len(MAIN_MENU_ITEMS) {
        MAIN_MENU_ITEMS[i].rect = {
            x = SCREEN_WIDTH/2 - item_width/2,
            y = f32(start_y + i * item_height),
            width = item_width,
            height = item_height,
        }
    }
    
    // Keyboard navigation
    if rl.IsKeyPressed(rl.KeyboardKey.DOWN) {
        selected_item = MenuOption((int(selected_item) + 1) % len(MAIN_MENU_ITEMS))
    }
    if rl.IsKeyPressed(rl.KeyboardKey.UP) {
        selected_item = MenuOption((int(selected_item) - 1 + len(MAIN_MENU_ITEMS)) % len(MAIN_MENU_ITEMS))
    }
    
    // Mouse navigation
    mouse_pos := rl.GetMousePosition()
    for i in 0..<len(MAIN_MENU_ITEMS) {
        MAIN_MENU_ITEMS[i].is_hovered = rl.CheckCollisionPointRec(mouse_pos, MAIN_MENU_ITEMS[i].rect)
        if MAIN_MENU_ITEMS[i].is_hovered {
            selected_item = MenuOption(i)
            if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
                return MenuOption(i)
            }
        }
    }
    
    // Selection with Enter key
    if rl.IsKeyPressed(rl.KeyboardKey.ENTER) {
        return selected_item
    }
    
    return .None // No selection
}

draw_main_menu :: proc() {
    // Draw title
    draw_centered_text(MAIN_MENU_C, 100, 40, COLOR_TEXT)
    
    // Draw menu items
    for i in 0..<len(MAIN_MENU_ITEMS) {
        item := MAIN_MENU_ITEMS[i]
        is_selected := MenuOption(i) == selected_item
        
        // Draw button background
        button_color := is_selected ? COLOR_BUTTON_SELECTED : COLOR_BUTTON
        if item.is_hovered {
            button_color = is_selected ? COLOR_BUTTON_SELECTED_HOVER : COLOR_BUTTON_HOVER
        }
        
        rl.DrawRectangleRec(item.rect, button_color)
        rl.DrawRectangleLinesEx(item.rect, 1, COLOR_TEXT_HELP)
        
        // Draw button text
        text_color := is_selected ? COLOR_TEXT_SELECTED : COLOR_TEXT
        text_width := rl.MeasureText(item.text, 20)
        text_x := item.rect.x + item.rect.width/2 - f32(text_width)/2
        text_y := item.rect.y + item.rect.height/2 - 10
        
        rl.DrawText(item.text, i32(text_x), i32(text_y), 20, text_color)
    }
    
    // Draw footer help text
    draw_centered_text(HELP_NAV_C, SCREEN_HEIGHT - 40, 15, COLOR_TEXT_HELP)
}

update_game :: proc() -> MenuOption {
    // Call gameplay update function, which returns true if ESC was pressed
    if gp.Update() {
        return .None // Return to main menu
    }
    return .StartGame // Continue game
}

draw_game :: proc() {
    // Call gameplay draw function to render the board
    gp.Draw()
}

update_options :: proc() -> MenuOption {
    // Options update logic would go here
    return .None
}

draw_options :: proc() {
    // Options drawing logic
    draw_centered_text(OPTIONS_SCREEN_C, SCREEN_HEIGHT/2 - 20, 40, COLOR_TEXT)
    draw_centered_text(HELP_ESC_C, SCREEN_HEIGHT - 40, 20, COLOR_TEXT_HELP)
}
