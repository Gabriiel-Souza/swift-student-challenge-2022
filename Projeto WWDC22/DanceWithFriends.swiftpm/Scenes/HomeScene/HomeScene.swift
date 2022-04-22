//
//  HomeScene.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 05/04/22.
//

import SpriteKit

class HomeSceneAssets {
    enum HUD {
        static let nextArrow = "next_arrow"
    }
    enum Char {
        static let charWithItem = "char_item_"
        static let charWithPortrait = "char_holding_portrait"
        static let portrait = "portrait"
    }
    enum Scenery {
        static let commode = "commode"
        static let plant = "plant"
        static let poster = "poster"
        static let wall = "wall"
    }
}

enum HomeScenePart {
    case first
    case second
}

class HomeScene: SKScene, SkipInteraction, SoundPlayable {
    // MARK: - Variables
    internal var nextArrow = SKSpriteNode(imageNamed: HomeSceneAssets.HUD.nextArrow)
    private var sentences = SKLabelNode()
    private let part: HomeScenePart
    private lazy var actualSpeech = part == .first ? HomeSpeech.initial : .six
    private weak var gameVC: GameViewController?
    // MARK: - Nodes
    private var char = MainChar()
    private let wall = SKSpriteNode(imageNamed: HomeSceneAssets.Scenery.wall)
    private let commode = SKSpriteNode(imageNamed: HomeSceneAssets.Scenery.commode)
    private let plant = SKSpriteNode(imageNamed: HomeSceneAssets.Scenery.plant)
    private lazy var objectNodes = [commode, plant]
    
    private var finishedActualSpeech = false {
        didSet {
            isNextSpeechArrowHidden(oldValue)
        }
    }
    // MARK: - Initializers
    init(size: CGSize, part: HomeScenePart, gameVC: GameViewController?) {
        self.part = part
        self.gameVC = gameVC
        let texture = part == .first ?
        SKTexture(imageNamed: HomeSceneAssets.Char.charWithItem + "1_" + "L") :
        SKTexture(imageNamed: HomeSceneAssets.Char.charWithPortrait)
        char = MainChar(texture: texture, color: .clear)
        super.init(size: size)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Life Cycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupBackground()
        setupChar()
        setupSentences()
        setupNextSpeechArrow(needToHide: true)
    }
    // MARK: - Setups
    /// Setup Initial nodes for scene background
    private func setupBackground() {
        // Wall
        wall.anchorPoint = .zero
        addChild(wall)
        // Commode
        commode.anchorPoint = CGPoint(x: 0.5, y: 0)
        commode.position = CGPoint(x: frame.width * 0.3, y: -10)
        addChild(commode)
        // Plant
        plant.anchorPoint = CGPoint(x: 0.5, y: 0)
        plant.position = CGPoint(x: -(commode.frame.width * 0.25), y: commode.frame.maxY * 0.98)
        commode.addChild(plant)
        // Poster
        let poster = SKSpriteNode(imageNamed: HomeSceneAssets.Scenery.poster)
        poster.position = CGPoint(x: frame.width * 0.8, y: frame.height * 0.6)
//        addChild(poster)
    }
    /// Setup char for scene
    private func setupChar() {
        char.anchorPoint = CGPoint(x: 0.5, y: 0)
        char.position = CGPoint(x: frame.width + char.size.width, y: -30)
        addChild(char)
        part == .first ? char.startAnimation(frame: frame) : char.startFriendAnimation(frame: frame)
    }
    /// Setup sentences for scene
    private func setupSentences() {
        sentences = SKLabelNode(text: "")
        sentences.preferredMaxLayoutWidth = frame.width * 0.85
        sentences.lineBreakMode = .byClipping
        sentences.horizontalAlignmentMode = .center
        sentences.numberOfLines = 2
        sentences.verticalAlignmentMode = .top
        sentences.fontName = Font.main.fontName
        sentences.fontColor = .black
        sentences.position = CGPoint(x: frame.midX, y: frame.height * 0.97)
        sentences.alpha = part == .first ? 0 : 1
        // Actions
        if part == .first {
            let wait = SKAction.wait(forDuration: 2)
            let appear = SKAction.fadeIn(withDuration: 0.4)
            sentences.run(.sequence([wait, appear])) {
                self.changeSpeech()
            }
        } else {
            changeSpeech()
        }
        addChild(sentences)
    }
    // MARK: - Functions
    /// Change the `sentences` label to the next Speech
    private func changeSpeech() {
        // Reset Label
        finishedActualSpeech = false
        actualSpeech = actualSpeech.next()
        sentences.text = ""
        // Setup for speech
        let speech = actualSpeech.rawValue
        let lettersCount = speech.count
        var index = 0
        // Type animation
        let wait = SKAction.wait(forDuration: 0.06)
        let addLetter = SKAction.run {
            index += 1
            let textToWrite = String(speech.prefix(index))
            self.sentences.text = textToWrite
            if textToWrite == speech {
                self.finishedActualSpeech = true
            }
        }
        let sequence = SKAction.sequence([wait, addLetter])
        let typeLetters = SKAction.repeat(sequence, count: lettersCount)
        sentences.run(typeLetters, withKey: "texting")
    }
    
    private func presentPart2() {
        clearScene()
        view?.presentScene(HomeScene(size: frame.size, part: .second, gameVC: gameVC ?? GameViewController()), transition: .fade(withDuration: 0.5))
    }
    
    private func removeObjects() {
        for object in objectNodes {
            object.removeFromParent()
        }
        char.removeFromParent()
    }
    
    private func goToTutorial() {
        clearScene()
        view?.presentScene(TextScene(size: frame.size, type: .tutorial, gameVC: gameVC))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if finishedActualSpeech {
            playSound(of: .button)
            if part == .first && actualSpeech == .six {
                presentPart2()
            } else {
                actualSpeech == .last ? goToTutorial() : changeSpeech()
            }
            
            if actualSpeech == .eight {
                removeObjects()
                // Portrait
                let portraitNode = SKSpriteNode(imageNamed: HomeSceneAssets.Char.portrait)
                portraitNode.anchorPoint = CGPoint(x: 0.5, y: .zero)
                portraitNode.position = CGPoint(x: frame.midX, y: frame.height * 0.05)
                portraitNode.alpha = 0
                addChild(portraitNode)
                // Action
                let show = SKAction.fadeAlpha(to: 1, duration: 1.0)
                portraitNode.run(show)
            }
        } else {
            sentences.removeAllActions()
            if actualSpeech == .initial {
                sentences.alpha = 1
                actualSpeech = .first
            }
            sentences.text = actualSpeech.rawValue
            finishedActualSpeech = true
        }
    }
    
    private func clearScene() {
        removeAllActions()
        children.forEach { child in
            child.removeAllActions()
            child.removeAllChildren()
            child.removeFromParent()
        }
        removeAllChildren()
    }
}
