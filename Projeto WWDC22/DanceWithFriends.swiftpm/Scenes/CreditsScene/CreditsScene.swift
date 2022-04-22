//
//  CreditsScene.swift
//  Dance'n'Friends
//
//  Created by Gabriel Souza de Araujo on 21/04/22.
//

import SpriteKit

class CreditsScene: SKScene {
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        backgroundColor = .white
        
        let creditsLabel = SKLabelNode(color: .black, text: "Credits", shadowColor: .clear)
        creditsLabel.position = CGPoint(x: frame.midX, y: frame.maxY * 0.85)
        addChild(creditsLabel)
        
        let failSFXLabel = SKLabelNode(color: .black, text: "Fail Sound Effect by Sjonas88 - https://freesound.org/", shadowColor: .clear)
        failSFXLabel.position = CGPoint(x: frame.midX, y: creditsLabel.position.y * 0.75)
        failSFXLabel.fontSize = 14
        addChild(failSFXLabel)
        
        let musicLabel = SKLabelNode(color: .black, text: "Music \"Emergence\" by Joystock - https://www.joystock.org", shadowColor: .clear)
        musicLabel.position = CGPoint(x: frame.midX, y: failSFXLabel.position.y * 0.93)
        musicLabel.fontSize = 14
        addChild(musicLabel)
        
        let popSFXLabel = SKLabelNode(color: .black, text: "Pop Sound Effect by Epidemic Sound - https://www.epidemicsound.com/", shadowColor: .clear)
        popSFXLabel.position = CGPoint(x: frame.midX, y: musicLabel.position.y * 0.93)
        popSFXLabel.fontSize = 14
        addChild(popSFXLabel)
        
        let backgroundLabel = SKLabelNode(color: .black, text: "Background (Modified): Ghetto vector created by vectorpocket - www.freepik.com", shadowColor: .clear)
        backgroundLabel.position = CGPoint(x: frame.midX, y: popSFXLabel.position.y * 0.93)
        backgroundLabel.fontSize = 14
        addChild(backgroundLabel)
        
        let fontlabel = SKLabelNode(color: .black, text: "Font Fredoka One - Copyright (c) 2022, Milena Brandao, milenabbrandao@gmail.com\nwith Reserved Font Name Fredoka One.", shadowColor: .clear)
        fontlabel.numberOfLines = 2
        fontlabel.position = CGPoint(x: frame.midX, y: backgroundLabel.position.y * 0.83)
        fontlabel.fontSize = 14
        addChild(fontlabel)
        
    }
}
