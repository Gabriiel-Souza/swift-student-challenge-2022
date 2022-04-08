import SwiftUI
import SpriteKit

@main
struct MyApp: App {
    var scene: SKScene{
        let size = CGSize(width: 700, height: 500)
        let scene = HomeScene(size: size, part: .first)
        scene.scaleMode = .fill
        return scene
    }
    var body: some Scene {
        WindowGroup {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    loadFont()
                }
        }
    }
    /// Load App Fonts
    private func loadFont() {
        let fontURL = Bundle.main.url(forResource: "FredokaOne-Regular", withExtension: "ttf")
        CTFontManagerRegisterFontsForURL(fontURL! as CFURL, CTFontManagerScope.process, nil)
    }
}
