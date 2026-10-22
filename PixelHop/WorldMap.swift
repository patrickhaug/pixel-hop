enum WorldMap {
    static let rows = [
        "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
        "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
        "T........*TTTT......=......~~~~~~~~~~~.T",
        "T...*....CTTTT...*..=.....~~~~~~~~~~~~~T",
        "T.....*...TTT.......=.C...~~~~~C..~~~~~T",
        "T..............*....=....######.C.~~~~~T",
        "T...................=.....~~~~~..C~~~~~T",
        "T..*................=.....~~~~~~~~~~~~~T",
        "T....C......*.......=......~~~~~~~~~~~.T",
        "T.......*......C....=........~~~~~~~...T",
        "T...................=..................T",
        "T....@..............=..................T",
        "T======================================T",
        "T...........C...........=..............T",
        "TTTTTTT.TTTTTTT.........=............R.T",
        "TTTTTTT..TTTTTT.~~~~~...=..RR..R....C..T",
        "TTTTTTTT.TTTTTT.~~~~~...=.....C...RR...T",
        "TTTTTT...TTTTTC.~~~~~...=..............T",
        "TTT.......TTTTT.~~~~~...=..R...RR......T",
        "TTT.C...C.TTTTT.........=...R....C..R..T",
        "TTT...C...TTTTT......C..=..............T",
        "TTTTTTTTTTTTTTT.........=....RC..RR....T",
        "TTTTTTTTTTTTTTT.........=..............T",
        "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
    ]

    static let grid = rows.map { Array($0) }

    static func tile(_ column: Int, _ row: Int) -> Character? {
        guard grid.indices.contains(row), grid[row].indices.contains(column) else { return nil }
        return grid[row][column]
    }

    static func isBlocked(_ point: SIMD2<Float>) -> Bool {
        guard let key = tile(Int(point.x.rounded(.down)), Int(point.y.rounded(.down))) else { return true }
        return Block.of(key).solid
    }

    static func centers(of key: Character) -> [SIMD2<Float>] {
        grid.enumerated().flatMap { row, tiles in
            tiles.enumerated().compactMap { column, tile in
                tile == key ? SIMD2<Float>(Float(column) + 0.5, Float(row) + 0.5) : nil
            }
        }
    }
}
