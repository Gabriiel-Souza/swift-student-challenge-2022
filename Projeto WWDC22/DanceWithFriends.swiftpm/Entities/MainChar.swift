//
//  MainChar.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 05/04/22.
//

import SpriteKit

class MainChar: SKSpriteNode {
    // MARK: - Initializers
    init () {
        super.init(texture: nil, color: .clear, size: .zero)
    }
    
    init(texture: SKTexture, color: UIColor) {
        super.init(texture: texture, color: color, size: texture.size())
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation(frame: CGRect) {
        // Points
        let startPoint = position
        let finishPoint = CGPoint(x: -frame.minX - size.width, y: -30)
        // Left Actions
        let moveLeft = SKAction.move(to: finishPoint, duration: 5)
        let leftAsset = SKAction.setTexture(SKTexture(imageNamed: HomeSceneAssets.Char.charWithItem + "1_" + "L"))
        let leftGroup = SKAction.group([moveLeft, leftAsset])
        // Right Actions
        let moveRight = SKAction.move(to: startPoint, duration: 5)
        let rightAsset = SKAction.setTexture(SKTexture(imageNamed: HomeSceneAssets.Char.charWithItem + "1_" + "R"))
        let rightGroup = SKAction.group([moveRight, rightAsset])
        // Up and Down Actions
        let moveUp = SKAction.moveTo(y: -20, duration: 0.1)
        let moveDown = SKAction.moveTo(y: -30, duration: 0.1)
        let moveUpDown = SKAction.repeatForever(.sequence([moveUp, moveDown]))
        // Sequence
        let moveAndChangeAsset = SKAction.repeatForever(.sequence([leftGroup, rightGroup]))
        // Run Actions
        let animationGroup = SKAction.group([moveAndChangeAsset, moveUpDown])
        run(animationGroup, withKey: "initialAnimation")
    }
    
    func startFriendAnimation(frame: CGRect) {
        // Points
        let midPoint = CGPoint(x: frame.midX, y: -30)
        // Up and Down Actions
        let moveUp = SKAction.moveTo(y: -20, duration: 0.1)
        let moveDown = SKAction.moveTo(y: -30, duration: 0.1)
        let moveUpDown = SKAction.repeatForever(.sequence([moveUp, moveDown]))
        // Move Actions
        let moveToCenter = SKAction.move(to: midPoint, duration: 2.5)
        // Run actions
        run(moveToCenter) { [weak self] in
            guard let self = self else { return }
            self.removeAllActions()
        }
        run(moveUpDown)
    }
}
