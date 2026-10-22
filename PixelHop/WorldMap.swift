enum WorldMap {
    static let chunkSize = 16

    static let home = [
        "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
        "~~~~~~~~~~~~~,LL,~~~~~~~~~~~~~~,LL,~~~~~~~~~~~~~",
        "~~~~~~~~~~~~~,LL,~~~~~~~~~~~~~~,LL,~~~~~~~~~~~~~",
        "~~~~~~~~~~~~~,,C,~~~~~~~~~~~~~~,,,,~~~~~~~~~~~~~",
        "~~~~~~~~~~~~~P,,P~~~~~~~~~~~~~~PC,P~~~~~~~~~~~~~",
        "~~~,,,,,,,,,,,,,,~~~~~~~~~~~~~~,,,,,,,,,,,,,,~~~",
        "~~~,HHH,GGG,HHH,,~~~~##~~~~~~~~,,GGG,HHH,GGG,~~~",
        "~~~,HHH,GGG,HHH,,~o~~#d~~~~~~~~,,GGG,HHH,GGG,~~~",
        "~~~,HHH,GGG,HHH,,~~~~##~~~##~~~,,GGG,HHH,GGG,~~~",
        "~~~,,,,,,,,,,,,,,~~~~##~~~#d~~~,,,,,,,,,,,,,,~~~",
        "~~~,FP,B,P,F,P,,,~~~~##~o~##~~~,,,P,B,P,F,P,F~~~",
        "~~~,,,,,,,C,,,,,,~~~~d#~~~##~~~,,,,,,,,,,,,,,~~~",
        "~~~,C,,,,,,,,,,,,~~~~##~~~##~~~,,,,,,C,,,,,,,~~~",
        "~~~,,,,,,,,,,,,,,,,P,,,,P,,,,P,,,,,,,,,,,,,C,###",
        "~~~,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,~~~",
        "~~~......=......,,,,,,,,,,,,,,,,,,GGG,,HHH,,C~~~",
        "~~~.T....=..T..R,P,,,,,,,,,,,,P,,,GGG,,HHH,,,~~~",
        "~~~...T..=.*....,,,,,,,,C,,,,,,,,,GGG,,HHH,,,~~~",
        "~~~.....c=....T.,,,,,F,,,,F,,,,,,,,,,,,,,,,,,~~~",
        "~~~..T...=......,,,C,,,,@,,,,,,,,P,C,P,,,P,,P~~~",
        "~~~......=...T..,,,,,,,,,,,,C,,,,,,,,,,,,,,,,~~~",
        "###=============,P,,,,B,,B,,,,P,,:::::Y:::::~~~~",
        "~~~.*....=...c..,,,,,,,,,,,,,,,,,:Y:::::::Y:~~~~",
        "~~~......=....T.,,,,,,,,C,,,,,,,,:::::s:::::~~~~",
        "~~~.T..*.=......,,HHH,,GGG,,HHH,,:::Y::::s::~~~~",
        "~~~......c..T...,,HHH,,GGG,,HHH,,::::::##:::~~~~",
        "~~~...T..=.*....,,HHH,,GGG,,HHH,,~~~~~~##~~~~~~~",
        "~~~R.c...=......,,,,,,,,,,,,,,,,,~~~~~~##~~~~~~~",
        "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#d~~~~~~~",
        "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~o~~~##~~~~~~~",
        "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##~~~~~~~",
        "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##~~~~~~~",
    ]

    private static let homeGrid = home.map { Array($0) }
    static let homeSize = SIMD2<Int>(homeGrid[0].count, homeGrid.count)
    static let step: Float = 0.5
    private static let climb: Float = 0.8
    private static var cache: [SIMD2<Int>: Patch] = [:]

    private struct Patch {
        var tiles: [Character] = []
        var levels: [Int] = []
    }

    static let start: SIMD2<Float> = {
        for (row, tiles) in homeGrid.enumerated() {
            if let column = tiles.firstIndex(of: "@") {
                return SIMD2<Float>(Float(column) + 0.5, Float(row) + 0.5)
            }
        }
        return SIMD2<Float>(Float(homeSize.x) / 2, Float(homeSize.y) / 2)
    }()

    static func tile(_ column: Int, _ row: Int) -> Character {
        if isHome(column, row) { return homeGrid[row][column] }
        let (patch, index) = lookup(column, row)
        return patch.tiles[index]
    }

    static func level(_ column: Int, _ row: Int) -> Int {
        if isHome(column, row) { return 0 }
        let (patch, index) = lookup(column, row)
        return patch.levels[index]
    }

    static func tile(at point: SIMD2<Float>) -> Character {
        tile(Int(point.x.rounded(.down)), Int(point.y.rounded(.down)))
    }

    static func isBlocked(_ point: SIMD2<Float>) -> Bool {
        Block.of(tile(at: point)).solid
    }

    static func canStep(from start: SIMD2<Float>, to point: SIMD2<Float>) -> Bool {
        !isBlocked(point) && abs(height(point) - height(start)) <= climb
    }

    static func height(_ column: Int, _ row: Int) -> Float {
        Block.of(tile(column, row)).height + Float(level(column, row)) * step
    }

    static func height(_ point: SIMD2<Float>) -> Float {
        height(Int(point.x.rounded(.down)), Int(point.y.rounded(.down)))
    }

    static func chunk(of tile: SIMD2<Int>) -> SIMD2<Int> {
        [WorldGen.floorDiv(tile.x, chunkSize), WorldGen.floorDiv(tile.y, chunkSize)]
    }

    static func props(in chunk: SIMD2<Int>) -> [(key: Character, tile: SIMD2<Int>, center: SIMD2<Float>)] {
        var result: [(key: Character, tile: SIMD2<Int>, center: SIMD2<Float>)] = []
        forEachTile(in: chunk) { column, row in
            let key = tile(column, row)
            guard let prop = Models.props[key], isAnchor(column, row, key: key, footprint: prop.footprint) else { return }
            result.append((key: key, tile: [column, row], center: SIMD2<Float>(Float(column), Float(row)) + SIMD2<Float>(prop.footprint) / 2))
        }
        return result
    }

    static func coins(in chunk: SIMD2<Int>) -> [SIMD2<Int>] {
        var result: [SIMD2<Int>] = []
        forEachTile(in: chunk) { column, row in
            if "Ccds".contains(tile(column, row)) { result.append([column, row]) }
        }
        return result
    }

    static func forEachTile(in chunk: SIMD2<Int>, _ body: (Int, Int) -> Void) {
        for row in (chunk.y * chunkSize)..<((chunk.y + 1) * chunkSize) {
            for column in (chunk.x * chunkSize)..<((chunk.x + 1) * chunkSize) {
                body(column, row)
            }
        }
    }

    static func isHome(_ column: Int, _ row: Int) -> Bool {
        column >= 0 && row >= 0 && column < homeSize.x && row < homeSize.y
    }

    private static func isAnchor(_ column: Int, _ row: Int, key: Character, footprint: SIMD2<Int>) -> Bool {
        if footprint == [1, 1] { return true }
        if isHome(column, row) { return homeAnchors.contains([column, row]) }
        return tile(column - 1, row) != key && tile(column, row - 1) != key
    }

    private static let homeAnchors: Set<SIMD2<Int>> = {
        var claimed = Set<SIMD2<Int>>()
        var anchors = Set<SIMD2<Int>>()
        for (row, tiles) in homeGrid.enumerated() {
            for (column, key) in tiles.enumerated() where !claimed.contains([column, row]) {
                guard let footprint = Models.props[key]?.footprint, footprint != [1, 1] else { continue }
                anchors.insert([column, row])
                for dz in 0..<footprint.y {
                    for dx in 0..<footprint.x { claimed.insert([column + dx, row + dz]) }
                }
            }
        }
        return anchors
    }()

    private static func lookup(_ column: Int, _ row: Int) -> (Patch, Int) {
        let owner = chunk(of: [column, row])
        return (patch(of: owner), (row - owner.y * chunkSize) * chunkSize + column - owner.x * chunkSize)
    }

    private static func patch(of chunk: SIMD2<Int>) -> Patch {
        if let patch = cache[chunk] { return patch }
        if cache.count > 4096 { cache.removeAll() }
        var patch = Patch()
        patch.tiles.reserveCapacity(chunkSize * chunkSize)
        patch.levels.reserveCapacity(chunkSize * chunkSize)
        forEachTile(in: chunk) { column, row in
            patch.tiles.append(WorldGen.tile(column, row))
            patch.levels.append(WorldGen.level(column, row))
        }
        cache[chunk] = patch
        return patch
    }
}
