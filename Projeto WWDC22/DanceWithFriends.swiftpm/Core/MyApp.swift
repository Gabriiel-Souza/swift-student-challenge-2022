import SwiftUI
import SpriteKit

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .ignoresSafeArea()
        }
    }
}
