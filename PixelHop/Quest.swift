import Foundation
import RealityKit
import simd

struct Errand {
    let item: String
    let model: VoxelModel
    let ask: String
    let waiting: String
    let thanks: String
}

struct Quest {
    let giver: SIMD2<Int>
    let title: String
    let errand: Errand
    let target: SIMD2<Int>
    var found = false

    var goal: SIMD2<Float> {
        SIMD2<Float>(found ? giver : target) + 0.5
    }

    var label: String {
        found ? "Zurück zu \(title)" : "Gesucht: \(errand.item)"
    }

    static func target(from giver: SIMD2<Int>) -> SIMD2<Int>? {
        for attempt in 0..<80 {
            let angle = Float(Hash.value(giver.x, giver.y, attempt, 50) % 628) / 100
            let distance = 22 + Float(Hash.value(giver.x, giver.y, attempt, 51) % 14)
            let target = giver &+ SIMD2<Int>(Int(cos(angle) * distance), Int(sin(angle) * distance))
            if isOpen(target) && isReachable(from: giver, to: target) { return target }
        }
        return nil
    }

    private static func isOpen(_ tile: SIMD2<Int>) -> Bool {
        guard !WorldMap.isHome(tile.x, tile.y) else { return false }
        let center = SIMD2<Float>(tile) + 0.5
        let sides: [SIMD2<Float>] = [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]]
        return sides.allSatisfy { WorldMap.canStep(from: center, to: center + $0) }
    }

    private static func isReachable(from start: SIMD2<Int>, to end: SIMD2<Int>) -> Bool {
        let a = SIMD2<Float>(start) + 0.5
        let b = SIMD2<Float>(end) + 0.5
        let steps = Int(simd_distance(a, b) * 2)
        var previous = a
        for i in 1...steps {
            let point = a + (b - a) * Float(i) / Float(steps)
            let tile = SIMD2<Int>(Int(point.x.rounded(.down)), Int(point.y.rounded(.down)))
            defer { previous = point }
            if WorldMap.isHome(tile.x, tile.y) || WorldMap.isHome(Int(previous.x.rounded(.down)), Int(previous.y.rounded(.down))) { continue }
            if WorldMap.tile(tile.x, tile.y) == "~" || WorldMap.tile(tile.x, tile.y) == "o" { return false }
            if abs(WorldMap.height(point) - WorldMap.height(previous)) > 0.8 { return false }
        }
        return true
    }
}

final class QuestSite {
    let item: Entity
    private(set) var grummels: [Grummel] = []
    private let anchor = Entity()
    private let spot: SIMD2<Float>

    init(target: SIMD2<Int>, errand: Errand, root: Entity, atlas: Atlas, material: UnlitMaterial) throws {
        spot = SIMD2<Float>(target) + 0.5
        item = ModelEntity(mesh: try errand.model.mesh(atlas: atlas).resource(named: "loot"), materials: [material])
        item.scale = SIMD3<Float>(repeating: 1.6)
        anchor.addChild(item)
        let monster = ModelEntity(mesh: try Grummel.model.mesh(atlas: atlas).resource(named: "grummel"), materials: [material])
        let posts: [SIMD2<Float>] = [[2.5, 0], [-2.5, 0], [0, 2.5], [0, -2.5], [2, 2], [-2, -2]]
        for post in posts.map({ spot + $0 }) where !WorldMap.isBlocked(post) && grummels.count < 4 {
            let grummel = Grummel(model: monster, home: post)
            anchor.addChild(grummel.entity)
            grummels.append(grummel)
        }
        root.addChild(anchor)
    }

    func update(_ dt: Float, time: Float, hopper: SIMD2<Float>, hunting: Bool) -> SIMD2<Float>? {
        item.position = [spot.x, WorldMap.height(spot) + 0.5 + sin(time * 3) * 0.1, spot.y]
        item.orientation = simd_quatf(angle: time * 2, axis: [0, 1, 0])
        var bite: SIMD2<Float>?
        for grummel in grummels {
            grummel.update(dt, hopper: hopper, hunting: hunting)
            if simd_distance(grummel.position, hopper) < 0.65 { bite = grummel.position }
        }
        return bite
    }

    func remove() {
        anchor.removeFromParent()
    }
}
