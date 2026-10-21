import SpriteKit
import SwiftUI

@main
struct PixelHopApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .ignoresSafeArea()
                .statusBarHidden()
                .persistentSystemOverlays(.hidden)
        }
    }
}

struct GameView: View {
    @State private var scene: GameScene?

    var body: some View {
        GeometryReader { geometry in
            if let scene {
                SpriteView(scene: scene)
                    .onChange(of: geometry.size) { _, size in scene.fit(to: size) }
            } else {
                Color.black.onAppear { scene = GameScene(viewSize: geometry.size) }
            }
        }
    }
}
