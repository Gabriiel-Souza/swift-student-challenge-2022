//
//  SKScene+SoundPlayable.swift
//  
//
//  Created by Gabriel Souza de Araujo on 17/04/22.
//

import SpriteKit

enum SoundType: String {
    case button = "button"
    case goalPoint = "success"
    case miss = "fail"
}

protocol SoundPlayable {
    func playSound(of type: SoundType)
}

extension SoundPlayable where Self: SKScene {
    /// Add the `SKAudioNode` on scene and play the button sound
    func playSound(of type: SoundType) {
        let buttonSound = SKAudioNode(fileNamed: type.rawValue)
        buttonSound.autoplayLooped = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.addChild(buttonSound)
            buttonSound.run(.play())
        }
    }
}
