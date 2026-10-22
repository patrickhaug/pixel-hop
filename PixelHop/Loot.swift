enum Loot {
    static let wool = VoxelModel(size: [6, 6, 6]) { m in
        m.ball(center: [2.5, 2.5, 2.5], radius: [2.6, 2.6, 2.6]) { p in (p.x + p.y) % 3 == 0 ? "r" : "i" }
        m.box("i", x: 5...5, y: 0...0, z: 1...3)
    }

    static let bone = VoxelModel(size: [9, 3, 3]) { m in
        m.box("w", x: 2...6, y: 1...1, z: 1...1)
        m.box("x", x: 2...6, y: 0...0, z: 1...1)
        for x in [0, 7] { m.box("w", x: x...(x + 1), y: 0...2, z: 0...2) }
    }

    static let egg = VoxelModel(size: [5, 7, 5]) { m in
        m.ball(center: [2, 3, 2], radius: [2.3, 3.3, 2.3]) { p in
            if p.x == 1 && p.y >= 3 { return "w" }
            return p.y < 2 ? "o" : "y"
        }
    }

    static let duck = VoxelModel(size: [5, 6, 7]) { m in
        m.ball("y", center: [2, 1.5, 3], radius: [2.2, 1.6, 2.8])
        m.ball("y", center: [2, 4, 4.5], radius: [1.4, 1.5, 1.4])
        m.box("o", x: 1...3, y: 3...4, z: 6...6)
        m[[1, 5, 5]] = "k"
        m[[3, 5, 5]] = "k"
    }

    static let chart = VoxelModel(size: [8, 2, 6]) { m in
        m.box("a", x: 0...7, y: 0...0, z: 0...5)
        m.box("f", x: 0...0, y: 0...1, z: 0...5)
        m.box("f", x: 7...7, y: 0...1, z: 0...5)
        m.box("u", x: 1...3, y: 1...1, z: 1...1)
        m.box("u", x: 3...3, y: 1...1, z: 1...3)
        m.box("u", x: 3...5, y: 1...1, z: 3...3)
        let cross: [SIMD3<Int>] = [[5, 1, 4], [6, 1, 5], [6, 1, 3], [4, 1, 5]]
        for p in cross { m[p] = "r" }
    }

    static let crown = VoxelModel(size: [7, 6, 7]) { m in
        m.box(x: 0...6, y: 0...4, z: 0...6) { p in
            guard p.x == 0 || p.x == 6 || p.z == 0 || p.z == 6 else { return nil }
            return p.y < 3 || (p.x + p.z) % 3 == 0 ? "y" : nil
        }
        m[[3, 1, 6]] = "r"
        m[[6, 1, 3]] = "r"
        m[[3, 1, 0]] = "s"
        m[[0, 1, 3]] = "s"
    }
}
