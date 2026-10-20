import CoreGraphics

enum WorldMap {
    static let tileSize: CGFloat = 10

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

    static let size = CGSize(
        width: CGFloat(grid[0].count) * tileSize,
        height: CGFloat(grid.count) * tileSize
    )

    private static let grid = rows.map { Array($0) }

    static func isBlocked(_ point: CGPoint) -> Bool {
        let column = Int((point.x / tileSize).rounded(.down))
        let row = grid.count - 1 - Int((point.y / tileSize).rounded(.down))
        guard grid.indices.contains(row), grid[row].indices.contains(column) else { return true }
        return "T~R".contains(grid[row][column])
    }

    static func centers(of key: Character) -> [CGPoint] {
        grid.enumerated().flatMap { row, tiles in
            tiles.enumerated().compactMap { column, tile in
                tile == key ? CGPoint(
                    x: (CGFloat(column) + 0.5) * tileSize,
                    y: (CGFloat(grid.count - 1 - row) + 0.5) * tileSize
                ) : nil
            }
        }
    }
}
