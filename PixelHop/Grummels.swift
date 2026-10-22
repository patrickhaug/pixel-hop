import Foundation
import RealityKit
import simd

final class Grummel {
    static let model = VoxelModel(size: [10, 12, 10]) { m in
        m.ball(center: [4.5, 4, 4.5], radius: [4.4, 4.0, 4.4]) { p in VoxelModel.noise(p) % 7 == 0 ? "r" : "p" }
        let spikes: [SIMD2<Int>] = [[2, 3], [4, 2], [6, 3], [3, 5], [6, 6], [4, 7]]
        for spike in spikes {
            m.box("k", x: spike.x...spike.x, y: 8...9, z: spike.y...spike.y)
            m[[spike.x, 10, spike.y]] = "w"
        }
        m.box("w", x: 2...3, y: 5...6, z: 8...8)
        m.box("w", x: 6...7, y: 5...6, z: 8...8)
        m[[3, 5, 9]] = "k"
        m[[6, 5, 9]] = "k"
        m.box("k", x: 1...2, y: 7...7, z: 8...8)
        m.box("k", x: 7...8, y: 7...7, z: 8...8)
        m[[2, 7, 9]] = "k"
        m[[7, 7, 9]] = "k"
        m.box("k", x: 2...7, y: 2...3, z: 9...9)
        m[[3, 3, 9]] = "w"
        m[[6, 3, 9]] = "w"
        m.box("p", x: 1...2, y: 0...1, z: 3...6)
        m.box("p", x: 7...8, y: 0...1, z: 3...6)
    }

    let entity = Entity()
    private let body: Entity
    private let home: SIMD2<Float>
    private var hopTime: Float = 0

    var position: SIMD2<Float> { [entity.position.x, entity.position.z] }

    init(model: ModelEntity, home: SIMD2<Float>) {
        self.home = home
        body = model.clone(recursive: true)
        entity.addChild(body)
        place(at: home)
    }

    func update(_ dt: Float, hopper: SIMD2<Float>, hunting: Bool) {
        let chase = hunting && simd_distance(hopper, position) < 6 && simd_distance(hopper, home) < 10
        let offset = (chase ? hopper : home) - position
        let distance = simd_length(offset)
        hopTime += dt
        guard distance > 0.05 else {
            body.position.y = abs(sin(hopTime * 3)) * 0.1
            return
        }
        let next = position + offset / distance * min(distance, (chase ? 2.1 : 1.2) * dt)
        if WorldMap.canStep(from: position, to: next) { place(at: next) }
        body.position.y = abs(sin(hopTime * (chase ? 11 : 7))) * 0.3
        let goal = simd_quatf(angle: atan2(offset.x, offset.y), axis: [0, 1, 0])
        body.orientation = simd_slerp(body.orientation, goal, min(1, dt * 10))
    }

    private func place(at point: SIMD2<Float>) {
        entity.position = [point.x, WorldMap.height(point), point.y]
    }
}
