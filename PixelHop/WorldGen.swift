import Foundation

enum WorldGen {
    private static let cell = 6

    static func tile(_ column: Int, _ row: Int) -> Character {
        if homeDistance(Double(column), Double(row)) <= 3 { return "." }
        let e = elevation(column, row)
        let roll = Hash.value(column, row, 5) % 1000
        if e < -0.15 { return "~" }
        if e < -0.08 { return roll < 40 ? "Y" : roll >= 990 ? "s" : ":" }
        let cx = floorDiv(column, cell)
        let cz = floorDiv(row, cell)
        if isTown(cx, cz) { return townTile(column - cx * cell, row - cz * cell, cx: cx, cz: cz, roll: roll) }
        if abs(fbm(Double(column) / 30, Double(row) / 30, seed: 3)) < 0.035 { return roll >= 992 ? "c" : "=" }
        if fbm(Double(column) / 24, Double(row) / 24, seed: 4) > 0.25 {
            if roll < 380 { return "T" }
        } else {
            if roll < 25 { return "T" }
            if roll < 40 { return "R" }
            if roll < 110 { return "*" }
        }
        return roll >= 992 ? "c" : "."
    }

    static func floorDiv(_ a: Int, _ b: Int) -> Int {
        a >= 0 ? a / b : -((b - 1 - a) / b)
    }

    private static func townTile(_ x: Int, _ z: Int, cx: Int, cz: Int, roll: UInt32) -> Character {
        if x == 0 || z == 0 { return roll >= 985 ? "C" : "," }
        if let house = house(cx, cz) {
            if (1...3).contains(x) && (1...3).contains(z) { return house }
            if x == 4 && z == 1 { return "P" }
            if x == 5 && z == 3 && Hash.value(cx, cz, 9) % 2 == 1 { return "F" }
            if x == 2 && z == 5 && Hash.value(cx, cz, 10) % 3 == 0 { return "B" }
        } else {
            if (x == 2 && z == 2) || (x == 4 && z == 4) { return "T" }
            if (x == 4 && z == 2) || (x == 2 && z == 4) { return "F" }
            if x == 3 && z == 3 { return "P" }
        }
        return roll >= 990 ? "C" : ","
    }

    private static func isTown(_ cx: Int, _ cz: Int) -> Bool {
        let x = cx * cell + 3
        let z = cz * cell + 3
        return fbm(Double(x) / 70, Double(z) / 70, seed: 2) > 0.22
            && elevation(x, z) > 0.05
            && homeDistance(Double(x), Double(z)) > 10
    }

    private static func house(_ cx: Int, _ cz: Int) -> Character? {
        guard Hash.value(cx, cz, 7) % 10 < 7 else { return nil }
        for dz in 1...3 {
            for dx in 1...3 where elevation(cx * cell + dx, cz * cell + dz) < -0.08 { return nil }
        }
        return Hash.value(cx, cz, 8) % 2 == 1 ? "H" : "G"
    }

    private static func elevation(_ column: Int, _ row: Int) -> Double {
        let distance = homeDistance(Double(column), Double(row))
        return fbm(Double(column) / 38, Double(row) / 38, seed: 1) + max(0, (16 - distance) / 16) * 0.9
    }

    private static func homeDistance(_ x: Double, _ z: Double) -> Double {
        let dx = max(-x, 0, x - Double(WorldMap.homeSize.x - 1))
        let dz = max(-z, 0, z - Double(WorldMap.homeSize.y - 1))
        return (dx * dx + dz * dz).squareRoot()
    }

    private static func fbm(_ x: Double, _ z: Double, seed: Int) -> Double {
        (value(x, z, seed: seed) + 0.5 * value(x * 2, z * 2, seed: seed + 101)) / 1.5
    }

    private static func value(_ x: Double, _ z: Double, seed: Int) -> Double {
        let x0 = Int(x.rounded(.down))
        let z0 = Int(z.rounded(.down))
        let tx = smooth(x - Double(x0))
        let tz = smooth(z - Double(z0))
        let a = lattice(x0, z0, seed)
        let b = lattice(x0 + 1, z0, seed)
        let c = lattice(x0, z0 + 1, seed)
        let d = lattice(x0 + 1, z0 + 1, seed)
        let north = a + (b - a) * tx
        let south = c + (d - c) * tx
        return (north + (south - north) * tz) * 2 - 1
    }

    private static func lattice(_ x: Int, _ z: Int, _ seed: Int) -> Double {
        Double(Hash.value(x, z, seed)) / 4_294_967_296
    }

    private static func smooth(_ t: Double) -> Double {
        t * t * (3 - 2 * t)
    }
}
