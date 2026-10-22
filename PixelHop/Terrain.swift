enum Terrain {
    static func mesh(atlas: Atlas, chunk: SIMD2<Int>) -> MeshBuilder {
        var builder = MeshBuilder()
        WorldMap.forEachTile(in: chunk) { column, row in
            let block = Block.of(WorldMap.tile(column, row))
            let height = WorldMap.height(column, row)
            let origin = SIMD3<Float>(Float(column), 0, Float(row))
            builder.quad(
                Face.top.corners.map { origin + SIMD3<Float>($0.x, height, $0.z) },
                normal: Face.top.normal,
                uvs: atlas.uvs(Textures.pick(block.top, column, row), face: .top)
            )
            for face in Face.sides {
                let low = WorldMap.height(column + face.offset.x, row + face.offset.z)
                var top = height
                var texture = block.side
                while top > low + 0.001 {
                    let bottom = max(low, top - 1)
                    builder.quad(
                        face.corners.map { origin + SIMD3<Float>($0.x, $0.y == 1 ? top : bottom, $0.z) },
                        normal: face.normal,
                        uvs: atlas.uvs(texture, face: face, height: top - bottom)
                    )
                    top = bottom
                    texture = block.wall
                }
            }
        }
        return builder
    }
}
