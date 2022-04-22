//
//  SKScene+SkipInteraction.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 08/04/22.
//

import SpriteKit

// MARK: - Next Arrow
protocol SkipInteraction: AnyObject {
    // Variables
    var nextArrow: SKSpriteNode { get set }
    // Functions
    func setupNextSpeechArrow(needToHide: Bool)
    func isNextSpeechArrowHidden(_ isHidden: Bool)
}
extension SkipInteraction where Self: SKScene {
    // MARK: - Setup
    /// Setup `nextArrow` Node, you need to setup Arrow Button before
    func setupNextSpeechArrow(needToHide: Bool) {
        // Next Arrow
        nextArrow.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        nextArrow.name = "nextArrow"
        nextArrow.position = CGPoint(x: frame.width * 0.95, y: frame.height * 0.1)
        nextArrow.alpha = needToHide ? 0 : 1
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
    /// Hide or show the arrow to go to next speech
    /// - Parameter isHidden: Tha value to change the alpha of `nextArrow`
    func isNextSpeechArrowHidden(_ isHidden: Bool) {
        nextArrow.alpha = isHidden ? 0 : 1
    }
}
