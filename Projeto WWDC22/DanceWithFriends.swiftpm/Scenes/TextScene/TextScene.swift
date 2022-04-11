//
//  TextScene.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 08/04/22.
//

import SpriteKit

enum TextSceneAssets {
    static let nextArrow = "next_arrow"
}

enum TextType {
    case tutorial
    case final
}

class TextScene: SKScene, SkipInteraction {
    // MARK: - Variables
    internal var nextArrow = SKSpriteNode(imageNamed: TextSceneAssets.nextArrow)
    private var tutorialLabel = SKLabelNode()
    private var type = TextType.tutorial
    private var texts = [String]()
    private var actualTextIndex = 0
    private weak var gameVC: GameViewController?
    // MARK: - Initializers
    init(size: CGSize, type: TextType, gameVC: GameViewController?) {
        self.gameVC = gameVC
        self.type = type
        let speeches = type == .tutorial ? (TutorialSpeech.first.getTexts()) : (FinalSpeech.first.getTexts())
        self.texts = speeches
        super.init(size: size)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Life Cycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
    }
    // MARK: - Setup
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
        tutorialLabel.verticalAlignmentMode = .center
        tutorialLabel.numberOfLines = 3
        tutorialLabel.fontName = Font.main.fontName
        tutorialLabel.fontColor = .black
        tutorialLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(tutorialLabel)
    }
    // MARK: - Functions
    private func changeTutorialText() {
        actualTextIndex += 1
        let nextText = texts[actualTextIndex]
        tutorialLabel.text = nextText
    }
    
    private func goToGameScene() {
        gameVC?.sceneToPresent = .game
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if actualTextIndex < texts.count - 1 {
            changeTutorialText()
        } else {
            if type == .tutorial {
                goToGameScene()
            } else {
                nextArrow.alpha = 0
            }
        }
    }
    
}
