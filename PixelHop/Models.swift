import Foundation

struct Prop {
    let variants: [VoxelModel]
    var footprint: SIMD2<Int> = [1, 1]
    var natural = false
}

enum Models {
    static let props: [Character: Prop] = [
        "H": Prop(variants: [house(wall: "a", roof: "z", shade: "r"), house(wall: "w", roof: "b", shade: "n"), house(wall: "x", roof: "t", shade: "m")], footprint: [3, 3]),
        "G": Prop(variants: [house(wall: "r", roof: "o", shade: "z"), house(wall: "y", roof: "z", shade: "r"), house(wall: "i", roof: "p", shade: "m")], footprint: [3, 3]),
        "L": Prop(variants: [lighthouse], footprint: [2, 2]),
        "P": Prop(variants: [lamp]),
        "B": Prop(variants: [bench]),
        "F": Prop(variants: [bush], natural: true),
        "Y": Prop(variants: [palm], natural: true),
        "T": Prop(variants: Nature.trees, natural: true),
        "R": Prop(variants: Nature.rocks, natural: true),
        "&": Prop(variants: Nature.snowyRocks, natural: true),
        "o": Prop(variants: [boat], natural: true),
    ]

    static let chimney: SIMD3<Float> = [0.65, 3.75, -0.15]

    static let hopper = VoxelModel(size: [9, 15, 10]) { m in
        m.ball("w", center: [4, 4, 4.5], radius: [3.2, 3.3, 3.8])
        m.ball("w", center: [4, 8.5, 6], radius: [2.8, 2.6, 2.6])
        m.box("w", x: 2...3, y: 10...14, z: 5...5)
        m.box("w", x: 5...6, y: 10...14, z: 5...5)
        m.box("i", x: 3...3, y: 11...13, z: 6...6)
        m.box("i", x: 5...5, y: 11...13, z: 6...6)
        m.box("k", x: 3...3, y: 9...9, z: 8...8)
        m.box("k", x: 5...5, y: 9...9, z: 8...8)
        m.box("i", x: 4...4, y: 8...8, z: 9...9)
        m.ball("w", center: [4, 4, 0.6], radius: [1.3, 1.3, 1.3])
        m.box("w", x: 1...2, y: 0...0, z: 3...6)
        m.box("w", x: 6...7, y: 0...0, z: 3...6)
    }

    static let coin = VoxelModel(size: [7, 8, 2]) { m in
        m.ball(center: [3, 3.5, 0.5], radius: [3.4, 3.9, 1]) { p in
            let dx = (Float(p.x) - 3) / 3.4
            let dy = (Float(p.y) - 3.5) / 3.9
            if dx * dx + dy * dy > 0.55 { return "o" }
            return p.x == 2 && (2...5).contains(p.y) ? "w" : "y"
        }
    }

    static let lamp = VoxelModel(size: [10, 24, 10]) { m in
        m.box("n", x: 3...6, y: 0...1, z: 3...6)
        m.box("n", x: 4...5, y: 2...15, z: 4...5)
        m.box("n", x: 3...6, y: 16...16, z: 3...6)
        m.box("y", x: 3...6, y: 17...20, z: 3...6)
        for x in [3, 6] {
            for z in [3, 6] { m.box("n", x: x...x, y: 17...20, z: z...z) }
        }
        m.box("n", x: 2...7, y: 21...21, z: 2...7)
        m.box("n", x: 4...5, y: 22...22, z: 4...5)
    }

    static let bench = VoxelModel(size: [10, 8, 10]) { m in
        m.box("u", x: 0...9, y: 3...3, z: 3...6)
        m.box("o", x: 0...9, y: 3...3, z: 6...6)
        m.box("u", x: 0...9, y: 5...7, z: 2...2)
        m.box("h", x: 0...9, y: 6...6, z: 2...2)
        for x in [1, 8] {
            m.box("n", x: x...x, y: 0...2, z: 3...3)
            m.box("n", x: x...x, y: 0...2, z: 6...6)
            m.box("n", x: x...x, y: 3...6, z: 1...1)
        }
    }

