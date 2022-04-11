//
//  IntroScene.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 11/04/22.
//

import SpriteKit

enum IntroSceneAssets {
    static let playButton = "next_arrow"
    static let boxes = "boxes"
}

class IntroScene: SKScene {
    // MARK: - Variables
    private let button = SKSpriteNode(imageNamed: IntroSceneAssets.playButton)
    private weak var gameVC: GameViewController?
    
    // MARK: - Initializers
    init(size: CGSize, gameVC: GameViewController) {
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
        // Boxes
        let boxes = SKSpriteNode(imageNamed: IntroSceneAssets.boxes)
        boxes.anchorPoint = CGPoint(x: 1, y: .zero)
        boxes.position = CGPoint(x: frame.maxX, y: frame.minY)
        addChild(boxes)
        // Button
        button.anchorPoint = CGPoint(x: 0.5, y: 1)
        button.position = CGPoint(x: frame.midX, y: boxes.frame.height * 1.2)
        addChild(button)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let nodes = nodes(at: touch.location(in: self))
        
        for node in nodes {
            if node == button {
                view?.presentScene(HomeScene(size: frame.size, part: .first, gameVC: gameVC))
            }
        }
    }
}
