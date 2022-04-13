//
//  CameraScene.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 05/04/22.
//


enum GameSceneAssets {
    static let friend = "friend%@_walking_"
    static let background = "background"
    static let char = "char_walking_"
    
    enum Arrow {
        static let topArrow = "top_arrow"
        static let leftArrow = "left_arrow"
        static let bottomArrow = "bottom_arrow"
        static let rigthArrow = "right_arrow"
    }
}

enum ObjectivePosition: CaseIterable {
    case top
    case left
    case bottom
    case right
}

enum Level: Int {
    case first = 0
    case second = 1
    case third = 2
}

import SpriteKit
class GameScene: SKScene {
    // MARK: - Variables
    // Camera
    private var isWristOnScene = false
    private lazy var wristNode = makeWristNode()
    // Game
    private weak var gameVC: GameViewController?
    private var friendsMoved = 0
    private var worldNode = SKNode()
    private var background = [SKSpriteNode]()
    private var actualLevel = Level.first
    private let sides = ObjectivePosition.allCases
    private var targetScore = 5
    private var score = 0 {
        didSet {
            if oldValue == targetScore {
                changeWarningLabel(to: "Perfect!")
                animateFriend()
                if actualLevel != .third {
                    let newlevel = actualLevel.rawValue + 1
                    actualLevel = Level(rawValue: newlevel) ?? .first
                    targetScore += 5
                    score = 0
                } else {
                    print("Venceu o jogo")
                }
            } else if score == 0 {
                updateScoreLabel()
            } else {
                changeWarningLabel(to: "Great!")
            }
        }
    }
    // Map
    private lazy var topArrow = makeArrow(mask: .topArrowMask)
    private lazy var leftArrow = makeArrow(mask: .leftArrowMask)
    private lazy var bottomArrow = makeArrow(mask: .bottomArrowMask)
    private lazy var rightArrow = makeArrow(mask: .rightArrowMask)
    // Entities
    private var char = MainChar()
    private var friends = [SKSpriteNode]()
    // Labels
    private var scoreLabel = SKLabelNode(color: .white, text: "0/5", shadowColor: .black)
    private var warningLabel = SKLabelNode(fontNamed: Font.main.fontName)
    // Music
    private var engine: MusicEngine?
    private(set) var isTopArrowInArea = false
    private(set) var isLeftArrowInArea = false
    private(set) var isBottomArrowInArea = false
    private(set) var isRightArrowInArea = false
    // MARK: - Initializers
    init(size: CGSize, gameVC: GameViewController) {
        self.gameVC = gameVC
        super.init(size: size)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
          
    // MARK: - Life Cycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setup()
    }
    // MARK: - Setup
    private func setup() {
        physicsWorld.contactDelegate = self
        addChild(worldNode)
        setupBackground()
        setupFriends()
        setupChar()
        [topArrow,
         leftArrow,
         bottomArrow,
         rightArrow].forEach { worldNode.addChild($0) }
        setupScoreLabel()
        setupWarningLabel()
        setupSong()
    }
    
    private func setupBackground() {
        // Create 2 sprite nodes to do parallax
        for numberNode in 0...1 {
            background.append(SKSpriteNode(texture: SKTexture(imageNamed: GameSceneAssets.background)))
            let background = background[numberNode]
            let move = SKAction.move(by: CGVector(dx: -background.size.width, dy: 0), duration: 25)
            let resetPosition = SKAction.move(by: CGVector(dx: background.size.width,dy: 0), duration: 0)
            
            background.zPosition = -1
            background.anchorPoint = .zero
            background.position = CGPoint (x: (background.size.width * CGFloat(numberNode)) - CGFloat(1 * numberNode),
                                           y: 0.0)
            background.run(.repeatForever(.sequence([move, resetPosition])))
            worldNode.addChild(background)
        }
    }
    
    private func setupFriends() {
        for friendNumber in 1...3 {
            let friend = SKSpriteNode(imageNamed: String(format: GameSceneAssets.friend, String(friendNumber)) + "left_1")
            friend.position = CGPoint(x: frame.maxX, y: frame.height * 0.02)
            friend.anchorPoint = .zero
            friends.append(friend)
            worldNode.addChild(friend)
        }
    }
    
