enum Critters {
    static let butterflies = [butterfly(wing: "i", dot: "y"), butterfly(wing: "s", dot: "w"), butterfly(wing: "y", dot: "o")]

    static let gull = VoxelModel(size: [11, 3, 7]) { m in
        m.box("w", x: 4...6, y: 0...1, z: 0...4)
        m.box("w", x: 4...6, y: 1...2, z: 4...5)
        m[[5, 1, 6]] = "o"
        m[[4, 2, 5]] = "k"
        m[[6, 2, 5]] = "k"
        m.box("w", x: 0...3, y: 1...1, z: 1...3)
        m.box("w", x: 7...10, y: 1...1, z: 1...3)
        m.box("e", x: 0...1, y: 1...1, z: 1...3)
        m.box("e", x: 9...10, y: 1...1, z: 1...3)
        m.box("k", x: 0...0, y: 1...1, z: 1...2)
        m.box("k", x: 10...10, y: 1...1, z: 1...2)
        m.box("e", x: 4...6, y: 1...1, z: 0...0)
    }

    static let fish = VoxelModel(size: [3, 4, 8]) { m in
        m.ball(center: [1, 1.5, 4], radius: [1.4, 1.8, 3.0]) { p in p.y == 0 ? "y" : "o" }
        m.box("o", x: 1...1, y: 0...3, z: 0...0)
        m.box("z", x: 1...1, y: 3...3, z: 4...5)
        m[[0, 2, 6]] = "k"
        m[[2, 2, 6]] = "k"
    }

    static let puff = VoxelModel(size: [5, 5, 5]) { m in
        m.ball(center: [2, 2, 2], radius: [2.4, 2.4, 2.4]) { p in VoxelModel.noise(p) % 3 == 0 ? "w" : "x" }
    }

    static let glint = VoxelModel(size: [5, 1, 5]) { m in
        m.box("c", x: 2...2, y: 0...0, z: 0...4)
        m.box("c", x: 0...4, y: 0...0, z: 2...2)
        m[[2, 0, 2]] = "w"
    }

    private static func butterfly(wing: Character, dot: Character) -> VoxelModel {
        VoxelModel(size: [5, 1, 4]) { m in
            m.box("k", x: 2...2, y: 0...0, z: 0...3)
            m.box(wing, x: 0...1, y: 0...0, z: 2...3)
            m.box(wing, x: 3...4, y: 0...0, z: 2...3)
            m.box(wing, x: 1...1, y: 0...0, z: 0...1)
            m.box(wing, x: 3...3, y: 0...0, z: 0...1)
            m[[0, 0, 3]] = dot
            m[[4, 0, 3]] = dot
        }
    }
}
