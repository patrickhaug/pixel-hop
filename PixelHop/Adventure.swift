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
    @ObservationIgnored private var rounds: [SIMD2<Int>: Int] = [:]
    private let root: Entity
    private let atlas: Atlas
    private let material: UnlitMaterial

    static let maxHearts = 3

    enum Event {
        case bitten(SIMD2<Float>)
        case found(String?)
        case squashed(String?)
        case fainted
    }

    var target: SIMD2<Int>? { quest?.spots.first }

    init(root: Entity, atlas: Atlas, material: UnlitMaterial) {
        self.root = root
        self.atlas = atlas
        self.material = material
    }

    func talk(to resident: Resident) -> (text: String, reward: Int, cue: Cue)? {
        if let current = quest, current.giver == resident.tile {
            resident.hop()
            guard current.complete else { return (current.waiting, 0, Cue.talk) }
            finish()
            return (current.thanks, 5, Cue.reward)
        }
        let round = rounds[resident.tile, default: 0]
        guard quest == nil, resident.offersErrand, round < Quest.Kind.allCases.count,
              let started = Quest.make(Quest.Kind.allCases[round], for: resident, round: round),
              let site = try? QuestSite(quest: started, root: root, atlas: atlas, material: material) else { return nil }
        resident.hop()
        quest = started
        self.site = site
        label = started.label
        return (started.ask, 0, Cue.quest)
    }

    func update(_ dt: Float, time: Float, hopper: SIMD2<Float>, altitude: Float) -> Event? {
        safe = max(0, safe - dt)
        if flash > 0 { flash = max(0, flash - Double(dt) * 2.5) }
        guard var current = quest, let site else {
            danger = .infinity
            return nil
        }
        let grounded = altitude < 0.3
        danger = safe > 0 || !grounded ? .infinity : site.nearest(to: hopper)
        let way = current.goal(from: hopper) - hopper
        let angle = (Double(atan2(way.x, -way.y)) * 180 / .pi / 10).rounded() * 10
        if angle != arrow { arrow = angle }
        let contact = site.update(
            dt,
            time: time,
            hopper: hopper,
            hunting: safe == 0 && grounded,
            stomping: altitude > 0.25 && altitude < 1.4,
            reaching: altitude < 1.4
        )
        if let index = contact.reached, current.kind != .chase {
            current.taken.insert(index)
            site.take(index, follows: current.kind == .rescue)
            quest = current
            label = current.label
            return .found(current.news(taking: index))
        }
        if contact.squashed > 0 {
            current.squashed += contact.squashed
            quest = current
            label = current.label
            return .squashed(current.cheer)
        }
        guard let bite = contact.bite, safe == 0, grounded else { return nil }
        hearts = max(practice ? 1 : 0, hearts - 1)
        safe = 1.6
        flash = 1
        guard hearts == 0 else { return .bitten(bite) }
        hearts = Self.maxHearts
        current.taken = []
        quest = current
        site.restore()
        label = current.label
        return .fainted
    }

    private func finish() {
        if let quest { rounds[quest.giver, default: 0] += 1 }
        site?.remove()
        site = nil
        quest = nil
        label = nil
    }
}
