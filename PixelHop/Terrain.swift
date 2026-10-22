enum Terrain {
    static func mesh(atlas: Atlas, chunk: SIMD2<Int>) -> MeshBuilder {
        var builder = MeshBuilder()
        WorldMap.forEachTile(in: chunk) { column, row in
            let block = Block.of(WorldMap.tile(column, row))
            let origin = SIMD3<Float>(Float(column), 0, Float(row))
            builder.quad(
                Face.top.corners.map { origin + SIMD3<Float>($0.x, block.height, $0.z) },
                normal: Face.top.normal,
                uvs: atlas.uvs(block.top, face: .top)
            )
            for face in Face.sides {
                let low = Block.of(WorldMap.tile(column + face.offset.x, row + face.offset.z)).height
                guard low < block.height else { continue }
                builder.quad(
                    face.corners.map { origin + SIMD3<Float>($0.x, $0.y == 1 ? block.height : low, $0.z) },
                    normal: face.normal,
                    uvs: atlas.uvs(block.side, face: face, height: block.height - low)
                )
            }
        }
        return builder
    }
}