    private func setupChar() {
        char = MainChar(texture: SKTexture(imageNamed: GameSceneAssets.char + "1"), color: .clear)
        char.anchorPoint = .zero
        char.position = CGPoint(x: frame.midX * 0.35, y: frame.height * 0.02)
        // Animation
        var textures = [SKTexture]()
        for i in 1...4 {
            let texture = SKTexture(imageNamed: GameSceneAssets.char + "\(i)")
            textures.append(texture)
        }
        let animate = SKAction.animate(with: textures, timePerFrame: 0.1)
        char.run(.repeatForever(animate))
        worldNode.addChild(char)
    }
    
    private func setupScoreLabel() {
        scoreLabel.position = CGPoint(x: frame.width * 0.9, y: frame.height * 0.9)
        worldNode.addChild(scoreLabel)
    }
    
    private func setupWarningLabel() {
        warningLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        warningLabel.alpha = 0
        worldNode.addChild(warningLabel)
    }
    
    private func setupSong() {
        DispatchQueue.main.async {
            self.engine = MusicEngine(delegate: self)
            self.engine?.playMusic()
        }
    }
    // MARK: - Node Makers
    private func makeArrow(mask: GameMask) -> SKSpriteNode {
        let arrow: SKSpriteNode
        let texture: SKTexture
        let center: CGPoint
        let horizontalSize = CGSize(width: frame.width * 0.7, height: 100)
        let verticalSize = CGSize(width: 100, height: frame.height * 0.7)
        let vSpacing = (view?.safeAreaInsets.bottom).orDefault
        var hSpacing = (view?.safeAreaInsets.left).orDefault
        if hSpacing == 0 {
            hSpacing = vSpacing
        }
        let size: CGSize
        switch mask {
        case .topArrowMask:
            texture = SKTexture(imageNamed: GameSceneAssets.Arrow.topArrow)
            arrow = SKSpriteNode(texture: texture)
            size = horizontalSize
            center = CGPoint(x: .zero, y: -20)
            arrow.anchorPoint = CGPoint(x: 0.5, y: 1)
            arrow.position = CGPoint(x: frame.midX, y: frame.maxY - vSpacing)
        case .leftArrowMask:
            texture = SKTexture(imageNamed: GameSceneAssets.Arrow.leftArrow)
            arrow = SKSpriteNode(texture: texture)
            size = verticalSize
            center = .zero
            arrow.anchorPoint = CGPoint(x: 0, y: 0.5)
            arrow.position = CGPoint(x: frame.minX + hSpacing, y: frame.midY)
        case .bottomArrowMask:
            texture = SKTexture(imageNamed: GameSceneAssets.Arrow.bottomArrow)
            arrow = SKSpriteNode(texture: texture)
            size = horizontalSize
            center = CGPoint(x: .zero, y: 10)
            arrow.anchorPoint = CGPoint(x: 0.5, y: 0)
            arrow.position = CGPoint(x: frame.midX, y: frame.minY + vSpacing)
        case .rightArrowMask:
            texture = SKTexture(imageNamed: GameSceneAssets.Arrow.rigthArrow)
            arrow = SKSpriteNode(texture: texture)
            size = verticalSize
            center = .zero
            arrow.anchorPoint = CGPoint(x: 1, y: 0.5)
            arrow.position = CGPoint(x: frame.maxX - hSpacing, y: frame.midY)
        default:
            return SKSpriteNode()
        }
        arrow.alpha = 0.8
        // Physic Body
        arrow.physicsBody = SKPhysicsBody(rectangleOf: size , center: center)
        arrow.physicsBody?.isDynamic = false
        arrow.physicsBody?.categoryBitMask = mask.rawValue
        //        arrow.physicsBody?.contactTestBitMask = GameMask.handMask.rawValue
        arrow.physicsBody?.collisionBitMask = GameMask.none.rawValue
        return arrow
    }
    
