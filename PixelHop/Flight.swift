import Observation
import RealityKit
import simd

@Observable
final class Flight {
    private(set) var flying = false
    private(set) var energy: Double = 1
    @ObservationIgnored private(set) var altitude: Float = 0
    @ObservationIgnored var endless = false
    @ObservationIgnored private var charge: Float = 1
    @ObservationIgnored private var flap: Float = 0
    private let joints: [Entity]

    static let height: Float = 2.6
    static let speed: Float = 5.5

    static let wing = VoxelModel(size: [7, 2, 6]) { m in
        let rows: [ClosedRange<Int>] = [3...4, 1...5, 0...6, 0...6, 0...4, 0...2]
        for (z, row) in rows.enumerated() {
            m.box(x: row, y: 0...0, z: z...z) { p in
                if p.x == 0 { return "i" }
                return p.x >= 5 || (p.x + z) % 4 == 0 ? "x" : "w"
            }
        }
        m.box("w", x: 0...2, y: 1...1, z: 2...4)
    }

    var airborne: Bool { altitude > 0.3 }

    init(body: Entity, atlas: Atlas, material: UnlitMaterial) throws {
        let feathers = ModelEntity(mesh: try Flight.wing.mesh(atlas: atlas).resource(named: "wing"), materials: [material])
        joints = [1, -1].map { (side: Float) in
            let joint = Entity()
            joint.position = [0.2 * side, 0.55, -0.1]
            let copy = feathers.clone(recursive: true)
            copy.position = [0.35 * side, 0, 0]
            copy.scale = [side, 1, 1]
            joint.addChild(copy)
            joint.isEnabled = false
            body.addChild(joint)
            return joint
        }
    }

    func toggle() {
        if flying {
            flying = false
        } else if charge > 0.2 {
            flying = true
            Cue.takeoff.play()
        }
    }

    func update(_ dt: Float, canLand: Bool) {
        if flying {
            if !endless { charge = max(0, charge - dt / 10) }
            if charge == 0 { flying = false }
        } else if altitude == 0 {
            charge = min(1, charge + dt / 6)
        }
        let published = (Double(charge) * 20).rounded() / 20
        if published != energy { energy = published }
        let target: Float = flying ? Self.height : canLand ? 0 : 0.6
        altitude += (target - altitude) * min(1, dt * 3)
        if !flying && canLand && altitude < 0.05 && altitude > 0 {
            altitude = 0
            Cue.land.play()
        }
        let previous = flap
        flap += dt * (flying ? 11 : 6)
        if Int(previous / (2 * .pi)) != Int(flap / (2 * .pi)) && airborne { Cue.flap.play() }
        let angle = 0.25 + sin(flap) * 0.55
        for (joint, side) in zip(joints, [Float(1), -1]) {
            joint.isEnabled = altitude > 0.05
            joint.orientation = simd_quatf(angle: angle * side, axis: [0, 0, 1])
        }
    }
}
