enum Models {
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

    static let tree = VoxelModel(size: [10, 15, 10]) { m in
        m.box("h", x: 4...5, y: 0...5, z: 4...5)
        m.ball(center: [4.5, 9.5, 4.5], radius: [4.6, 4.6, 4.6]) { p in
            if p.y < 7 { return "t" }
            if (p.x * 7 + p.y * 3 + p.z * 5) % 7 == 0 { return p.y > 9 ? "l" : "t" }
            return "g"
        }
    }

    static let rock = VoxelModel(size: [10, 6, 10]) { m in
        m.ball(center: [4.5, 0.5, 4.5], radius: [4.3, 4.8, 4.0]) { p in
            if p.y >= 4 && (p.x + p.z) % 3 == 0 { return "w" }
            return p.y == 0 || (p.x * 5 + p.z * 3 + p.y) % 6 == 0 ? "d" : "e"
        }
    }

    static let coin = VoxelModel(size: [7, 8, 2]) { m in
        m.ball(center: [3, 3.5, 0.5], radius: [3.4, 3.9, 1]) { p in
            let dx = (Float(p.x) - 3) / 3.4
            let dy = (Float(p.y) - 3.5) / 3.9
            if dx * dx + dy * dy > 0.55 { return "o" }
            return p.x == 2 && (2...5).contains(p.y) ? "w" : "y"
        }
    }

    static let props: [Character: VoxelModel] = ["T": tree, "R": rock]
}
