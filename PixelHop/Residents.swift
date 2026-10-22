import Foundation
import RealityKit
import simd

final class Resident {
    let species: Species
    let name: String
    let entity = Entity()
    private let body: Entity
    private let home: SIMD2<Float>
    private var target: SIMD2<Float>
    private var wait: Float
    private var hopTime: Float = 0
    private var cheer: Float = 0
    private var line: Int
    private var gifted = false

    var title: String { "\(species.kind) \(name)" }
    var position: SIMD2<Float> { [entity.position.x, entity.position.z] }

    init(species: Species, model: ModelEntity, home: SIMD2<Float>, seed: Int) {
        self.species = species
        name = species.names[seed % species.names.count]
        self.home = home
        target = home
        wait = Float(seed % 30) / 10
        line = seed % species.lines.count
        body = model.clone(recursive: true)
        entity.addChild(body)
        place(at: home)
    }

    func update(_ dt: Float, hopper: SIMD2<Float>) {
        if cheer > 0 {
            cheer = max(0, cheer - dt)
            face(hopper - position, dt: dt)
            body.position.y = abs(sin(cheer * 12)) * 0.3
            return
        }
        body.position.y = 0
        if simd_distance(hopper, position) < 1.6 {
            face(hopper - position, dt: dt)
            return
        }
        if wait > 0 {
            wait -= dt
            return
        }
        let offset = target - position
        let distance = simd_length(offset)
        if distance < 0.05 {
            wait = Float.random(in: 1...3)
            target = pickTarget()
            return
        }
        let next = position + offset / distance * min(distance, species.speed * dt)
        guard !WorldMap.isBlocked(next) else {
            wait = 0.5
            target = pickTarget()
            return
        }
        place(at: next)
        hopTime += dt
        body.position.y = abs(sin(hopTime * 9)) * 0.15
        face(offset, dt: dt)
    }

    func talk() -> (text: String, gift: Bool) {
        cheer = 0.8
        if species.gives && !gifted {
            gifted = true
            return (Species.gift, true)
        }
        let text = species.lines[line]
        line = (line + 1) % species.lines.count
        return (text, false)
    }

    private func pickTarget() -> SIMD2<Float> {
        for _ in 0..<6 {
            let candidate = home + SIMD2<Float>(Float.random(in: -3...3), Float.random(in: -3...3))
            if !WorldMap.isBlocked(candidate) { return candidate }
        }
        return home
    }

    private func face(_ direction: SIMD2<Float>, dt: Float) {
        guard simd_length(direction) > 0.01 else { return }
        let goal = simd_quatf(angle: atan2(direction.x, direction.y), axis: [0, 1, 0])
        body.orientation = simd_slerp(body.orientation, goal, min(1, dt * 10))
    }

    private func place(at point: SIMD2<Float>) {
        entity.position = [point.x, WorldMap.height(point), point.y]
    }
}

final class Residents {
    private var byChunk: [SIMD2<Int>: [Resident]] = [:]
    private var models: [Character: ModelEntity] = [:]

    private static let home: [SIMD2<Int>: Character] = [
        [23, 18]: "h", [7, 9]: "k", [39, 13]: "k", [6, 18]: "c",
        [27, 20]: "c", [37, 23]: "d", [12, 24]: "f", [23, 13]: "q",
    ]

    init(atlas: Atlas, material: UnlitMaterial) throws {
        for (key, species) in Species.all {
            models[key] = ModelEntity(mesh: try species.model.mesh(atlas: atlas).resource(named: "resident-\(key)"), materials: [material])
        }
    }

    func spawn(in chunk: SIMD2<Int>, under parent: Entity) {
        var residents: [Resident] = []
        for (key, tile) in Self.spawns(in: chunk) {
            guard let species = Species.all[key], let model = models[key] else { continue }
            let resident = Resident(species: species, model: model, home: SIMD2<Float>(tile) + 0.5, seed: Int(Hash.value(tile.x, tile.y, 13)))
            parent.addChild(resident.entity)
            residents.append(resident)
        }
        byChunk[chunk] = residents
    }

    func remove(_ chunk: SIMD2<Int>) {
        byChunk[chunk] = nil
    }

    func update(_ dt: Float, hopper: SIMD2<Float>) {
        for residents in byChunk.values {
            for resident in residents { resident.update(dt, hopper: hopper) }
        }
    }

    func nearest(to point: SIMD2<Float>, within reach: Float) -> Resident? {
        byChunk.values.joined()
            .filter { simd_distance($0.position, point) < reach }
            .min { simd_distance($0.position, point) < simd_distance($1.position, point) }
    }

    private static func spawns(in chunk: SIMD2<Int>) -> [(key: Character, tile: SIMD2<Int>)] {
        var result: [(key: Character, tile: SIMD2<Int>)] = []
        WorldMap.forEachTile(in: chunk) { column, row in
            if let key = home[[column, row]] {
                result.append((key: key, tile: [column, row]))
                return
            }
            guard !WorldMap.isHome(column, row) else { return }
            let (choices, density) = Self.choices(on: WorldMap.tile(column, row))
            guard !choices.isEmpty, Hash.value(column, row, 11) % 1000 < density else { return }
            result.append((key: choices[Int(Hash.value(column, row, 12) % UInt32(choices.count))], tile: [column, row]))
        }
        return result
    }

    private static func choices(on tile: Character) -> (species: [Character], density: UInt32) {
        switch tile {
        case ",", "C": (["k", "h", "c"], 12)
        case ".", "*", "=", "c": (["f", "q", "c", "h"], 4)
        case ":", "s": (["d", "q"], 10)
        default: ([], 0)
        }
    }
}
