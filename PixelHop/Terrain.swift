enum Terrain {
    static func mesh(atlas: Atlas) -> MeshBuilder {
        var builder = MeshBuilder()
        for (row, tiles) in WorldMap.grid.enumerated() {
            for (column, tile) in tiles.enumerated() {
                let block = Block.of(tile)
                let origin = SIMD3<Float>(Float(column), 0, Float(row))
                builder.quad(
                    Face.top.corners.map { origin + SIMD3<Float>($0.x, block.height, $0.z) },
                    normal: Face.top.normal,
                    uvs: atlas.uvs(block.top, face: .top)
                )
                for face in Face.sides {
                    let low = WorldMap.tile(column + face.offset.x, row + face.offset.z).map { Block.of($0).height } ?? -1
                    guard low < block.height else { continue }
                    builder.quad(
                        face.corners.map { origin + SIMD3<Float>($0.x, $0.y == 1 ? block.height : low, $0.z) },
                        normal: face.normal,
                        uvs: atlas.uvs(block.side, face: face, height: block.height - low)
                    )
                }
            }
        }
        return builder
    }
}
