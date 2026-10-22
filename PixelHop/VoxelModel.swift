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

    mutating func box(_ key: Character, x: ClosedRange<Int>, y: ClosedRange<Int>, z: ClosedRange<Int>) {
        for px in x { for py in y { for pz in z { self[[px, py, pz]] = key } } }
    }

    mutating func ball(center: SIMD3<Float>, radius: SIMD3<Float>, color: (SIMD3<Int>) -> Character) {
        for px in 0..<size.x {
            for py in 0..<size.y {
                for pz in 0..<size.z {
                    let p = SIMD3<Int>(px, py, pz)
                    let d = (SIMD3<Float>(p) - center) / radius
                    if (d * d).sum() <= 1 { self[p] = color(p) }
                }
            }
        }
    }

    mutating func ball(_ key: Character, center: SIMD3<Float>, radius: SIMD3<Float>) {
        ball(center: center, radius: radius) { _ in key }
    }

    func mesh(atlas: Atlas) -> MeshBuilder {
        var builder = MeshBuilder()
        let pivot = SIMD3<Float>(Float(size.x) / 2, 0, Float(size.z) / 2)
        for px in 0..<size.x {
            for py in 0..<size.y {
                for pz in 0..<size.z {
                    let p = SIMD3<Int>(px, py, pz)
                    guard let key = self[p] else { continue }
                    for face in Face.allCases where self[p &+ face.offset] == nil {
                        let uv = atlas.uv(key, face: face)
                        builder.quad(
                            face.corners.map { (SIMD3<Float>(p) + $0 - pivot) * Self.voxelSize },
                            normal: face.normal,
                            uvs: Array(repeating: uv, count: 4)
                        )
                    }
                }
            }
        }
        return builder
    }

    private func contains(_ p: SIMD3<Int>) -> Bool {
        p.x >= 0 && p.y >= 0 && p.z >= 0 && p.x < size.x && p.y < size.y && p.z < size.z
    }

    private func index(_ p: SIMD3<Int>) -> Int {
        p.x + size.x * (p.y + size.y * p.z)
    }
}
