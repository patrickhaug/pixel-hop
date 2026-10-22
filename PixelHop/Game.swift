import Observation
import RealityKit
import simd
import UIKit

enum Direction {
    case up, right, down, left

    var vector: SIMD2<Float> {
        switch self {
        case .up: [0, -1]
        case .right: [1, 0]
        case .down: [0, 1]
        case .left: [-1, 0]
        }
    }

    var yaw: Float {
        switch self {
        case .down: 0
        case .right: .pi / 2
        case .up: .pi
        case .left: -.pi / 2
        }
    }
}

@Observable
final class Game {
    private(set) var coins = UserDefaults.standard.integer(forKey: "coins")
    var heading: Direction?

    private let root = Entity()
    private let hopper = Entity()
    private let body = Entity()
    private let camera = PerspectiveCamera()
    @ObservationIgnored private var clock: FrameClock?
    @ObservationIgnored private var coinEntities: [Entity] = []
    @ObservationIgnored private var flying: [Flying] = []
    @ObservationIgnored private var facing = Direction.down
    @ObservationIgnored private var time: Float = 0
    @ObservationIgnored private var hopTime: Float = 0

    private let walkSpeed: Float = 3.2
    private let cameraOffset: SIMD3<Float> = [0, 7.5, 8]

    private struct Flying {
        let entity: Entity
        var age: Float
    }

    func makeWorld() async throws -> Entity {
        let atlas = Atlas.shared
        let material = try await Scenery.pixelMaterial(atlas.image)
        root.addChild(ModelEntity(mesh: try Terrain.mesh(atlas: atlas).resource(named: "terrain"), materials: [material]))
        for (key, prop) in Models.props {
            let entity = ModelEntity(mesh: try prop.model.mesh(atlas: atlas).resource(named: "prop-\(key)"), materials: [material])
            for center in WorldMap.placements(of: key, footprint: prop.footprint) {
                let copy = entity.clone(recursive: true)
                copy.position = [center.x, Block.of(key).height, center.y]
                root.addChild(copy)
            }
        }
        let coin = ModelEntity(mesh: try Models.coin.mesh(atlas: atlas).resource(named: "coin"), materials: [material])
        for center in "Ccds".flatMap({ WorldMap.centers(of: $0) }) {
            let copy = coin.clone(recursive: true)
            copy.position = [center.x, WorldMap.height(center) + 0.2, center.y]
            root.addChild(copy)
            coinEntities.append(copy)
        }
        body.addChild(ModelEntity(mesh: try Models.hopper.mesh(atlas: atlas).resource(named: "hopper"), materials: [material]))
        hopper.addChild(try Scenery.shadow())
        hopper.addChild(body)
        let start = WorldMap.centers(of: "@").first ?? [1.5, 1.5]
        move(to: start)
        root.addChild(hopper)
        camera.camera.fieldOfViewInDegrees = 40
        camera.camera.far = 300
        camera.look(at: [0, 0.6, 0], from: cameraOffset, relativeTo: nil)
        camera.addChild(try await Scenery.backdrop())
        root.addChild(camera)
        follow()
        clock = FrameClock { [weak self] dt in self?.step(dt) }
        clock?.start()
        return root
    }

    private func step(_ dt: Float) {
        time += dt
        if let heading {
            facing = heading
            walk(heading, by: walkSpeed * dt)
            hopTime += dt
        } else {
            hopTime = 0
        }
        body.position.y = abs(sin(hopTime * 10)) * 0.25
        body.orientation = simd_slerp(body.orientation, simd_quatf(angle: facing.yaw, axis: [0, 1, 0]), min(1, dt * 14))
        follow()
        updateCoins(dt)
    }

    private func walk(_ direction: Direction, by step: Float) {
        let position = SIMD2<Float>(hopper.position.x, hopper.position.z)
        let ahead = position + direction.vector * step
        if !Self.isBlocked(ahead) {
            move(to: ahead)
            return
        }
        let lane = direction.vector.x == 0 ? position.x : position.y
        let shift = max(-step, min(step, lane.rounded(.down) + 0.5 - lane))
        let slide = direction.vector.x == 0
            ? SIMD2<Float>(position.x + shift, position.y)
            : SIMD2<Float>(position.x, position.y + shift)
        if !Self.isBlocked(slide) { move(to: slide) }
    }

    private func move(to position: SIMD2<Float>) {
        hopper.position = [position.x, WorldMap.height(position), position.y]
    }

    private static func isBlocked(_ center: SIMD2<Float>) -> Bool {
        let half: Float = 0.3
        let corners: [SIMD2<Float>] = [[-half, -half], [half, -half], [-half, half], [half, half]]
        return corners.contains { WorldMap.isBlocked(center + $0) }
    }

    private func follow() {
        camera.position = hopper.position + cameraOffset
    }

    private func updateCoins(_ dt: Float) {
        let spin = simd_quatf(angle: time * 2.5, axis: [0, 1, 0])
        let reach = SIMD2<Float>(hopper.position.x, hopper.position.z)
        var remaining: [Entity] = []
        for coin in coinEntities {
            coin.orientation = spin
            coin.position.y = WorldMap.height(SIMD2<Float>(coin.position.x, coin.position.z)) + 0.2 + sin(time * 3) * 0.06
            if simd_distance(SIMD2<Float>(coin.position.x, coin.position.z), reach) < 0.55 {
                collect(coin)
            } else {
                remaining.append(coin)
            }
        }
        coinEntities = remaining
        flying = flying.compactMap { item in
            var item = item
            item.age += dt
            item.entity.position.y += dt * 2.5
            item.entity.scale = SIMD3<Float>(repeating: max(0.01, 1 - item.age * 2.5))
            guard item.age < 0.4 else {
                item.entity.removeFromParent()
                return nil
            }
            return item
        }
    }

    private func collect(_ coin: Entity) {
        flying.append(Flying(entity: coin, age: 0))
        coins += 1
        UserDefaults.standard.set(coins, forKey: "coins")
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
