import UIKit

enum Cue {
    case coin, gift, talk, steer, quest, found, reward, hurt, faint, splash, danger, climb
    case step(Character)

    func play() {
        switch self {
        case .coin:
            Sounds.shared.play("coin", volume: 0.5)
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .gift:
            Sounds.shared.play("gift")
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .talk:
            Sounds.shared.play("talk", volume: 0.6)
            UISelectionFeedbackGenerator().selectionChanged()
        case .steer:
            UISelectionFeedbackGenerator().selectionChanged()
        case .quest:
            Sounds.shared.play("quest", volume: 0.7)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .found:
            Sounds.shared.play("found", volume: 0.7)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .reward:
            Sounds.shared.play("reward", volume: 0.7)
            Sounds.shared.play("gift")
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .hurt:
            Sounds.shared.play("hurt")
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .faint:
            Sounds.shared.play("faint", volume: 0.8)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .splash:
            Sounds.shared.play("splash", volume: 0.35)
        case .danger:
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.6)
        case .climb:
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.7)
        case .step(let tile):
            Sounds.shared.play("step-\(Self.ground(tile))-\(Int.random(in: 0...2))", volume: 0.25)
        }
    }

    private static func ground(_ tile: Character) -> String {
        switch tile {
        case ",", "C", "@": "stone"
        case "#", "d": "wood"
        case ":", "s", "=": "sand"
        case "^": "snow"
        default: "grass"
        }
    }
}
