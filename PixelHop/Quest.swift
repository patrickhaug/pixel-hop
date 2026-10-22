import Foundation
import simd

struct Errand {
    let item: String
    let model: VoxelModel
    let ask: String
    let waiting: String
    let thanks: String
}

struct Quest {
    enum Kind: CaseIterable {
        case fetch, rescue, gather, chase
    }

    static let gems = 3
    static let pests = 3

    let kind: Kind
    let giver: SIMD2<Int>
    let title: String
    let species: Species
    let spots: [SIMD2<Int>]
    var taken = Set<Int>()
    var squashed = 0

    var complete: Bool {
        kind == .chase ? squashed >= Self.pests : taken.count == spots.count
    }

    func goal(from hopper: SIMD2<Float>) -> SIMD2<Float> {
        let home = SIMD2<Float>(giver) + 0.5
        guard !complete else { return home }
        let open = spots.indices.filter { !taken.contains($0) }.map { SIMD2<Float>(spots[$0]) + 0.5 }
        return open.min { simd_distance($0, hopper) < simd_distance($1, hopper) } ?? home
    }

    var label: String {
        let back = "Zurück zu \(title)"
        switch kind {
        case .fetch: return complete ? back : "Gesucht: \(species.errand.item)"
        case .rescue: return complete ? "Bring das \(species.baby) zu \(title)" : "Rette: \(species.baby)"
        case .gather: return complete ? back : "Glitzersteine: \(taken.count)/\(spots.count)"
        case .chase: return complete ? back : "Grummel verjagt: \(squashed)/\(Self.pests)"
        }
    }

    var ask: String {
        switch kind {
        case .fetch: species.errand.ask
        case .rescue: "Die Grummel haben mein \(species.baby) mitgenommen! Ich würde ja selbst gehen, aber ich muss hier ganz wichtig rumstehen. Bring es zurück!"
        case .gather: "Ich sammle Glitzersteine. Also, eigentlich sammeln die Grummel sie gerade. Holst du mir \(Self.gems) Stück?"
        case .chase: "Die Grummel machen so viel Krach, ich kann nicht schlafen! Flieg hoch und lande auf \(Self.pests) von ihnen. Pflatsch!"
        }
    }

    var waiting: String {
        switch kind {
        case .fetch: species.errand.waiting
        case .rescue: "Mein \(species.baby) ist noch bei den Grummeln! Folg dem Pfeil, schnell!"
        case .gather: "Erst \(Self.gems) Glitzersteine, dann reden wir. So sind die Regeln."
        case .chase: "Ich höre immer noch Grummeln. Lande auf ihnen! Von oben! Mit Schwung!"
        }
    }

    var thanks: String {
        switch kind {
        case .fetch: species.errand.thanks
        case .rescue: "Mein \(species.baby)! Ich hab mir überhaupt keine Sorgen gemacht. Fast gar nicht. Hier, 5 Münzen."
        case .gather: "\(Self.gems) Glitzersteine! Jetzt hab ich genau … \(Self.gems). Danke! Hier, 5 Münzen."
        case .chase: "Endlich Ruhe. Ich schlafe jetzt drei Tage am Stück. Hier, 5 Münzen."
        }
    }

    func news(taking index: Int) -> String? {
        switch kind {
        case .fetch: "Du hast: \(species.errand.item). Jetzt schnell zurück, bevor die Grummel dich kriegen!"
        case .rescue: "Du hast das \(species.baby) gefunden! Es hüpft dir hinterher. Bring es nach Hause!"
        case .gather: complete ? "Alle Glitzersteine! Zurück zu \(title)." : nil
        case .chase: nil
        }
    }

    var cheer: String? {
        kind == .chase && complete ? "Die Grummel sind weg! Zurück zu \(title)." : nil
    }

    static func make(_ kind: Kind, for resident: Resident, round: Int) -> Quest? {
        let count = kind == .gather ? gems : 1
        var spots: [SIMD2<Int>] = []
        for index in 0..<count {
            guard let spot = target(from: resident.tile, salt: round * 4 + index, avoiding: spots) else { return nil }
            spots.append(spot)
        }
        return Quest(kind: kind, giver: resident.tile, title: resident.title, species: resident.species, spots: spots)
    }

    private static func target(from giver: SIMD2<Int>, salt: Int, avoiding others: [SIMD2<Int>]) -> SIMD2<Int>? {
        for attempt in 0..<80 {
            let angle = Float(Hash.value(giver.x, giver.y, attempt, salt, 50) % 628) / 100
            let distance = 22 + Float(Hash.value(giver.x, giver.y, attempt, salt, 51) % 14)
            let target = giver &+ SIMD2<Int>(Int(cos(angle) * distance), Int(sin(angle) * distance))
            let apart = others.allSatisfy { simd_distance(SIMD2<Float>($0), SIMD2<Float>(target)) > 8 }
            if apart && isOpen(target) && isReachable(from: giver, to: target) { return target }
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
