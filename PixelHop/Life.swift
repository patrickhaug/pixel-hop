import Foundation
import RealityKit
import simd

final class Life {
    private enum Motion {
        case sway, bob, butterfly, bird, glint, smoke
    }

    private struct Mover {
        let entity: Entity
        let motion: Motion
        let base: SIMD3<Float>
        let turn: simd_quatf
        let phase: Float
    }

    private struct Leap {
        let start: SIMD3<Float>
        let direction: SIMD3<Float>
        var age: Float
    }

    private struct Drop {
        let entity: Entity
        var velocity: SIMD3<Float>
        var age: Float
    }

    private let root: Entity
    private let butterflies: [ModelEntity]
    private let gull: ModelEntity
    private let glint: ModelEntity
    private let puff: ModelEntity
    private let fish: ModelEntity
    private var byChunk: [SIMD2<Int>: [Mover]] = [:]
    private var leap: Leap?
    private var nextLeap: Float = 2
    private var drops: [Drop] = []

    init(root: Entity, atlas: Atlas, material: UnlitMaterial) throws {
        self.root = root
        butterflies = try Critters.butterflies.enumerated().map { try Life.entity($1, named: "butterfly-\($0)", atlas: atlas, material: material) }
        gull = try Life.entity(Critters.gull, named: "gull", atlas: atlas, material: material)
        glint = try Life.entity(Critters.glint, named: "glint", atlas: atlas, material: material)
        puff = try Life.entity(Critters.puff, named: "puff", atlas: atlas, material: material)
        fish = try Life.entity(Critters.fish, named: "fish", atlas: atlas, material: material)
        fish.isEnabled = false
        root.addChild(fish)
    }

    func spawn(in chunk: SIMD2<Int>, under parent: Entity) {
        var movers: [Mover] = []
        WorldMap.forEachTile(in: chunk) { column, row in
            let key = WorldMap.tile(column, row)
            let roll = Hash.value(column, row, 41) % 100
            let ground = SIMD3<Float>(Float(column) + 0.5, WorldMap.height(column, row), Float(row) + 0.5)
            let phase = Float(Hash.value(column, row, 42) % 628) / 100
            if (key == "*" || key == "%") && roll < 15 {
                movers.append(add(butterflies[Int(roll) % butterflies.count], .butterfly, at: ground, phase: phase, under: parent))
            } else if key == "~" && roll < 4 {
                movers.append(add(glint, .glint, at: ground + [0, 0.02, 0], phase: phase, under: parent))
            }
        }
        if Hash.value(chunk.x, chunk.y, 43) % 10 < 4 {
            let center = (SIMD2<Float>(chunk) + 0.5) * Float(WorldMap.chunkSize)
            let sky = SIMD3<Float>(center.x, max(0, WorldMap.height(center)) + 4.5, center.y)
            let phase = Float(Hash.value(chunk.x, chunk.y, 44) % 628) / 100
            for i in 0..<2 {
                movers.append(add(gull, .bird, at: sky, phase: phase + Float(i) * 1.3, under: parent))
            }
        }
        byChunk[chunk, default: []] += movers
    }

    func adopt(_ key: Character, _ entity: Entity, in chunk: SIMD2<Int>, under parent: Entity) {
        let base = entity.position
        let phase = Float(Hash.value(Int(base.x * 10), Int(base.z * 10), 45) % 628) / 100
        switch key {
        case "T", "Y":
            byChunk[chunk, default: []].append(Mover(entity: entity, motion: .sway, base: base, turn: entity.orientation, phase: phase))
        case "o":
            byChunk[chunk, default: []].append(Mover(entity: entity, motion: .bob, base: base, turn: entity.orientation, phase: phase))
        case "H", "G":
            for i in 0..<3 {
                byChunk[chunk, default: []].append(add(puff, .smoke, at: base + Models.chimney, phase: phase + Float(i), under: parent))
            }
        default:
            break
        }
    }

    func remove(_ chunk: SIMD2<Int>) {
        byChunk[chunk] = nil
    }

    func update(time: Float, dt: Float, around hopper: SIMD3<Float>) {
        for movers in byChunk.values {
            for mover in movers where isNear(mover.base, hopper) {
                move(mover, time: time + mover.phase)
            }
        }
        updateFish(dt, around: hopper)
        updateDrops(dt)
    }

    private func add(_ prototype: ModelEntity, _ motion: Motion, at base: SIMD3<Float>, phase: Float, under parent: Entity) -> Mover {
        let copy = prototype.clone(recursive: true)
        copy.position = base
        parent.addChild(copy)
        return Mover(entity: copy, motion: motion, base: base, turn: copy.orientation, phase: phase)
    }

    private func isNear(_ point: SIMD3<Float>, _ hopper: SIMD3<Float>) -> Bool {
        abs(point.x - hopper.x) < 20 && point.z - hopper.z > -18 && point.z - hopper.z < 10
    }

