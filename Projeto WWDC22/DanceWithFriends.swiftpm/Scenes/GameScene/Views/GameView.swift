//
//  GameView.swift
//  
//
//  Created by Gabriel Souza de Araujo on 08/04/22.
//

import SwiftUI

struct GameView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        loadFont()
        return GameViewController()
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) { }
    
    /// Load App Fonts
    private func loadFont() {
        let fontURL = Bundle.main.url(forResource: "FredokaOne-Regular", withExtension: "ttf")
        CTFontManagerRegisterFontsForURL(fontURL! as CFURL, CTFontManagerScope.process, nil)
    }
}