    private func makeWristNode() -> SKShapeNode {
        let wristNode = SKShapeNode(circleOfRadius: 10)
        wristNode.name = "\(GameMask.handMask)"
        wristNode.fillColor = .blue
        wristNode.strokeColor = .clear
        // Physic Body
        wristNode.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        wristNode.physicsBody?.affectedByGravity = false
        wristNode.physicsBody?.categoryBitMask = GameMask.handMask.rawValue
        // Contact Mask
        wristNode.physicsBody?.contactTestBitMask =
        GameMask.topArrowMask.rawValue |
        GameMask.leftArrowMask.rawValue |
        GameMask.bottomArrowMask.rawValue |
        GameMask.rightArrowMask.rawValue
        wristNode.physicsBody?.collisionBitMask = GameMask.none.rawValue
        return wristNode
    }
    
    // MARK: - Score
    func addScore() {
        score += 1
        updateScoreLabel()
    }
    
    private func updateScoreLabel() {
        scoreLabel.removeFromParent()
        scoreLabel = SKLabelNode(color: .white, text: "\(score)/\(targetScore)", shadowColor: .black)
        setupScoreLabel()
    }
    
    func changeWarningLabel(to text: String) {
        warningLabel.removeFromParent()
        warningLabel = SKLabelNode(color: .white, text: text, shadowColor: .black)
        setupWarningLabel()
        let appear = SKAction.fadeAlpha(to: 1, duration: 0.5)
        let wait = SKAction.wait(forDuration: 0.5)
        let disappear = SKAction.fadeAlpha(to: 0, duration: 0.5)
        let sequence = SKAction.sequence([appear, wait, disappear])
        warningLabel.run(sequence)
        if text == "Perfect!" {
            let sfxNode = SKAudioNode(fileNamed: "success")
            sfxNode.autoplayLooped = false
            addChild(sfxNode)
            sfxNode.run(.play())
        }
    }
    
    func toggleMask(_ mask: GameMask) {
        switch mask {
        case .topArrowMask:
            isTopArrowInArea.toggle()
        case .leftArrowMask:
            isLeftArrowInArea.toggle()
        case .bottomArrowMask:
            isBottomArrowInArea.toggle()
        case .rightArrowMask:
            isRightArrowInArea.toggle()
        default:
            break
        }
    }
    
    // MARK: - Friends
    private func animateFriend() {
        friendsMoved += 1
        if friendsMoved == 3 {
            let disappear = SKAction.fadeOut(withDuration: 0.5)
            let removeArrows = SKAction.removeFromParent()
            let disappearSequence = SKAction.sequence([disappear, removeArrows])
            [topArrow,
             leftArrow,
             bottomArrow,
             rightArrow].forEach { $0.run(disappearSequence) }
        }
        let friend = friends[actualLevel.rawValue]
        // Move Left Action
        let divider = actualLevel == .first ? 2.5 : 3.3
        let distanceFromChar = -((char.frame.width / divider) * CGFloat(actualLevel.rawValue + 1))
        let y = friend.position.y - CGFloat(actualLevel.rawValue) * 3
        let moveLeft = SKAction.move(to: CGPoint(x: char.position.x + distanceFromChar,
                                                 y: y),
                                     duration: 5)
        // Left Animation Action
        var leftTextures = [SKTexture]()
        for i in 1...4 {
            let friend = String(format: GameSceneAssets.friend, String(actualLevel.rawValue + 1)) // Ex.: friend1_walking_
            let texture = SKTexture(imageNamed: friend + "left_\(i)") // Ex.: friend1_walking_left_1
            leftTextures.append(texture)
        }
        let animateLeft = SKAction.repeatForever(.animate(with: leftTextures, timePerFrame: 0.1))
        // Right Animation Action
        var rightTextures = [SKTexture]()
        for i in 1...4 {
            let friend = String(format: GameSceneAssets.friend, String(actualLevel.rawValue + 1)) // Ex.: friend1_walking_
            let texture = SKTexture(imageNamed: friend + "right_\(i)") // Ex.: friend1_walking_right_1
            rightTextures.append(texture)
        }
        let animateRight = SKAction.repeatForever(.animate(with: rightTextures, timePerFrame: 0.1))
        // Move to left and animate friend
        friend.run(animateLeft, withKey: "animateLeft")
        friend.run(moveLeft) { [weak self] in
            guard let self = self else { return }
            // Remove left animation
            friend.removeAction(forKey: "animateLeft")
            // Set right animation
            friend.run(.repeatForever(animateRight))
            if self.friendsMoved == 3 {
                let wait = SKAction.wait(forDuration: 4)
                let goToFinalScene = SKAction.run {
                    self.gameVC?.sceneToPresent = .final
                }
                let moveSequence = SKAction.sequence([wait, goToFinalScene])
                self.worldNode.run(moveSequence)
            }
        }
    }
    