    private func move(_ mover: Mover, time t: Float) {
        let entity = mover.entity
        switch mover.motion {
        case .sway:
            entity.orientation = mover.turn * simd_quatf(angle: sin(t * 1.6) * 0.04, axis: [1, 0, 0])
        case .bob:
            entity.position.y = mover.base.y + sin(t * 1.8) * 0.05
            entity.orientation = mover.turn * simd_quatf(angle: sin(t * 1.3) * 0.07, axis: [0, 0, 1])
        case .butterfly:
            entity.position = mover.base + SIMD3<Float>(sin(t * 0.9) * 0.8, 0.5 + sin(t * 2.3) * 0.15, sin(t * 1.3) * 0.6)
            entity.orientation = simd_quatf(angle: atan2(cos(t * 0.9) * 0.72, cos(t * 1.3) * 0.78), axis: [0, 1, 0])
            entity.scale = [0.25 + 0.75 * abs(sin(t * 14)), 1, 1]
        case .bird:
            let angle = t * 0.35
            entity.position = mover.base + SIMD3<Float>(cos(angle) * 5, sin(t * 0.9) * 0.3, sin(angle) * 5)
            entity.orientation = simd_quatf(angle: atan2(-sin(angle), cos(angle)), axis: [0, 1, 0])
            entity.scale = [0.55 + 0.45 * abs(cos(t * 5)), 1, 1]
        case .glint:
            let flash = max(0, sin(t * 1.7))
            let sharp = flash * flash * flash * flash
            entity.scale = SIMD3<Float>(repeating: max(0.01, sharp * sharp))
        case .smoke:
            let u = (t / 3).truncatingRemainder(dividingBy: 1)
            entity.position = mover.base + SIMD3<Float>(u * 0.3, u * 1.1, 0)
            entity.scale = SIMD3<Float>(repeating: max(0.01, sin(u * .pi) * (0.3 + u * 0.4)))
        }
    }

    private func updateFish(_ dt: Float, around hopper: SIMD3<Float>) {
        guard var current = leap else {
            nextLeap -= dt
            if nextLeap <= 0 {
                nextLeap = Float.random(in: 2...5)
                startLeap(around: hopper)
            }
            return
        }
        current.age += dt
        let u = current.age / 1.1
        let flat = current.start + current.direction * min(u, 1) * 1.4
        guard u < 1 else {
            splash(at: flat)
            fish.isEnabled = false
            leap = nil
            return
        }
        fish.position = flat + [0, sin(u * .pi) * 1.3, 0]
        fish.orientation = simd_quatf(angle: atan2(current.direction.x, current.direction.z), axis: [0, 1, 0])
            * simd_quatf(angle: -cos(u * .pi), axis: [1, 0, 0])
        leap = current
    }

    private func startLeap(around hopper: SIMD3<Float>) {
        let directions: [SIMD3<Float>] = [[1, 0, 0], [-1, 0, 0], [0, 0, 1], [0, 0, -1]]
        for _ in 0..<12 {
            let column = Int(hopper.x.rounded(.down)) + Int.random(in: -9...9)
            let row = Int(hopper.z.rounded(.down)) + Int.random(in: -8...3)
            let direction = directions[Int.random(in: 0..<directions.count)]
            guard WorldMap.tile(column, row) == "~",
                  WorldMap.tile(column + Int(direction.x), row + Int(direction.z)) == "~" else { continue }
            let start = SIMD3<Float>(Float(column) + 0.5, WorldMap.height(column, row) - 0.05, Float(row) + 0.5)
            leap = Leap(start: start, direction: direction, age: 0)
            fish.isEnabled = true
            fish.position = start
            splash(at: start)
            return
        }
    }

    private func splash(at point: SIMD3<Float>) {
        for _ in 0..<6 {
            let drop = puff.clone(recursive: true)
            drop.position = point
            drop.scale = SIMD3<Float>(repeating: 0.3)
            root.addChild(drop)
            drops.append(Drop(entity: drop, velocity: [Float.random(in: -0.8...0.8), Float.random(in: 1.5...2.6), Float.random(in: -0.8...0.8)], age: 0))
        }
    }

    private func updateDrops(_ dt: Float) {
        drops = drops.compactMap { drop in
            var drop = drop
            drop.age += dt
            drop.velocity.y -= 7 * dt
            drop.entity.position += drop.velocity * dt
            guard drop.age < 0.6 else {
                drop.entity.removeFromParent()
                return nil
            }
            return drop
        }
    }

    private static func entity(_ model: VoxelModel, named name: String, atlas: Atlas, material: UnlitMaterial) throws -> ModelEntity {
        ModelEntity(mesh: try model.mesh(atlas: atlas).resource(named: name), materials: [material])
    }
}
