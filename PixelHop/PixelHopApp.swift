import SwiftUI

@main
struct PixelHopApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .statusBarHidden()
                .persistentSystemOverlays(.hidden)
        }
    }
}
