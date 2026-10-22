enum Nature {
    static let trees = [pine, birch, oak, autumn, blossom]
    static let rocks = [rock(cap: nil), rock(cap: "g")]
    static let snowyRocks = [rock(cap: "w")]

    static let pine = VoxelModel(size: [10, 21, 10]) { m in
        m.box("h", x: 4...5, y: 0...3, z: 4...5)
        for y in 3...19 {
            let tier = (y - 3) % 5
            let radius = 5.3 - Float(y - 3) / 17 * 3.6 - Float(tier) * 0.45
            m.cylinder(center: [4.5, 4.5], y: y...y, radius: { _ in radius }) { p in
                let d = SIMD2<Float>(Float(p.x) - 4.5, Float(p.z) - 4.5)
                return tier == 0 && (d * d).sum() > (radius - 1) * (radius - 1) ? "g" : "t"
            }
        }
        m.box("t", x: 4...5, y: 20...20, z: 4...5)
    }

    static let birch = VoxelModel(size: [10, 16, 10]) { m in
        m.box(x: 4...5, y: 0...8, z: 4...5) { p in VoxelModel.noise(p) % 5 == 0 ? "k" : "w" }
        m.ball(center: [4.5, 11, 4.5], radius: [3.8, 4.4, 3.8]) { p in
            p.y < 8 || VoxelModel.noise(p) % 8 == 0 ? "g" : "l"
        }
    }

    static let oak = crowned { p in
        if p.y < 7 { return "t" }
        if (p.x * 7 + p.y * 3 + p.z * 5) % 7 == 0 { return p.y > 9 ? "l" : "t" }
        return "g"
    }

    static let autumn = crowned { p in
        let r = VoxelModel.noise(p) % 9
        if p.y < 7 { return r < 4 ? "z" : "r" }
        if r == 0 { return "y" }
        return r < 6 ? "o" : "z"
    }

    static let blossom = crowned { p in
        let r = VoxelModel.noise(p) % 10
        if p.y < 7 { return r < 3 ? "r" : "i" }
        return r < 2 ? "w" : "i"
    }

    private static func crowned(_ leaves: @escaping (SIMD3<Int>) -> Character?) -> VoxelModel {
        VoxelModel(size: [10, 15, 10]) { m in
            m.box("h", x: 4...5, y: 0...5, z: 4...5)
            m.ball(center: [4.5, 9.5, 4.5], radius: [4.6, 4.6, 4.6], color: leaves)
        }
    }

    private static func rock(cap: Character?) -> VoxelModel {
        VoxelModel(size: [10, 7, 10]) { m in
            m.ball(center: [4.5, 0.5, 4.5], radius: [4.3, cap == nil ? 4.8 : 6.0, 4.0]) { p in
                if let cap, p.y >= 4 { return VoxelModel.noise(p) % 4 == 0 && cap == "g" ? "l" : cap }
                if p.y >= 4 && (p.x + p.z) % 3 == 0 { return "w" }
                return p.y == 0 || (p.x * 5 + p.z * 3 + p.y) % 6 == 0 ? "d" : "e"
            }
        }
    }
}
