package play

import "core:slice"
import rl "vendor:raylib"

all_equal :: proc(b: Board, ps: []GridPosition, v: GemType) -> bool {
    for p in ps {
        if b.slots[p.y][p.x] != v { return false }
    }
    return true
}

push_pos :: proc(a: ^[dynamic]GridPosition, p: GridPosition) {
    _, _ = append(a, p)
}

push_pat :: proc(a: ^[dynamic]Match, k: MatchPattern, c: []GridPosition) {
    _, _ = append(a, Match{k, c})
}

find_matches_around :: proc(b: ^Board, pos: GridPosition) -> [dynamic]Match {
    if pos.x < 0 || pos.x >= GRID_WIDTH || pos.y < 0 || pos.y >= GRID_HEIGHT {
        rl.TraceLog(
            .ERROR,
            "find_matches_around: invalid pos = (%d, %d), GRID_WIDTH = %d, GRID_HEIGHT = %d",
            pos.x, pos.y, GRID_WIDTH, GRID_HEIGHT
        )
        return [dynamic]Match{}
    }

    out : [dynamic]Match
    centre := b.slots[pos.y][pos.x]
    if centre == .None { return out }

    // horizontal run
    horiz : [dynamic]GridPosition
    push_pos(&horiz, pos)
    for x := pos.x-1; x >= 0; x -= 1 {
        if b.slots[pos.y][x] == centre {
            push_pos(&horiz, GridPosition{x, pos.y})
        } else { break }
    }
    for x in pos.x+1..<GRID_WIDTH {
        if b.slots[pos.y][x] == centre {
            push_pos(&horiz, GridPosition{x, pos.y})
        } else { break }
    }
    if len(horiz) >= 3 {
        slice.sort_by(horiz[:], proc(a, b: GridPosition) -> bool { return a.x < b.x })
        switch len(horiz) {
        case 3: push_pat(&out, .Horizontal3, horiz[:])
        case 4: push_pat(&out, .Horizontal4, horiz[:])
        case:   push_pat(&out, .Horizontal5, horiz[:])
        }
    }

    // vertical run
    vert : [dynamic]GridPosition
    push_pos(&vert, pos)
    for y := pos.y-1; y >= 0; y -= 1 {
        if b.slots[y][pos.x] == centre {
            push_pos(&vert, GridPosition{pos.x, y})
        } else { break }
    }
    for y in pos.y+1..<GRID_HEIGHT {
        if b.slots[y][pos.x] == centre {
            push_pos(&vert, GridPosition{pos.x, y})
        } else { break }
    }
    if len(vert) >= 3 {
        slice.sort_by(vert[:], proc(a, b: GridPosition) -> bool { return a.y < b.y })
        switch len(vert) {
        case 3: push_pat(&out, .Vertical3, vert[:])
        case 4: push_pat(&out, .Vertical4, vert[:])
        case:   push_pat(&out, .Vertical5, vert[:])
        }
    }

//    // 2×2 squares
//    for dy in -1..=0 {
//        for dx in -1..=0 {
//            sx := pos.x + dx
//            sy := pos.y + dy
//            if sx >= 0 && sy >= 0 && sx+1 < GRID_WIDTH && sy+1 < GRID_HEIGHT {
//                sq := [4]GridPosition{
//                    {sx, sy}, {sx+1, sy},
//                    {sx, sy+1}, {sx+1, sy+1},
//                }
//                if all_equal(b^, sq[:], centre) {
//                    push_pat(&out, .Square2x2, sq[:])
//                }
//            }
//        }
//    }
//
//    // 3×3 squares
//    for dy in -2..=0 {
//        for dx in -2..=0 {
//            sx := pos.x + dx
//            sy := pos.y + dy
//            if sx >= 0 && sy >= 0 && sx+2 < GRID_WIDTH && sy+2 < GRID_HEIGHT {
//                sq : [dynamic]GridPosition
//                valid_square := true
//                for oy in 0..<3 {
//                    for ox in 0..<3 {
//                        p := GridPosition{sx+ox, sy+oy}
//                        if !is_valid(p) {
//                            valid_square = false
//                            break
//                        }
//                        push_pos(&sq, p)
//                    }
//                    if !valid_square { break }
//                }
//                if valid_square && all_equal(b^, sq[:], centre) {
//                    push_pat(&out, .Square3x3, sq[:])
//                }
//            }
//        }
//    }

    return out
}

on_match :: proc(b: ^Board, positions: []GridPosition) {
    processed := map[GridPosition]bool{}
    queue     := make([dynamic]GridPosition, 0)
    matches   : [dynamic]Match

    rl.TraceLog(.DEBUG, "on_match: starting with %d positions", len(positions))
    for p in positions {
        if is_valid(p) {
            rl.TraceLog(.DEBUG, "on_match: adding valid position (%d, %d) to queue", p.x, p.y)
            _ = append(&queue, p)
        } else {
            rl.TraceLog(.ERROR, "on_match: skipping invalid position (%d, %d)", p.x, p.y)
        }
    }

    for i in 0..<len(queue) {
        pos := queue[i]
        if processed[pos] || !is_valid(pos) { 
            if !is_valid(pos) {
                rl.TraceLog(.ERROR, "on_match: skipping invalid position in queue (%d, %d)", pos.x, pos.y)
            }
            continue 
        }
        processed[pos] = true
        rl.TraceLog(.DEBUG, "on_match: processing position (%d, %d)", pos.x, pos.y)

        local := find_matches_around(b, pos)
        for m in local {
            append(&matches, m)
            for p in m.cells {
                if !processed[p] && is_valid(p) {
                    rl.TraceLog(.DEBUG, "on_match: adding match cell (%d, %d) to queue", p.x, p.y)
                    _ = append(&queue, p)
                } else if !is_valid(p) {
                    rl.TraceLog(.ERROR, "on_match: skipping invalid match cell (%d, %d)", p.x, p.y)
                }
            }
        }
    }

    rl.TraceLog(.DEBUG, "on_match: found %d matches", len(matches))
    apply_matches(b, matches[:])
}

apply_matches :: proc(b: ^Board, pats: []Match) {
    for pat in pats {
        for p in pat.cells {
            if p.x >= 0 && p.x < GRID_WIDTH && p.y >= 0 && p.y < GRID_HEIGHT {
                if b.slots[p.y][p.x] != .Black {
                    rl.TraceLog(.DEBUG, "apply_matches: setting pos = (%d, %d) to Black", p.x, p.y)
                    set_slot(b, p, .Black)
                }
            } else {
                rl.TraceLog(.ERROR, "apply_matches: invalid pos = (%d, %d)", p.x, p.y)
            }
        }
    }
}