    static let bush = VoxelModel(size: [10, 9, 10]) { m in
        m.ball(center: [4.5, 3.5, 4.5], radius: [4.4, 4.0, 4.4]) { p in
            let r = VoxelModel.noise(p) % 11
            if p.y >= 3 && r == 0 { return "r" }
            if p.y >= 3 && r == 1 { return "i" }
            if p.y >= 3 && r == 2 { return "y" }
            if p.y < 3 { return "t" }
            return r == 3 ? "l" : "g"
        }
        m.box("h", x: 2...7, y: 0...1, z: 2...7)
        m.box("o", x: 2...7, y: 0...0, z: 2...7)
    }

    static let palm = VoxelModel(size: [24, 36, 24]) { m in
        let cx = 11
        let cz = 12
        for y in 0...26 {
            let x = cx + Int((sin(Float(y) / 9) * 2).rounded())
            m.box(y % 4 == 0 ? "h" : "u", x: x...(x + 1), y: y...y, z: cz...(cz + 1))
        }
        let top = cx + Int((sin(Float(26) / 9) * 2).rounded())
        m.box("u", x: (top - 1)...(top + 2), y: 26...27, z: (cz - 1)...(cz + 2))
        for frond in 0..<7 {
            let angle = Float(frond) / 7 * 2 * .pi + 0.3
            let dx = cos(angle)
            let dz = sin(angle)
            for i in 1...10 {
                let y = Int((28 - Float(i * i) / 14).rounded())
                for w in 0...1 {
                    let px = Float(top) + 0.5 + dx * Float(i) - dz * Float(w) * 0.8
                    let pz = Float(cz) + 0.5 + dz * Float(i) + dx * Float(w) * 0.8
                    m[[Int(px), y, Int(pz)]] = (i + w) % 3 == 0 ? "l" : "g"
                }
            }
        }
        m.box("y", x: top...(top + 1), y: 25...25, z: (cz + 2)...(cz + 2))
        m.box("y", x: (top - 1)...(top - 1), y: 25...25, z: cz...cz)
    }

    static let boat = VoxelModel(size: [8, 22, 18]) { m in
        for z in 0...17 {
            let half = z < 2 ? 1 : z > 14 ? max(0, 17 - z) : 3
            guard half > 0 else {
                m.box("u", x: 3...4, y: 1...3, z: z...z)
                continue
            }
            let left = 4 - half
            let right = 3 + half
            m.box("h", x: (half > 1 ? left + 1 : left)...(half > 1 ? right - 1 : right), y: 0...0, z: z...z)
            m.box(x: left...right, y: 1...3, z: z...z) { p in
                if p.x == left || p.x == right || z == 0 || z == 17 || half < 3 { return p.y == 3 ? "w" : "u" }
                return p.y == 1 ? "f" : nil
            }
        }
        m.box("h", x: 3...4, y: 2...20, z: 8...9)
        for y in 6...19 {
            m.box(y % 4 == 0 ? "r" : "w", x: 3...3, y: y...y, z: 10...(10 + (20 - y) / 2))
        }
        m.box("r", x: 3...4, y: 21...21, z: 7...9)
        m.box("h", x: 2...5, y: 2...2, z: 4...4)
    }

    static let lighthouse = VoxelModel(size: [20, 66, 20]) { m in
        let center = SIMD2<Float>(9.5, 9.5)
        let bands: [Character] = ["w", "w", "r", "w", "w", "n"]
        m.cylinder(center: center, y: 0...3, radius: { _ in 9.3 }) { p in
            VoxelModel.noise(p) % 3 == 0 ? "d" : "e"
        }
        m.cylinder(center: center, y: 4...49, radius: { y in 6.2 - Float(y - 4) * 0.035 }) { p in
            let band = bands[(p.y - 4) / 4 % bands.count]
            return band == "w" && (p.x + p.z) % 9 == 0 ? "x" : band
        }
        m.box("y", x: 8...11, y: 10...13, z: 15...16)
        m.box("n", x: 8...11, y: 10...10, z: 15...16)
        m.box("y", x: 8...11, y: 30...33, z: 14...15)
        m.box("n", x: 8...11, y: 30...30, z: 14...15)
        m.cylinder("n", center: center, y: 50...50, radius: 7.6)
        m.cylinder(center: center, y: 51...52, radius: { _ in 7.6 }) { p in
            let d = SIMD2<Float>(Float(p.x), Float(p.z)) - center
            return (p.x + p.z) % 2 == 0 && (d * d).sum() > 6.5 * 6.5 ? "n" : nil
        }
        m.cylinder(center: center, y: 51...57, radius: { _ in 4.3 }) { p in
            (p.x + p.z) % 3 == 0 ? "n" : "y"
        }
        m.cylinder("n", center: center, y: 58...58, radius: 5.2)
        m.ball("n", center: [9.5, 59, 9.5], radius: [3.6, 3.5, 3.6])
        m.box("n", x: 9...10, y: 62...65, z: 9...10)
    }

