import RealityKit
import simd

final class Chunks {
    private(set) var coins: [SIMD2<Int>: Entity] = [:]
    private let root: Entity
    private let atlas: Atlas
    private let material: UnlitMaterial
    private let coin: ModelEntity
    private var props: [Character: ModelEntity] = [:]
    private var loaded: [SIMD2<Int>: Entity] = [:]
    private var collected = Set<SIMD2<Int>>()

    init(root: Entity, atlas: Atlas, material: UnlitMaterial) throws {
        self.root = root
        self.atlas = atlas
        self.material = material
        coin = ModelEntity(mesh: try Models.coin.mesh(atlas: atlas).resource(named: "coin"), materials: [material])
        for (key, prop) in Models.props {
            props[key] = ModelEntity(mesh: try prop.model.mesh(atlas: atlas).resource(named: "prop-\(key)"), materials: [material])
        }
    }

    func update(around position: SIMD2<Float>, budget: Int) throws {
        let keep = Self.area(around: position, margin: 1)
        for chunk in loaded.keys where !keep.contains(chunk) {
            unload(chunk)
        }
        let wanted = Self.area(around: position, margin: 0)
            .filter { loaded[$0] == nil }
            .sorted { distance($0, to: position) < distance($1, to: position) }
        for chunk in wanted.prefix(budget) {
            try load(chunk)
        }
    }

    func collect(_ tile: SIMD2<Int>) -> Entity? {
        collected.insert(tile)
        return coins.removeValue(forKey: tile)
    }

    private static func area(around position: SIMD2<Float>, margin: Int) -> Set<SIMD2<Int>> {
        let x = Int(position.x.rounded(.down))
        let z = Int(position.y.rounded(.down))
        let size = WorldMap.chunkSize
        let west = WorldGen.floorDiv(x - 28, size) - margin
        let east = WorldGen.floorDiv(x + 28, size) + margin
        let north = WorldGen.floorDiv(z - 20, size) - margin
        let south = WorldGen.floorDiv(z + 14, size) + margin
        var chunks = Set<SIMD2<Int>>()
        for cz in north...south {
            for cx in west...east { chunks.insert([cx, cz]) }
        }
        return chunks
    }

    private func distance(_ chunk: SIMD2<Int>, to position: SIMD2<Float>) -> Float {
        let center = (SIMD2<Float>(chunk) + 0.5) * Float(WorldMap.chunkSize)
        return simd_distance(center, position)
    }

    private func load(_ chunk: SIMD2<Int>) throws {
        let entity = Entity()
        entity.addChild(ModelEntity(mesh: try Terrain.mesh(atlas: atlas, chunk: chunk).resource(named: "terrain"), materials: [material]))
        for (key, center) in WorldMap.props(in: chunk) {
            guard let prototype = props[key] else { continue }
            let copy = prototype.clone(recursive: true)
            copy.position = [center.x, Block.of(key).height, center.y]
            entity.addChild(copy)
        }
        for tile in WorldMap.coins(in: chunk) where !collected.contains(tile) {
            let center = SIMD2<Float>(tile) + 0.5
            let copy = coin.clone(recursive: true)
            copy.position = [center.x, WorldMap.height(center) + 0.2, center.y]
            entity.addChild(copy)
            coins[tile] = copy
        }
        root.addChild(entity)
        loaded[chunk] = entity
    }

    private func unload(_ chunk: SIMD2<Int>) {
        loaded.removeValue(forKey: chunk)?.removeFromParent()
        coins = coins.filter { WorldMap.chunk(of: $0.key) != chunk }
    }
}
