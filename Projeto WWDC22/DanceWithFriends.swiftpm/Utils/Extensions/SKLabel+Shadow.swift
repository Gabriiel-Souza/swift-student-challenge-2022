//
//  SKLabel+Shadow.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 05/04/22.
//

import SpriteKit

extension SKLabelNode {
    public convenience init(font: UIFont = Font.main, color: UIColor, text: String, shadowColor: UIColor) {
        let fontName = font.fontName
        self.init(fontNamed: fontName)
        self.text = text
        self.fontName = fontName
        fontColor = color
        
        let shadowNode = SKLabelNode(fontNamed: fontName)
        shadowNode.text = self.text
        shadowNode.zPosition = zPosition - 1
        shadowNode.fontColor = shadowColor
        // Just create a little offset from the main text label
        shadowNode.position = CGPoint(x: 2, y: -2)
        shadowNode.fontSize = fontSize + 1
        shadowNode.alpha = 0.5
        addChild(shadowNode)
    }
}
