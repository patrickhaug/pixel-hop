struct VoxelModel {
    static let voxelSize: Float = 0.1

    let size: SIMD3<Int>
    private var voxels: [Character?]

    init(size: SIMD3<Int>, build: (inout VoxelModel) -> Void) {
        self.size = size
        voxels = Array(repeating: nil, count: size.x * size.y * size.z)
        build(&self)
    }

    subscript(_ p: SIMD3<Int>) -> Character? {
        get { contains(p) ? voxels[index(p)] : nil }
        set { if contains(p) { voxels[index(p)] = newValue } }
    }

    static func noise(_ p: SIMD3<Int>) -> Int {
        Int(Hash.value(p.x, p.y, p.z))
    }

    mutating func box(_ key: Character, x: ClosedRange<Int>, y: ClosedRange<Int>, z: ClosedRange<Int>) {
        box(x: x, y: y, z: z) { _ in key }
    }

    mutating func box(x: ClosedRange<Int>, y: ClosedRange<Int>, z: ClosedRange<Int>, color: (SIMD3<Int>) -> Character?) {
        for px in x {
            for py in y {
                for pz in z {
                    let p = SIMD3<Int>(px, py, pz)
                    if let key = color(p) { self[p] = key }
                }
            }
        }
    }

    mutating func ball(_ key: Character, center: SIMD3<Float>, radius: SIMD3<Float>) {
        ball(center: center, radius: radius) { _ in key }
    }

    mutating func ball(center: SIMD3<Float>, radius: SIMD3<Float>, color: (SIMD3<Int>) -> Character?) {
        for px in 0..<size.x {
            for py in 0..<size.y {
                for pz in 0..<size.z {
                    let p = SIMD3<Int>(px, py, pz)
                    let d = (SIMD3<Float>(p) - center) / radius
                    if (d * d).sum() <= 1, let key = color(p) { self[p] = key }
                }
            }
        }
    }

    mutating func cylinder(_ key: Character, center: SIMD2<Float>, y: ClosedRange<Int>, radius: Float) {
        cylinder(center: center, y: y, radius: { _ in radius }) { _ in key }
    }

    mutating func cylinder(center: SIMD2<Float>, y: ClosedRange<Int>, radius: (Int) -> Float, color: (SIMD3<Int>) -> Character?) {
        for py in y {
            let r = radius(py)
            for px in 0..<size.x {
                for pz in 0..<size.z {
                    let d = SIMD2<Float>(Float(px), Float(pz)) - center
                    let p = SIMD3<Int>(px, py, pz)
                    if (d * d).sum() <= r * r, let key = color(p) { self[p] = key }
                }
            }
        }
    }

    func mesh(atlas: Atlas) -> MeshBuilder {
        var builder = MeshBuilder()
        let pivot = SIMD3<Float>(Float(size.x) / 2, 0, Float(size.z) / 2)
        for face in Face.allCases {
            let (n, u, v) = face.axes
            for layer in 0..<size[n] {
                var mask = exposed(face, layer: layer)
                for b in 0..<size[v] {
                    var a = 0
                    while a < size[u] {
                        guard let key = mask[a + b * size[u]] else {
                            a += 1
                            continue
                        }
                        var width = 1
                        while a + width < size[u], mask[a + width + b * size[u]] == key { width += 1 }
                        var height = 1
                        while b + height < size[v], (0..<width).allSatisfy({ mask[a + $0 + (b + height) * size[u]] == key }) {
                            height += 1
                        }
                        for dv in 0..<height {
                            for du in 0..<width { mask[a + du + (b + dv) * size[u]] = nil }
                        }
                        let corners = face.corners.map { corner in
                            var p = SIMD3<Float>.zero
                            p[n] = Float(layer) + corner[n]
                            p[u] = Float(a) + corner[u] * Float(width)
                            p[v] = Float(b) + corner[v] * Float(height)
                            return (p - pivot) * Self.voxelSize
                        }
                        builder.quad(corners, normal: face.normal, uvs: Array(repeating: atlas.uv(key, face: face), count: 4))
                        a += width
                    }
                }
            }
        }
        return builder
    }

    private func exposed(_ face: Face, layer: Int) -> [Character?] {
        let (n, u, v) = face.axes
        var mask = [Character?](repeating: nil, count: size[u] * size[v])
        for b in 0..<size[v] {
            for a in 0..<size[u] {
                var p = SIMD3<Int>.zero
                p[n] = layer
                p[u] = a
                p[v] = b
                if let key = self[p], self[p &+ face.offset] == nil { mask[a + b * size[u]] = key }
            }
        }
        return mask
    }

    private func contains(_ p: SIMD3<Int>) -> Bool {
        p.x >= 0 && p.y >= 0 && p.z >= 0 && p.x < size.x && p.y < size.y && p.z < size.z
    }

    private func index(_ p: SIMD3<Int>) -> Int {
        p.x + size.x * (p.y + size.y * p.z)
    }
}
