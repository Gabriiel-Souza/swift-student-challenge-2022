//
//  SKScene.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 08/04/22.
//

import SpriteKit

// MARK: - Next Arrow
protocol SkipInteraction: AnyObject {
    // Variables
    var nextArrow: SKSpriteNode { get set }
    // Initializers
//    init()
//    init(size: CGSize, nextButtonImageName: String)
//    init(size: CGSize, nextButtonImageName: String, part: HomeScenePart)
    // Functions
    func setupNextSpeechArrow()
}
extension SkipInteraction where Self: SKScene {
    // MARK: - Initializer
//    init(size: CGSize, nextButtonImageName: String) {
//        self.init()
//        self.init(size: size)
//        nextArrow = SKSpriteNode(imageNamed: nextButtonImageName)
//    }
//    init(size: CGSize, nextButtonImageName: String, part: HomeScenePart) {
//        self.init()
//        super.init(size: size)
//        nextArrow = SKSpriteNode(imageNamed: nextButtonImageName)
//        guard let homeScene = self as? HomeScene else { return }
//        homeScene.part = part
//    }
    // MARK: - Setup
    /// Setup `nextArrow` Node, you need to setup Arrow Button before
    func setupNextSpeechArrow() {
        // Next Arrow
        nextArrow.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        nextArrow.name = "nextArrow"
        nextArrow.position = CGPoint(x: frame.width * 0.95, y: frame.height * 0.1)
        nextArrow.alpha = 0
        let moveRigth = SKAction.moveTo(x: nextArrow.position.x + 5, duration: 0.3)
        let moveLeft = SKAction.moveTo(x: nextArrow.position.x - 5, duration: 0.3)
        nextArrow.run(
            .repeatForever(
                .sequence(
                    [moveRigth, moveLeft]
                )
            )
        )
        addChild(nextArrow)
    }
}
