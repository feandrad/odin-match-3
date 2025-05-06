package board

GemType :: enum int {
    None = -1,
    Red,
    Blue,
    Green,
    Yellow,
    Purple,
    Orange,
    White,
    Black,
}

gem_to_string :: proc(g: GemType) -> string {
    switch g {
    case .Red: return "Red"
    case .Green: return "Green"
    case .Blue: return "Blue"
    case .Yellow: return "Yellow"
    case .Purple: return "Purple"
    case .Orange: return "Orange"
    case .White: return "White"
    case .Black: return "Black"
    case .None: return "None"
    case: return "Unknown"
    }
}
