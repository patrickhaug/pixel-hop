import RealityKit

struct MeshBuilder {
    private var positions: [SIMD3<Float>] = []
    private var normals: [SIMD3<Float>] = []
    private var uvs: [SIMD2<Float>] = []
    private var indices: [UInt32] = []

    mutating func quad(_ corners: [SIMD3<Float>], normal: SIMD3<Float>, uvs quadUVs: [SIMD2<Float>]) {
        let start = UInt32(positions.count)
        positions += corners
        normals += Array(repeating: normal, count: corners.count)
        uvs += quadUVs
        indices += [start, start + 1, start + 2, start, start + 2, start + 3]
    }

    func resource(named name: String) throws -> MeshResource {
        var descriptor = MeshDescriptor(name: name)
        descriptor.positions = MeshBuffers.Positions(positions)
        descriptor.normals = MeshBuffers.Normals(normals)
        descriptor.textureCoordinates = MeshBuffers.TextureCoordinates(uvs)
        descriptor.primitives = .triangles(indices)
        return try MeshResource.generate(from: [descriptor])
    }
}
