//
//  FinalSpeech.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 05/04/22.
//

public enum FinalSpeech: String, CaseIterable, Speechable {
    case first = ""
    case second = "Congratulations! You made new friends!"
    case third = "Our life is smoother when we're around friends"
    case last = "Thank you for play!"
    
    mutating func next() -> Self {
        let speeches = Self.allCases
        let actualIndex = speeches.firstIndex(of: self).orDefault
        let endIndex = speeches.endIndex - 1
        let nextSpeechIndex = actualIndex == endIndex ? speeches.startIndex : speeches.index(after: actualIndex)
        return speeches[nextSpeechIndex]
    }
}
