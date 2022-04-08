//
//  TutorialScene.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 08/04/22.
//

import SpriteKit

class TutorialScene: SKScene {
    private let tutorialLabel = SKLabelNode(text: "")
    private var actualText = TutorialSpeech.first
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = .white
        changeTutorialText()
    }
    
    private func changeTutorialText() {
        actualText = actualText.next()
        tutorialLabel.text = actualText.rawValue
    }
    
    private func goToGameScene() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if actualText != .last {
            
            changeTutorialText()
        } else {
            
        }
    }
    
}
