enum WorldMap {
    static let rows = [
        "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
        "~~~~~~~~~~~~~,LL,~~~~~~~~~~~~~~,LL,~~~~~~~~~~~~~",
        "~~~~~~~~~~~~~,LL,~~~~~~~~~~~~~~,LL,~~~~~~~~~~~~~",
        "~~~~~~~~~~~~~,,C,~~~~~~~~~~~~~~,,,,~~~~~~~~~~~~~",
        "~~~~~~~~~~~~~P,,P~~~~~~~~~~~~~~PC,P~~~~~~~~~~~~~",
        "~~~,,,,,,,,,,,,,,~~~~~~~~~~~~~~,,,,,,,,,,,,,,~~~",
        "~~~,HHH,GGG,HHH,,~~~~##~~~~~~~~,,GGG,HHH,GGG,~~~",
        "~~~,HHH,GGG,HHH,,~~~~#d~~~~~~~~,,GGG,HHH,GGG,~~~",
        "~~~,HHH,GGG,HHH,,~~~~##~~~##~~~,,GGG,HHH,GGG,~~~",
        "~~~,,,,,,,,,,,,,,~~~~##~~~#d~~~,,,,,,,,,,,,,,~~~",
        "~~~,FP,B,P,F,P,,,~~~~##~~~##~~~,,,P,B,P,F,P,F~~~",
        "~~~,,,,,,,C,,,,,,~~~~d#~~~##~~~,,,,,,,,,,,,,,~~~",
        "~~~,C,,,,,,,,,,,,~~~~##~~~##~~~,,,,,,C,,,,,,,~~~",
        "~~~,,,,,,,,,,,,,,,,P,,,,P,,,,P,,,,,,,,,,,,,C,~~~",
        "~~~,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,~~~",
        "~~~......=......,,,,,,,,,,,,,,,,,,GGG,,HHH,,C~~~",
        "~~~.T....=..T..R,P,,,,,,,,,,,,P,,,GGG,,HHH,,,~~~",
        "~~~...T..=.*....,,,,,,,,C,,,,,,,,,GGG,,HHH,,,~~~",
        "~~~.....c=....T.,,,,,F,,,,F,,,,,,,,,,,,,,,,,,~~~",
        "~~~..T...=......,,,C,,,,@,,,,,,,,P,C,P,,,P,,P~~~",
        "~~~......=...T..,,,,,,,,,,,,C,,,,,,,,,,,,,,,,~~~",
        "~~~=============,P,,,,B,,B,,,,P,,:::::Y:::::~~~~",
        "~~~.*....=...c..,,,,,,,,,,,,,,,,,:Y:::::::Y:~~~~",
        "~~~......=....T.,,,,,,,,C,,,,,,,,:::::s:::::~~~~",
        "~~~.T..*.=......,,HHH,,GGG,,HHH,,:::Y::::s::~~~~",
        "~~~......c..T...,,HHH,,GGG,,HHH,,::::::##:::~~~~",
        "~~~...T..=.*....,,HHH,,GGG,,HHH,,~~~~~~##~~~~~~~",
        "~~~R.c...=......,,,,,,,,,,,,,,,,,~~~~~~##~~~~~~~",
        "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#d~~~~~~~",
        "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
        "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
        "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
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

    static func height(_ point: SIMD2<Float>) -> Float {
        tile(Int(point.x.rounded(.down)), Int(point.y.rounded(.down))).map { Block.of($0).height } ?? 0
    }

    static func placements(of key: Character, footprint: SIMD2<Int>) -> [SIMD2<Float>] {
        var claimed = Set<SIMD2<Int>>()
        var centers: [SIMD2<Float>] = []
        for (row, tiles) in grid.enumerated() {
            for (column, tile) in tiles.enumerated() where tile == key && !claimed.contains([column, row]) {
                for dz in 0..<footprint.y {
                    for dx in 0..<footprint.x { claimed.insert([column + dx, row + dz]) }
                }
                centers.append(SIMD2<Float>(Float(column), Float(row)) + SIMD2<Float>(footprint) / 2)
            }
        }
        return centers
    }

    static func centers(of key: Character) -> [SIMD2<Float>] {
        grid.enumerated().flatMap { row, tiles in
            tiles.enumerated().compactMap { column, tile in
                tile == key ? SIMD2<Float>(Float(column) + 0.5, Float(row) + 0.5) : nil
            }
        }
    }
}
