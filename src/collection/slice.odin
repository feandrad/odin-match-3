package collections

append_all :: proc($T: typeid, dst: ^[dynamic]T, src: [dynamic]T) {
    for x in src {
        _, _ = append(dst, x)
    }
}