    static func house(wall: Character, roof: Character, shade: Character) -> VoxelModel {
        VoxelModel(size: [30, 38, 30]) { m in
            let left = 2, right = 27, back = 4, front = 27, eaves = 21
            m.box(wall, x: left...right, y: 0...eaves, z: back...front)
            m.box("w", x: left...right, y: 0...0, z: back...front)
            m.box("w", x: left...right, y: 11...11, z: back...front)
            for k in 0...12 {
                let y = eaves + 1 + k
                let north = back - 1 + k
                let south = front + 1 - k
                if north + 1 <= south - 1 {
                    m.box(wall, x: left...right, y: y...y, z: (north + 1)...(south - 1))
                }
                for z in [north, south] {
                    m.box(x: (left - 1)...(right + 1), y: y...y, z: z...z) { p in
                        (p.y + p.x / 3) % 2 == 1 ? roof : shade
                    }
                }
            }
            m.box(shade, x: (left - 1)...(right + 1), y: (eaves + 12)...(eaves + 12), z: (back + 10)...(front - 10))
            m.box("r", x: 20...22, y: (eaves + 6)...(eaves + 14), z: 12...14)
            m.box("m", x: 20...22, y: (eaves + 15)...(eaves + 15), z: 12...14)
            for x in [6, 20] { frontWindow(&m, x: x, y: 3, z: front) }
            for x in [6, 13, 20] { frontWindow(&m, x: x, y: 14, z: front) }
            for (wallX, out) in [(left, left - 1), (right, right + 1)] {
                sideWindow(&m, z: 10, y: 14, x: wallX, out: out)
                sideWindow(&m, z: 18, y: 3, x: wallX, out: out)
            }
            m.box("w", x: 12...17, y: 0...9, z: front...front)
            m.box("h", x: 13...16, y: 0...8, z: front...front)
            m.box("u", x: 14...14, y: 0...8, z: front...front)
            m.box("y", x: 16...16, y: 4...4, z: (front + 1)...(front + 1))
            m.box("x", x: 11...18, y: 0...0, z: (front + 1)...(front + 2))
            m.box("g", x: 4...8, y: 1...2, z: (front + 1)...(front + 1))
            m.box("i", x: 5...5, y: 2...2, z: (front + 1)...(front + 1))
            m.box("r", x: 7...7, y: 2...2, z: (front + 1)...(front + 1))
        }
    }

    private static func frontWindow(_ m: inout VoxelModel, x: Int, y: Int, z: Int) {
        m.box("w", x: (x - 1)...(x + 4), y: (y - 1)...(y + 5), z: z...z)
        m.box("n", x: x...(x + 3), y: y...(y + 4), z: z...z)
        m.box("s", x: x...x, y: (y + 3)...(y + 4), z: z...z)
        m.box("w", x: x...(x + 3), y: (y + 2)...(y + 2), z: z...z)
        m.box("t", x: (x - 3)...(x - 2), y: y...(y + 4), z: (z + 1)...(z + 1))
        m.box("t", x: (x + 5)...(x + 6), y: y...(y + 4), z: (z + 1)...(z + 1))
        m.box("w", x: (x - 1)...(x + 4), y: (y - 1)...(y - 1), z: (z + 1)...(z + 1))
    }

    private static func sideWindow(_ m: inout VoxelModel, z: Int, y: Int, x: Int, out: Int) {
        m.box("w", x: x...x, y: (y - 1)...(y + 5), z: (z - 1)...(z + 4))
        m.box("n", x: x...x, y: y...(y + 4), z: z...(z + 3))
        m.box("w", x: x...x, y: (y + 2)...(y + 2), z: z...(z + 3))
        m.box("t", x: out...out, y: y...(y + 4), z: (z - 3)...(z - 2))
        m.box("t", x: out...out, y: y...(y + 4), z: (z + 5)...(z + 6))
    }
}
