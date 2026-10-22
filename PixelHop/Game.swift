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
    private(set) var nearby: String?
    private(set) var dialog: Dialog?
    private(set) var adventure: Adventure?
    private(set) var flight: Flight?
    var heading: Direction?

    private let root = Entity()
    private let hopper = Entity()
    private let body = Entity()
    private let shadow = Entity()
    private let camera = PerspectiveCamera()
    @ObservationIgnored private var clock: FrameClock?
    @ObservationIgnored private var chunks: Chunks?
    @ObservationIgnored private var flying: [Flying] = []
    @ObservationIgnored private var facing = Direction.down
    @ObservationIgnored private var time: Float = 0
    @ObservationIgnored private var hopTime: Float = 0
    @ObservationIgnored private var partner: Resident?
    @ObservationIgnored private var dialogAge: Float = 0
    @ObservationIgnored private var knock = SIMD2<Float>.zero
    @ObservationIgnored private var lastHop = 0
    @ObservationIgnored private var lastGround: Float = 0
    @ObservationIgnored private var pulse: Float = 0

    private let walkSpeed: Float = 3.2
    private let cameraOffset: SIMD3<Float> = [0, 10, 10.5]

    struct Dialog: Equatable {
        let title: String
        let text: String
    }

    private struct Flying {
        let entity: Entity
        var age: Float
    }

    func makeWorld() async throws -> Entity {
        let atlas = Atlas.shared
        let material = try await Scenery.pixelMaterial(atlas.image)
        let chunks = try Chunks(root: root, atlas: atlas, material: material)
        try chunks.update(around: Self.start, budget: .max)
        self.chunks = chunks
        adventure = Adventure(root: root, atlas: atlas, material: material)
        adventure?.practice = Self.screenshotQuest
        body.addChild(ModelEntity(mesh: try Models.hopper.mesh(atlas: atlas).resource(named: "hopper"), materials: [material]))
        flight = try Flight(body: body, atlas: atlas, material: material)
        flight?.endless = Self.screenshotFly
        shadow.addChild(try Scenery.shadow())
        hopper.addChild(shadow)
        hopper.addChild(body)
        move(to: Self.start)
        hopper.position.y = WorldMap.height(Self.start)
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

    private static let screenshotTalk = UserDefaults.standard.bool(forKey: "screenshotTalk")
    private static let screenshotQuest = UserDefaults.standard.bool(forKey: "screenshotQuest")
    private static let screenshotFly = UserDefaults.standard.bool(forKey: "screenshotFly")

    private static var start: SIMD2<Float> {
        let parts = UserDefaults.standard.string(forKey: "screenshotStart")?.split(separator: ",").compactMap { Float($0) } ?? []
        return parts.count == 2 ? SIMD2<Float>(parts[0], parts[1]) : WorldMap.start
    }

    private func step(_ dt: Float) {
        time += dt
        let airborne = flight?.airborne ?? false
        if let heading {
            facing = heading
            walk(heading, by: (flight?.flying == true ? Flight.speed : walkSpeed) * dt, free: airborne)
            hopTime += dt
        } else {
            hopTime = 0
        }
        body.position.y = airborne ? sin(time * 3) * 0.08 : abs(sin(hopTime * 10)) * 0.25
        let hop = Int(hopTime * 10 / .pi)
        if hop != lastHop {
            lastHop = hop
            if hop > 0 && !airborne { Cue.step(WorldMap.tile(at: hopperPosition)).play() }
        }
        let ground = WorldMap.height(hopperPosition)
        if abs(ground - lastGround) > 0.4 && !airborne { Cue.climb.play() }
        lastGround = ground
        flight?.update(dt, canLand: !Self.isBlocked(hopperPosition, from: hopperPosition))
        let altitude = flight?.altitude ?? 0
        body.orientation = simd_slerp(body.orientation, simd_quatf(angle: facing.yaw, axis: [0, 1, 0]), min(1, dt * 14))
        hopper.position.y += (ground + altitude - hopper.position.y) * min(1, dt * 14)
        shadow.position.y = ground - hopper.position.y + 0.01
        shadow.scale = SIMD3<Float>(repeating: max(0.45, 1 - altitude * 0.2))
        follow()
        try? chunks?.update(around: hopperPosition, budget: 2)
        chunks?.life.update(time: time, dt: dt, around: hopper.position)
        updateCoins(dt)
        updateResidents(dt)
        updateAdventure(dt)
        if Self.screenshotTalk, time > 17, dialog == nil {
            talk()
        }
        if Self.screenshotFly, time > 1, flight?.flying == false {
            fly()
        }
        if Self.screenshotQuest, time > 1, adventure?.target == nil {
            talk()
            if let target = adventure?.target { travel(to: SIMD2<Float>(target) + [0.5, 4]) }
        }
    }

    func talk() {
        guard let resident = chunks?.residents.nearest(to: hopperPosition, within: 1.6) else { return }
        let answer: (text: String, reward: Int, cue: Cue)
        if let errand = adventure?.talk(to: resident) {
            answer = errand
        } else {
            let (line, gift) = resident.talk()
            answer = (line, gift ? 1 : 0, gift ? Cue.gift : Cue.talk)
        }
        if answer.reward > 0 {
            coins += answer.reward
            UserDefaults.standard.set(coins, forKey: "coins")
        }
        answer.cue.play()
        partner = resident
        dialogAge = 0
        dialog = Dialog(title: resident.title, text: answer.text)
    }

    func fly() {
        flight?.toggle()
    }

    func closeDialog() {
        partner = nil
        dialog = nil
    }

    private var hopperPosition: SIMD2<Float> {
        SIMD2<Float>(hopper.position.x, hopper.position.z)
    }

    private func updateResidents(_ dt: Float) {
        guard let residents = chunks?.residents else { return }
        residents.update(dt, hopper: hopperPosition)
        let title = residents.nearest(to: hopperPosition, within: 1.6)?.title
        if title != nearby { nearby = title }
        guard dialog != nil else { return }
        dialogAge += dt
        if dialogAge > 6 || simd_distance(partner?.position ?? hopperPosition, hopperPosition) > 2.5 {
            closeDialog()
        }
    }

    private func updateAdventure(_ dt: Float) {
        guard let adventure else { return }
        switch adventure.update(dt, time: time, hopper: hopperPosition, altitude: flight?.altitude ?? 0) {
        case .bitten(let grummel)?:
            let away = hopperPosition - grummel
            knock = simd_length(away) > 0.01 ? simd_normalize(away) * 7 : [0, 7]
            Cue.hurt.play()
        case .found(let news)?:
            if let news { announce("Gefunden!", news) }
            Cue.found.play()
        case .squashed(let news)?:
            if let news { announce("Pflatsch!", news) }
            Cue.squash.play()
        case .fainted?:
            travel(to: WorldMap.start)
            announce("Autsch!", "Die Grummel haben dich erwischt. Du ruhst dich zu Hause aus. Was du gefunden hast, liegt wieder bei ihnen.")
            Cue.faint.play()
        case nil:
            break
        }
        pulse -= dt
        if adventure.danger < 3, pulse <= 0 {
            Cue.danger.play()
            pulse = 0.25 + adventure.danger * 0.15
        }
        body.isEnabled = adventure.safe == 0 || Int(adventure.safe * 10) % 2 == 0
        if simd_length(knock) > 0.05 {
            let next = hopperPosition + knock * dt
            if !Self.isBlocked(next, from: hopperPosition) { move(to: next) }
            knock *= max(0, 1 - dt * 9)
        }
    }

    private func announce(_ title: String, _ text: String) {
        partner = nil
        dialogAge = 0
        dialog = Dialog(title: title, text: text)
    }

    private func travel(to point: SIMD2<Float>) {
        knock = .zero
        move(to: point)
        hopper.position.y = WorldMap.height(point)
        follow()
        try? chunks?.update(around: point, budget: 8)
    }

    private func walk(_ direction: Direction, by step: Float, free: Bool) {
        let position = SIMD2<Float>(hopper.position.x, hopper.position.z)
        let ahead = position + direction.vector * step
        if free || !Self.isBlocked(ahead, from: position) {
            move(to: ahead)
            return
        }
        let lane = direction.vector.x == 0 ? position.x : position.y
        let shift = max(-step, min(step, lane.rounded(.down) + 0.5 - lane))
        let slide = direction.vector.x == 0
            ? SIMD2<Float>(position.x + shift, position.y)
            : SIMD2<Float>(position.x, position.y + shift)
        if !Self.isBlocked(slide, from: position) { move(to: slide) }
    }

    private func move(to position: SIMD2<Float>) {
        hopper.position.x = position.x
        hopper.position.z = position.y
    }

    private static func isBlocked(_ center: SIMD2<Float>, from start: SIMD2<Float>) -> Bool {
        let half: Float = 0.3
        let corners: [SIMD2<Float>] = [[-half, -half], [half, -half], [-half, half], [half, half]]
        return corners.contains { !WorldMap.canStep(from: start, to: center + $0) }
    }

    private func follow() {
        camera.position = hopper.position + cameraOffset
    }

    private func updateCoins(_ dt: Float) {
        let spin = simd_quatf(angle: time * 2.5, axis: [0, 1, 0])
        let reach = SIMD2<Float>(hopper.position.x, hopper.position.z)
        for (tile, coin) in chunks?.coins ?? [:] {
            coin.orientation = spin
            coin.position.y = WorldMap.height(SIMD2<Float>(tile) + 0.5) + 0.2 + sin(time * 3) * 0.06
            if simd_distance(SIMD2<Float>(tile) + 0.5, reach) < 0.55, let collected = chunks?.collect(tile) {
                collect(collected)
            }
        }
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
        Cue.coin.play()
    }
}
