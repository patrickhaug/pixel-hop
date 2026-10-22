import Observation
import RealityKit
import simd

@Observable
final class Adventure {
    private(set) var hearts = 3
    private(set) var label: String?
    private(set) var arrow: Double = 0
    private(set) var flash: Double = 0
    @ObservationIgnored private(set) var safe: Float = 0
    @ObservationIgnored private(set) var danger = Float.infinity
    @ObservationIgnored var practice = false
    @ObservationIgnored private var quest: Quest?
    @ObservationIgnored private var site: QuestSite?
    @ObservationIgnored private var finished = Set<SIMD2<Int>>()
    private let root: Entity
    private let atlas: Atlas
    private let material: UnlitMaterial

    static let maxHearts = 3

    enum Event {
        case bitten(SIMD2<Float>)
        case found(String)
        case fainted
    }

    var target: SIMD2<Int>? { quest?.target }

    init(root: Entity, atlas: Atlas, material: UnlitMaterial) {
        self.root = root
        self.atlas = atlas
        self.material = material
    }

    func talk(to resident: Resident) -> (text: String, reward: Int, cue: Cue)? {
        if let current = quest, current.giver == resident.tile {
            resident.hop()
            guard current.found else { return (current.errand.waiting, 0, Cue.talk) }
            finish()
            return (current.errand.thanks, 5, Cue.reward)
        }
        let errand = resident.species.errand
        guard quest == nil, resident.offersErrand, !finished.contains(resident.tile),
              let target = Quest.target(from: resident.tile),
              let site = try? QuestSite(target: target, errand: errand, root: root, atlas: atlas, material: material) else { return nil }
        resident.hop()
        let started = Quest(giver: resident.tile, title: resident.title, errand: errand, target: target)
        quest = started
        self.site = site
        label = started.label
        return (errand.ask, 0, Cue.quest)
    }

    func update(_ dt: Float, time: Float, hopper: SIMD2<Float>) -> Event? {
        safe = max(0, safe - dt)
        if flash > 0 { flash = max(0, flash - Double(dt) * 2.5) }
        guard var current = quest, let site else {
            danger = .infinity
            return nil
        }
        danger = safe > 0 ? .infinity : site.nearest(to: hopper)
        let way = current.goal - hopper
        let angle = (Double(atan2(way.x, -way.y)) * 180 / .pi / 10).rounded() * 10
        if angle != arrow { arrow = angle }
        if !current.found && simd_distance(hopper, SIMD2<Float>(current.target) + 0.5) < 0.7 {
            current.found = true
            quest = current
            site.item.isEnabled = false
            label = current.label
            return .found(current.errand.item)
        }
        guard let bite = site.update(dt, time: time, hopper: hopper, hunting: safe == 0), safe == 0 else { return nil }
        hearts = max(practice ? 1 : 0, hearts - 1)
        safe = 1.6
        flash = 1
        guard hearts == 0 else { return .bitten(bite) }
        hearts = Self.maxHearts
        current.found = false
        quest = current
        site.item.isEnabled = true
        label = current.label
        return .fainted
    }

    private func finish() {
        if let quest { finished.insert(quest.giver) }
        site?.remove()
        site = nil
        quest = nil
        label = nil
    }
}
