package play

import b "../board"
import i "../input"
import "core:slice"
import str "core:strings"
import rl "vendor:raylib"

all_equal :: proc(board: b.Board, ps: []i.GridPosition, v: b.GemType) -> bool {
    for p in ps {
        if board.slots[p.y][p.x].gem != v {
            return false
        }
    }
    return true
}

push_pos :: proc(a: ^[dynamic]i.GridPosition, p: i.GridPosition) {
    _, _ = append(a, p)
}

push_pat :: proc(a: ^[dynamic]b.Match, k: b.MatchPattern, c: []i.GridPosition) {
    _, _ = append(a, b.Match{ k, c })
}

find_matches_around :: proc(board: ^b.Board, pos: i.GridPosition) -> [dynamic]b.Match {
    if pos.x < 0 || pos.x >= b.GRID_WIDTH || pos.y < 0 || pos.y >= b.GRID_HEIGHT {
        rl.TraceLog(
        .ERROR,
        "find_matches_around: invalid pos = (%d, %d), GRID_WIDTH = %d, GRID_HEIGHT = %d",
        pos.x, pos.y, b.GRID_WIDTH, b.GRID_HEIGHT
        )
        return [dynamic]b.Match{ }
    }

    out : [dynamic]b.Match
    centre := board.slots[pos.y][pos.x].gem
    if centre == .None {
        return out
    }

    // horizontal run
    horiz : [dynamic]i.GridPosition
    push_pos(&horiz, pos)
    for x := pos.x - 1; x >= 0; x -= 1 {
        if board.slots[pos.y][x].gem == centre {
            push_pos(&horiz, i.GridPosition{ x, pos.y })
        } else {
            break
        }
    }
    for x in pos.x + 1 ..< b.GRID_WIDTH {
        if board.slots[pos.y][x].gem == centre {
            push_pos(&horiz, i.GridPosition{ x, pos.y })
        } else {
            break
        }
    }
    if len(horiz) >= 3 {
        slice.sort_by(horiz[:], proc(a, b: i.GridPosition) -> bool {
            return a.x < b.x
        })
        switch len(horiz) {
        case 3: push_pat(&out, .Horizontal3, horiz[:])
        case 4: push_pat(&out, .Horizontal4, horiz[:])
        case: push_pat(&out, .Horizontal5, horiz[:])
        }
    }

    // vertical run
    vert : [dynamic]i.GridPosition
    push_pos(&vert, pos)
    for y := pos.y - 1; y >= 0; y -= 1 {
        if board.slots[y][pos.x].gem == centre {
            push_pos(&vert, i.GridPosition{ pos.x, y })
        } else {
            break
        }
    }
    for y in pos.y + 1 ..< b.GRID_HEIGHT {
        if board.slots[y][pos.x].gem == centre {
            push_pos(&vert, i.GridPosition{ pos.x, y })
        } else {
            break
        }
    }
    if len(vert) >= 3 {
        slice.sort_by(vert[:], proc(a, b: i.GridPosition) -> bool {
            return a.y < b.y
        })
        switch len(vert) {
        case 3: push_pat(&out, .Vertical3, vert[:])
        case 4: push_pat(&out, .Vertical4, vert[:])
        case: push_pat(&out, .Vertical5, vert[:])
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

on_match :: proc(board: ^b.Board, positions: []i.GridPosition) {
    processed := map[i.GridPosition]bool{ }
    queue := make([dynamic]i.GridPosition, 0)
    matches   : [dynamic]b.Match

    rl.TraceLog(.DEBUG, "on_match: starting with %d positions", len(positions))
    for p in positions {
        if b.is_valid(p) {
            rl.TraceLog(.DEBUG, "on_match: adding valid position (%d, %d) to queue", p.x, p.y)
            _ = append(&queue, p)
        } else {
            rl.TraceLog(.ERROR, "on_match: skipping invalid position (%d, %d)", p.x, p.y)
        }
    }

    for i in 0 ..< len(queue) {
        pos := queue[i]
        if processed[pos] || !b.is_valid(pos) {
            if !b.is_valid(pos) {
                rl.TraceLog(.ERROR, "on_match: skipping invalid position in queue (%d, %d)", pos.x, pos.y)
            }
            continue
        }
        processed[pos] = true
        rl.TraceLog(.DEBUG, "on_match: processing position (%d, %d)", pos.x, pos.y)

        local := find_matches_around(board, pos)
        for m in local {
            append(&matches, m)
            for p in m.cells {
                if !processed[p] && b.is_valid(p) {
                    rl.TraceLog(.DEBUG, "on_match: adding match cell (%d, %d) to queue", p.x, p.y)
                    _ = append(&queue, p)
                } else if !b.is_valid(p) {
                    rl.TraceLog(.ERROR, "on_match: skipping invalid match cell (%d, %d)", p.x, p.y)
                }
            }
        }
    }

    rl.TraceLog(.DEBUG, "on_match: found %d matches", len(matches))
    apply_matches(board, matches[:])

    movements := handle_falls(board)

}

apply_matches :: proc(board: ^b.Board, pats: []b.Match) {
    for pat in pats {
        for p in pat.cells {
            if p.x >= 0 && p.x < b.GRID_WIDTH && p.y >= 0 && p.y < b.GRID_HEIGHT {
                current := board.slots[p.y][p.x].gem
                if current == .None {
                    continue
                }

                replace_with := b.GemType.Black

                if pat.kind == .Horizontal3 || pat.kind == .Vertical3 {
                    replace_with = b.GemType.None
                }

                board.slots[p.y][p.x].gem = replace_with

                rl.TraceLog(
                    .DEBUG,
                    "apply_matches: setting pos = (%d, %d) to %s (was %s)",
                    p.x, p.y,
                    str.clone_to_cstring(b.gem_to_string(replace_with), context.temp_allocator),
                    str.clone_to_cstring(b.gem_to_string(current), context.temp_allocator),
                )
            } else {
                rl.TraceLog(.ERROR, "apply_matches: invalid pos = (%d, %d)", p.x, p.y)
            }
        }
    }
}
