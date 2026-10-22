import Foundation
import RealityKit
import simd

final class QuestSite {
    struct Contact {
        var bite: SIMD2<Float>?
        var reached: Int?
        var squashed = 0
    }

    private(set) var grummels: [Grummel] = []
    private var items: [Int: Entity] = [:]
    private var taken: [Int: Entity] = [:]
    private var follower: Entity?
    private var followerHop: Float = 0
    private var dying: [(entity: Entity, age: Float)] = []
    private let anchor = Entity()
    private let spots: [SIMD2<Float>]

    init(quest: Quest, root: Entity, atlas: Atlas, material: UnlitMaterial) throws {
        spots = quest.spots.map { SIMD2<Float>($0) + 0.5 }
        let monster = ModelEntity(mesh: try Grummel.model.mesh(atlas: atlas).resource(named: "grummel"), materials: [material])
        let prize: ModelEntity?
        switch quest.kind {
        case .fetch:
            prize = ModelEntity(mesh: try quest.species.errand.model.mesh(atlas: atlas).resource(named: "loot"), materials: [material])
            prize?.scale = SIMD3<Float>(repeating: 1.6)
        case .rescue:
            prize = ModelEntity(mesh: try quest.species.model.mesh(atlas: atlas).resource(named: "baby"), materials: [material])
            prize?.scale = SIMD3<Float>(repeating: 0.55)
        case .gather:
            prize = ModelEntity(mesh: try Loot.gem.mesh(atlas: atlas).resource(named: "gem"), materials: [material])
            prize?.scale = SIMD3<Float>(repeating: 1.6)
        case .chase:
            prize = nil
        }
        let guards = quest.kind == .chase ? 5 : quest.kind == .gather ? 2 : 4
        let posts: [SIMD2<Float>] = [[2.5, 0], [-2.5, 0], [0, 2.5], [0, -2.5], [2, 2], [-2, -2], [2, -2], [-2, 2]]
        for (index, spot) in spots.enumerated() {
            if let prize {
                let copy = prize.clone(recursive: true)
                anchor.addChild(copy)
                items[index] = copy
            }
            for post in posts.map({ spot + $0 }).filter({ !WorldMap.isBlocked($0) }).prefix(guards) {
                let grummel = Grummel(model: monster, home: post)
                anchor.addChild(grummel.entity)
                grummels.append(grummel)
            }
        }
        root.addChild(anchor)
    }

    func update(_ dt: Float, time: Float, hopper: SIMD2<Float>, hunting: Bool, stomping: Bool, reaching: Bool) -> Contact {
        var contact = Contact()
        for (index, item) in items {
            let spot = spots[index]
            item.position = [spot.x, WorldMap.height(spot) + 0.5 + sin(time * 3) * 0.1, spot.y]
            item.orientation = simd_quatf(angle: time * 2, axis: [0, 1, 0])
            if reaching && simd_distance(spot, hopper) < 0.7 { contact.reached = index }
        }
        grummels = grummels.filter { grummel in
            if stomping && simd_distance(grummel.position, hopper) < 0.8 {
                dying.append((entity: grummel.entity, age: 0))
                contact.squashed += 1
                return false
            }
            grummel.update(dt, hopper: hopper, hunting: hunting)
            if simd_distance(grummel.position, hopper) < 0.65 { contact.bite = grummel.position }
            return true
        }
        dying = dying.compactMap { item in
            let age = item.age + dt
            item.entity.scale = [1 + age * 3, max(0.05, 1 - age * 4), 1 + age * 3]
            guard age < 0.25 else {
                item.entity.removeFromParent()
                return nil
            }
            return (entity: item.entity, age: age)
        }
        follow(hopper, dt: dt)
        return contact
    }

    func take(_ index: Int, follows: Bool) {
        guard let item = items.removeValue(forKey: index) else { return }
        taken[index] = item
        if follows {
            follower = item
            item.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
        } else {
            item.isEnabled = false
        }
    }

    func restore() {
        for (index, item) in taken {
            item.isEnabled = true
            items[index] = item
        }
        taken = [:]
        follower = nil
    }

    func nearest(to point: SIMD2<Float>) -> Float {
        grummels.map { simd_distance($0.position, point) }.min() ?? .infinity
    }

    func remove() {
        anchor.removeFromParent()
    }

    private func follow(_ hopper: SIMD2<Float>, dt: Float) {
        guard let follower else { return }
        let position = SIMD2<Float>(follower.position.x, follower.position.z)
        let offset = hopper - position
        let distance = simd_length(offset)
        var next = position
        if distance > 1.1 {
            next = position + offset / distance * min(distance - 1.1, 3.8 * dt)
            followerHop += dt
        }
        follower.position = [next.x, WorldMap.height(next) + abs(sin(followerHop * 10)) * 0.2, next.y]
        if distance > 0.01 {
            follower.orientation = simd_quatf(angle: atan2(offset.x, offset.y), axis: [0, 1, 0])
        }
    }
}
