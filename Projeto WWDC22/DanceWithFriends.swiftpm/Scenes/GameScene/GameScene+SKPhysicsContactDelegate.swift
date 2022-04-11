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
              let mask = GameMask.init(rawValue: arrow),
              let nextArrow = objectiveOrder.first
        else { return }
        
        var side = ObjectivePosition.left
        switch mask {
        case .topArrowMask:
            side = .top
        case .leftArrowMask:
            side = .left
        case .bottomArrowMask:
            side = .bottom
        case .rightArrowMask:
            side = .right
        default:
            break
        }
        if playerCanScore {
            if side == nextArrow {
                // Remove the first element on Array
                let numberOfObjectives = objectiveOrder.count
                print(numberOfObjectives)
                objectiveOrder = objectiveOrder.suffix(numberOfObjectives - 1)
                if objectiveOrder.isEmpty {
                    changeWarningLabel(to: "Perfect!")
                    print("Perfect")
                    addScore()
                } else {
                    changeWarningLabel(to: "Great!")
                }
            } else {
                resetObjetives()
            }
        }
    }
}
