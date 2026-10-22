enum Animals {
    static let cat = VoxelModel(size: [8, 11, 12]) { m in
        m.ball(center: [3.5, 3.5, 5.5], radius: [2.6, 2.2, 4.0]) { p in
            p.z % 3 == 0 && p.y >= 4 ? "z" : "o"
        }
        m.ball("o", center: [3.5, 6.5, 9], radius: [2.4, 2.2, 2.2])
        m.box("o", x: 1...2, y: 8...9, z: 8...9)
        m.box("o", x: 5...6, y: 8...9, z: 8...9)
        m.box("i", x: 2...2, y: 8...8, z: 9...9)
        m.box("i", x: 5...5, y: 8...8, z: 9...9)
        m.box("w", x: 2...5, y: 4...5, z: 11...11)
        m.box("k", x: 2...2, y: 7...7, z: 11...11)
        m.box("k", x: 5...5, y: 7...7, z: 11...11)
        m.box("i", x: 3...4, y: 6...6, z: 11...11)
        for x in [1, 5] {
            for z in [2, 8] {
                m.box("o", x: x...(x + 1), y: 0...2, z: z...(z + 1))
                m.box("w", x: x...(x + 1), y: 0...0, z: z...(z + 1))
            }
        }
        for i in 0..<6 {
            let z = max(0, 1 - i / 3)
            m.box(i % 2 == 1 ? "z" : "o", x: 3...4, y: (4 + i)...(4 + i), z: z...z)
        }
    }

    static let dog = VoxelModel(size: [8, 11, 13]) { m in
        m.ball("u", center: [3.5, 4, 5.5], radius: [2.7, 2.4, 4.2])
        m.ball(center: [3.5, 4, 5.5], radius: [2.0, 1.4, 3.4]) { p in p.y <= 3 ? "w" : nil }
        m.ball("u", center: [3.5, 7, 9.5], radius: [2.5, 2.3, 2.3])
        m.box("a", x: 2...5, y: 5...7, z: 11...12)
        m.box("k", x: 3...4, y: 7...7, z: 12...12)
        m.box("k", x: 2...2, y: 8...8, z: 11...11)
        m.box("k", x: 5...5, y: 8...8, z: 11...11)
        m.box("h", x: 0...1, y: 5...9, z: 8...10)
        m.box("h", x: 6...7, y: 5...9, z: 8...10)
        m.box("r", x: 3...4, y: 4...4, z: 12...12)
        for x in [1, 5] {
            for z in [2, 8] { m.box("u", x: x...(x + 1), y: 0...2, z: z...(z + 1)) }
        }
        m.box("u", x: 3...4, y: 5...8, z: 0...0)
        m.box("w", x: 3...4, y: 8...8, z: 0...0)
    }

    static let chicken = VoxelModel(size: [7, 9, 8]) { m in
        m.ball("w", center: [3, 3.5, 3.5], radius: [2.6, 2.4, 3.0])
        m.ball("w", center: [3, 6, 5], radius: [1.6, 1.8, 1.6])
        m.box("r", x: 3...3, y: 8...8, z: 4...6)
        m.box("r", x: 3...3, y: 4...5, z: 7...7)
        m.box("o", x: 2...4, y: 6...6, z: 7...7)
        m.box("k", x: 2...2, y: 7...7, z: 6...6)
        m.box("k", x: 4...4, y: 7...7, z: 6...6)
        m.box("w", x: 2...4, y: 4...6, z: 0...0)
        m.box("e", x: 1...1, y: 3...4, z: 2...5)
        m.box("e", x: 5...5, y: 3...4, z: 2...5)
        m.box("o", x: 2...2, y: 0...1, z: 3...3)
        m.box("o", x: 4...4, y: 0...1, z: 3...3)
    }

    static let duck = VoxelModel(size: [7, 9, 10]) { m in
        m.ball("y", center: [3, 2.5, 4], radius: [2.8, 2.2, 3.6])
        m.ball("y", center: [3, 6, 6.5], radius: [1.8, 1.9, 1.8])
        m.box("o", x: 2...4, y: 5...6, z: 8...9)
        m.box("k", x: 2...2, y: 7...7, z: 7...7)
        m.box("k", x: 4...4, y: 7...7, z: 7...7)
        m.box("f", x: 1...1, y: 2...3, z: 2...5)
        m.box("f", x: 5...5, y: 2...3, z: 2...5)
        m.box("y", x: 2...4, y: 3...4, z: 0...0)
        m.box("o", x: 2...2, y: 0...0, z: 4...5)
        m.box("o", x: 4...4, y: 0...0, z: 4...5)
    }

    static let fox = VoxelModel(size: [8, 11, 15]) { m in
        m.ball("o", center: [3.5, 4, 6], radius: [2.5, 2.2, 4.0])
        m.ball(center: [3.5, 3.4, 7.2], radius: [1.6, 1.4, 2.4]) { p in p.y <= 3 ? "w" : nil }
        m.ball("o", center: [3.5, 6.5, 10], radius: [2.4, 2.1, 2.2])
        m.box("w", x: 2...5, y: 5...6, z: 11...12)
        m.box("k", x: 3...4, y: 6...6, z: 13...13)
        m.box("w", x: 3...4, y: 5...5, z: 13...13)
        m.box("k", x: 2...2, y: 7...7, z: 12...12)
        m.box("k", x: 5...5, y: 7...7, z: 12...12)
        m.box("o", x: 1...2, y: 8...10, z: 9...10)
        m.box("o", x: 5...6, y: 8...10, z: 9...10)
        m.box("k", x: 1...2, y: 10...10, z: 9...10)
        m.box("k", x: 5...6, y: 10...10, z: 9...10)
        for x in [1, 5] {
            for z in [3, 8] { m.box("k", x: x...(x + 1), y: 0...2, z: z...(z + 1)) }
        }
        m.ball(center: [3.5, 4, 1.2], radius: [1.6, 1.6, 2.0]) { p in p.z == 0 ? "w" : "o" }
    }

    static let frog = VoxelModel(size: [9, 7, 9]) { m in
        m.ball(center: [4, 2.5, 4], radius: [3.6, 2.4, 3.6]) { p in
            p.y <= 1 && p.z >= 5 ? "l" : "g"
        }
        m.box("w", x: 1...3, y: 4...6, z: 5...7)
        m.box("w", x: 5...7, y: 4...6, z: 5...7)
        m.box("k", x: 2...2, y: 5...5, z: 7...7)
        m.box("k", x: 6...6, y: 5...5, z: 7...7)
        m.box("r", x: 3...5, y: 2...2, z: 8...8)
        m.box("g", x: 0...1, y: 0...1, z: 1...3)
        m.box("g", x: 7...8, y: 0...1, z: 1...3)
        m.box("g", x: 1...2, y: 0...0, z: 6...7)
        m.box("g", x: 6...7, y: 0...0, z: 6...7)
    }
}
