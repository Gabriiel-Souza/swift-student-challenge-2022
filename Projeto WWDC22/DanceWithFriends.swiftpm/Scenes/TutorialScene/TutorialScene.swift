//
//  TutorialScene.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 08/04/22.
//

import SpriteKit

class TutorialScene: SKScene, SkipInteraction {
    internal var nextArrow = SKSpriteNode(imageNamed: HomeSceneAssets.HUD.nextArrow)
    private var tutorialLabel = SKLabelNode()
    private var actualText = TutorialSpeech.first
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
    }
    
    private func setupScene() {
        backgroundColor = .white
        setupLabel()
        setupNextSpeechArrow(needToHide: false)
        changeTutorialText()
    }
    
    private func setupLabel() {
        tutorialLabel = SKLabelNode(text: "")
        tutorialLabel.preferredMaxLayoutWidth = frame.width * 0.85
        tutorialLabel.lineBreakMode = .byWordWrapping
        tutorialLabel.horizontalAlignmentMode = .center
        tutorialLabel.numberOfLines = 3
        tutorialLabel.fontName = Font.main.fontName
        tutorialLabel.fontColor = .black
        tutorialLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(tutorialLabel)
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
            goToGameScene()
        }
    }
    
}
