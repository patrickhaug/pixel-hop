import RealityKit
import SwiftUI

struct GameView: View {
    @State private var game = Game()

    var body: some View {
        ZStack {
            RealityView { [game] content in
                content.camera = .virtual
                if let world = try? await game.makeWorld() {
                    content.add(world)
                }
            }
            .ignoresSafeArea()
            if let adventure = game.adventure {
                Color.red
                    .opacity(adventure.flash * 0.35)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        CoinCounter(count: game.coins)
                        if let adventure = game.adventure {
                            Hearts(count: adventure.hearts)
                        }
                        if let flight = game.flight {
                            EnergyBar(level: flight.energy)
                        }
                    }
                    Spacer()
                    if let adventure = game.adventure, let label = adventure.label {
                        QuestBanner(label: label, arrow: adventure.arrow)
                        Spacer()
                    }
                }
                Spacer()
                HStack(alignment: .bottom) {
                    DPad { game.heading = $0 }
                    Spacer()
                    if let dialog = game.dialog {
                        DialogBox(dialog: dialog)
                            .onTapGesture { game.closeDialog() }
                        Spacer()
                    }
                    VStack(alignment: .trailing, spacing: 14) {
                        if game.nearby != nil && game.dialog == nil {
                            TalkButton { game.talk() }
                        }
                        if let flight = game.flight {
                            FlyButton(flying: flight.flying) { game.fly() }
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(Color(red: 0.49, green: 0.78, blue: 0.95))
    }
}
