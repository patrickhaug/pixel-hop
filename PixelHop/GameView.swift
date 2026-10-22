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
            VStack {
                HStack {
                    CoinCounter(count: game.coins)
                    Spacer()
                }
                Spacer()
                HStack {
                    DPad { game.heading = $0 }
                    Spacer()
                }
            }
            .padding(24)
        }
        .background(Color(red: 0.49, green: 0.78, blue: 0.95))
    }
}
