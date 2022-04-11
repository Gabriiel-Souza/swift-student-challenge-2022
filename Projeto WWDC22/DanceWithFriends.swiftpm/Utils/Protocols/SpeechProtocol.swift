//
//  SpeechProtocol.swift
//  
//
//  Created by Gabriel Souza de Araujo on 11/04/22.
//

import SpriteKit

protocol Speechable {
    
    func getTexts() -> [String]
}

extension Speechable where Self: CaseIterable {
    
    func getTexts() -> [String] {
        if self is TutorialSpeech {
            return TutorialSpeech.allCases.map { $0.rawValue}
        } else if self is FinalSpeech {
            return FinalSpeech.allCases.map { $0.rawValue}
        }
        return []
    }
}
