//
//  CreditsScene.swift
//  Dance'n'Friends
//
//  Created by Gabriel Souza de Araujo on 21/04/22.
//

import SpriteKit

class CreditsScene: SKScene {
    
    private weak var gameVC: GameViewController?
    
    init(size: CGSize, gameVC: GameViewController?) {
        self.gameVC = gameVC
        super.init(size: size)
    }
   
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        backgroundColor = .white
        
        let creditsLabel = SKLabelNode(color: .black, text: "Credits", shadowColor: .clear)
        creditsLabel.position = CGPoint(x: frame.midX, y: frame.maxY * 0.85)
        addChild(creditsLabel)
        
        let xPosition = frame.midX * 0.2
        // SFX
        let sfxLabel = SKLabelNode(color: .black, text: "SFX", shadowColor: .clear)
        sfxLabel.horizontalAlignmentMode = .left
        sfxLabel.position = CGPoint(x: xPosition, y: creditsLabel.position.y * 0.8)
        sfxLabel.fontSize = 18
        addChild(sfxLabel)
        
        let failSFXLabel = SKLabelNode(color: .black, text: "• Fail Sound Effect by Sjonas88 - https://freesound.org/", shadowColor: .clear)
        failSFXLabel.horizontalAlignmentMode = .left
        failSFXLabel.position = CGPoint(x: xPosition, y: sfxLabel.position.y * 0.93)
        failSFXLabel.fontSize = 14
        addChild(failSFXLabel)
        
        let popSFXLabel = SKLabelNode(color: .black, text: "• Pop Sound Effect by Epidemic Sound - https://www.epidemicsound.com/", shadowColor: .clear)
        popSFXLabel.horizontalAlignmentMode = .left
        popSFXLabel.position = CGPoint(x: xPosition, y: failSFXLabel.position.y * 0.94)
        popSFXLabel.fontSize = 14
        addChild(popSFXLabel)
        // Music
        let musicTitleLabel = SKLabelNode(color: .black, text: "Music", shadowColor: .clear)
        musicTitleLabel.horizontalAlignmentMode = .left
        musicTitleLabel.position = CGPoint(x: xPosition, y: popSFXLabel.position.y * 0.88)
        musicTitleLabel.fontSize = 18
        addChild(musicTitleLabel)
        
        let musicLabel = SKLabelNode(color: .black, text: "• Music \"Emergence\" by Joystock - https://www.joystock.org", shadowColor: .clear)
        musicLabel.horizontalAlignmentMode = .left
        musicLabel.position = CGPoint(x: xPosition, y: musicTitleLabel.position.y * 0.93)
        musicLabel.fontSize = 14
        addChild(musicLabel)
        // Assets
        let assetsLabel = SKLabelNode(color: .black, text: "Assets", shadowColor: .clear)
        assetsLabel.horizontalAlignmentMode = .left
        assetsLabel.position = CGPoint(x: xPosition, y: musicLabel.position.y * 0.87)
        assetsLabel.fontSize = 18
        addChild(assetsLabel)
        
        let backgroundLabel = SKLabelNode(color: .black, text: "• Background (Modified): Ghetto vector created by vectorpocket - www.freepik.com", shadowColor: .clear)
        backgroundLabel.horizontalAlignmentMode = .left
        backgroundLabel.position = CGPoint(x: xPosition, y: assetsLabel.position.y * 0.91)
        backgroundLabel.fontSize = 14
        addChild(backgroundLabel)
        // Font
        let fontTitleLabel = SKLabelNode(color: .black, text: "Font", shadowColor: .clear)
        fontTitleLabel.horizontalAlignmentMode = .left
        fontTitleLabel.position = CGPoint(x: xPosition, y: backgroundLabel.position.y * 0.82)
        fontTitleLabel.fontSize = 18
        addChild(fontTitleLabel)
        
        let fontlabel = SKLabelNode(color: .black, text: "• Font Fredoka One - Copyright (c) 2022, Milena Brandao, milenabbrandao@gmail.com\nwith Reserved Font Name Fredoka One.", shadowColor: .clear)
        fontlabel.horizontalAlignmentMode = .left
        fontlabel.verticalAlignmentMode = .top
        fontlabel.numberOfLines = 2
        fontlabel.position = CGPoint(x: xPosition, y: fontTitleLabel.position.y * 0.97)
        fontlabel.fontSize = 14
        addChild(fontlabel)
        // Try Again
        let tryAgainButton = SKSpriteNode(imageNamed: "try_again_1")
        var textures = [SKTexture]()
        for i in 1...6 {
            textures.append(SKTexture(imageNamed: "try_again_\(i)"))
        }
        let tryAgainSize = tryAgainButton.size
        tryAgainButton.name = "try_again"
        tryAgainButton.anchorPoint = CGPoint(x: 1.0, y: .zero)
        tryAgainButton.position = CGPoint(x: frame.maxX - (tryAgainSize.width / 2), y: frame.minY + (tryAgainSize.height / 2))
        tryAgainButton.run(.repeatForever(.animate(with: textures, timePerFrame: 0.08)))
        addChild(tryAgainButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let touchedNode = nodes(at: touch.location(in: self)).first else { return }
        if touchedNode.name == "try_again" {
            for child in children {
                child.removeAllActions()
            }
            removeAllChildren()
            gameVC?.sceneToPresent = .game
        }
    }
}
