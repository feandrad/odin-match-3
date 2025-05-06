package board

import input "../input"

Match :: struct {
    kind : MatchPattern,
    cells: []input.GridPosition,
}

MatchPattern :: enum {
    Horizontal3, Horizontal4, Horizontal5,
    Vertical3, Vertical4, Vertical5,
    L3, L4, L5,
    T3, T4, T5,
    Cross3, Cross4, Cross5,
    Square2x2, Square3x3,
    Jackpot,
}