    func proccessPoint(_ wristPoint: CGPoint, cameraView: CameraPreview) {
        let convertedPoint = cameraView.previewLayer.layerPointConverted(fromCaptureDevicePoint: wristPoint)
        if wristPoint != .zero {
            if !isWristOnScene {
                worldNode.addChild(wristNode)
                isWristOnScene = true
            }
            wristNode.position = convertedPoint
        } else {
            wristNode.removeFromParent()
            isWristOnScene = false
        }
    }
}
// MARK: - MusicBeatDelegate
extension GameScene: MusicBeatDelegate {
    private func getRandomArrow(delay: Double) {
        guard friendsMoved < 3, let objective = sides.randomElement() else { return }
        let color: UIColor
        let node: SKSpriteNode
        let target: CGPoint
        // Get Position
        switch objective {
        case .top:
            // Top Position
            node = topArrow
            target = CGPoint(x: frame.midX, y: frame.maxY + node.frame.height)
            color = .blue
        case .left:
            // Left Position
            node = leftArrow
            target = CGPoint(x: frame.minX - node.frame.width, y: frame.midY)
            color = .red
        case .bottom:
            // Down Position
            node = bottomArrow
            target = CGPoint(x: frame.midX, y: frame.minY - node.frame.height)
            color = .yellow
        case .right:
            // Right Position
            node = rightArrow
            target = CGPoint(x: frame.maxX + node.frame.width, y: frame.midY)
            color = .green
        }
        let ojectiveNode = SKSpriteNode(imageNamed: "\(objective)_arrow")
        ojectiveNode.alpha = 0
        ojectiveNode.position = CGPoint(x: frame.midX, y: frame.midY)
        // Actions
        // Change the color and set alpha to 1 -> 0,5s
        let setMaxAlpha = SKAction.fadeAlpha(to: 1, duration: 0.2)
        let changeColor = SKAction.colorize(with: color, colorBlendFactor: 1, duration: 0.5)
        // Move
        let moveTo = SKAction.move(to: target, duration: delay + 0.8)
        // Enable Score
        let wait = SKAction.wait(forDuration: delay - 0.5)
        let canScore = SKAction.run {
            switch objective {
            case .top:
                self.isTopArrowInArea = true
            case .left:
                self.isLeftArrowInArea = true
            case .bottom:
                self.isBottomArrowInArea = true
            case .right:
                self.isRightArrowInArea = true
            }
        }
        let scoreSequence = SKAction.sequence([wait, canScore])
        let appearAndMove = SKAction.group([setMaxAlpha, changeColor, moveTo, scoreSequence])
        // Remove from scene
        let removeNode = SKAction.removeFromParent()
        let disableScore = SKAction.run {
            switch objective {
            case .top:
                self.isTopArrowInArea.toggle()
            case .left:
                self.isLeftArrowInArea.toggle()
            case .bottom:
                self.isBottomArrowInArea.toggle()
            case .right:
                self.isRightArrowInArea.toggle()
            }
        }
        // Sequence -> 2.5s
        let nodeSequence = SKAction.sequence([appearAndMove, disableScore, removeNode])
        ojectiveNode.run(nodeSequence)
        worldNode.addChild(ojectiveNode)
    }
    
    func beatWillOccur(in time: Double) {
        getRandomArrow(delay: time)
    }
}
