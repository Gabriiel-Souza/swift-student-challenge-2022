//
//  GameScene+SKPhysicsContactDelegate.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 10/04/22.
//

import SpriteKit
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let arrow = contact.bodyA.node?.physicsBody?.categoryBitMask,
              let mask = GameMask.init(rawValue: arrow)
        else { return }
        let canScore: Bool
        
        switch mask {
        case .topArrowMask:
            canScore = isTopArrowInArea
        case .leftArrowMask:
            canScore = isLeftArrowInArea
        case .bottomArrowMask:
            canScore = isBottomArrowInArea
        case .rightArrowMask:
            canScore = isRightArrowInArea
        default:
            canScore = false
            break
        }
        toggleMask(mask)
        canScore ? addScore() : changeWarningLabel(to: .miss)
    }
}
