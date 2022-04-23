//
//  TutorialSpeech.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 05/04/22.
//

public enum TutorialSpeech: String, CaseIterable, Speechable {
    
    case first = ""
    case second = "To play you need to leave the iPad at least 30 centimeters away from you"
    case third = "You will need to move! So remove nearby objects to avoid accidents"
    case fourth = "Move one of your hands to the objectives that appear, in the right order"
    case fifth = "When you score enough, a new friend will join your party!"
    case last = "Ready?"
    
    mutating func next() -> Self {
        let speeches = Self.allCases
        let actualIndex = speeches.firstIndex(of: self).orDefault
        let endIndex = speeches.endIndex - 1
        let nextSpeechIndex = actualIndex == endIndex ? speeches.startIndex : speeches.index(after: actualIndex)
        return speeches[nextSpeechIndex]
    }
}
