//
//  CameraScene.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 05/04/22.
//


enum GameSceneAssets {
    static let friend = "friend%@_"
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
    var objectiveOrder = [ObjectivePosition]()
    private(set) var playerCanScore = false
    private var score = 0 {
        didSet {
            if oldValue == 5 {
                animateFriend()
                if actualLevel != .third {
                    let newlevel = actualLevel.rawValue + 1
                    actualLevel = Level(rawValue: newlevel) ?? .first
                    score = 0
                } else {
                    print("Venceu o jogo")
                }
            } else if score == 0 {
                updateScoreLabel()
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
        drawObjectives()
        setupScoreLabel()
        setupWarningLabel()
        setupSong()
    }
    
    private func setupBackground() {
        // Create 2 sprite nodes to do parallax
        for numberNode in 0...1 {
            background.append(SKSpriteNode(texture: SKTexture(imageNamed: GameSceneAssets.background)))
            let background = background[numberNode]
            let move = SKAction.move(by: CGVector(dx: -background.size.width, dy:0), duration: 25)
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
            let friend = SKSpriteNode(imageNamed: String(format: GameSceneAssets.friend, String(friendNumber)) + "L")
            friend.position = CGPoint(x: frame.maxX, y: frame.height * 0.02)
            friend.anchorPoint = .zero
            friends.append(friend)
            worldNode.addChild(friend)
        }
    }
    
    private func setupChar() {
        char = MainChar(texture: SKTexture(imageNamed: GameSceneAssets.char + "1"), color: .clear)
        char.anchorPoint = .zero
        char.position = CGPoint(x: frame.midX * 0.25, y: frame.height * 0.02)
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
    // MARK: - Objectives
    func resetObjetives() {
        playerCanScore = false
        changeWarningLabel(to: "Miss!")
        drawObjectives()
    }
    
    private func drawObjectives() {
        // Setup Values
        var numberOfObjectives = 0
        var objectiveSpeed: TimeInterval = 0
        playerCanScore = false
        objectiveOrder = [ObjectivePosition]()
        // Attribute Values
        switch actualLevel {
        case .first:
            numberOfObjectives = 3
            objectiveSpeed = 1.5
        case .second:
            numberOfObjectives = 4
            objectiveSpeed = 1.5
        case .third:
            numberOfObjectives = 5
            objectiveSpeed = 1.5
        }
        getRandomOrder(numberOfObjectives: numberOfObjectives, objectiveSpeed: objectiveSpeed)
    }
    
    private func getRandomOrder(numberOfObjectives: Int, objectiveSpeed: TimeInterval) {
        var objectivePile = [ObjectivePosition]()
        // Get a random order for objectives
        for _ in 1...numberOfObjectives {
            guard let newObjective = sides.randomElement() else { continue }
            objectiveOrder.append(newObjective)
            objectivePile.append(newObjective)
        }
        // Draw Actions
        let wait = SKAction.wait(forDuration: objectiveSpeed)
        let drawObjectives = SKAction.run { [weak self] in
            guard let self = self, let objective = objectivePile.first else {
                self?.playerCanScore = true
                return
            }
            let color: UIColor
            let node: SKSpriteNode
            // Get Position
            switch objective {
            case .top:
                // Top Position
                color = .blue
                node = self.topArrow
            case .left:
                // Left Position
                color = .red
                node = self.leftArrow
            case .bottom:
                // Down Position
                color = .yellow
                node = self.bottomArrow
            case .right:
                // Right Position
                color = .green
                node = self.rightArrow
            }
            // Node Actions
            // Change the color and set alpha to 1 -> 0,5s
            let setMaxAlpha = SKAction.fadeAlpha(to: 1, duration: 0.2)
            let changeColor = SKAction.colorize(with: color, colorBlendFactor: 1, duration: 0.5)
            let selected = SKAction.group([setMaxAlpha, changeColor])
            // Wait for player see -> 0,5s
            let nodeWait = SKAction.wait(forDuration: 0.5)
            // Back to original state -> 0,5s
            let originalTexture = SKAction.setTexture(SKTexture(imageNamed: "\(objective)_arrow"))
            let originalAlpha = SKAction.fadeAlpha(to: 0.8, duration: 0.5)
            let originalColor = SKAction.colorize(with: color, colorBlendFactor: 0, duration: 0.5)
            let original = SKAction.group([originalTexture, originalAlpha, originalColor])
            // Sequence -> 1,5s
            let nodeSequence = SKAction.sequence([selected, nodeWait, original])
            // Remove the first element on Array
            let numberOfObjectives = objectivePile.count
            objectivePile = objectivePile.suffix(numberOfObjectives - 1)
            
            node.run(nodeSequence)
        }
        let sequence = SKAction.sequence([drawObjectives, wait])
        worldNode.run(.repeat(sequence, count: numberOfObjectives)) {
            print("Player can score now")
            self.playerCanScore = true
        }
    }
    // MARK: - Score
    func addScore() {
        score += 1
        updateScoreLabel()
        drawObjectives()
    }
    
    private func updateScoreLabel() {
        scoreLabel.removeFromParent()
        scoreLabel = SKLabelNode(color: .white, text: "\(score)/5", shadowColor: .black)
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
        let distanceFromChar = actualLevel == .first ? friend.frame.size.width / 5 : friend.frame.size.width / 2
        let y = friend.position.y - CGFloat(actualLevel.rawValue) * 3
        let referencePosition = actualLevel == .first ? char.position : friends[actualLevel.rawValue - 1].position
        let move = SKAction.move(to: CGPoint(x: referencePosition.x - distanceFromChar,
                                             y: y),
                                 duration: 5)
        let changeTexture = SKAction.setTexture(SKTexture(imageNamed: String(format: GameSceneAssets.friend,
                                                                             String(actualLevel.rawValue + 1)) + "R"))
        let sequence = SKAction.sequence([move, changeTexture])
        friend.run(sequence) { [weak self] in
            guard let self = self else { return }
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

extension GameScene: MusicBeatDelegate {
    func beatWillOccur(in time: TimeInterval) {
        <#code#>
    }
    
    func beatWillFinish(in time: TimeInterval) {
        <#code#>
    }
    
}
