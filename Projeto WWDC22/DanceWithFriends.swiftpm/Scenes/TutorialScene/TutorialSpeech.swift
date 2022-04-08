//
//  TutorialSpeech.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 05/04/22.
//

public enum TutorialSpeech: String, CaseIterable {
    case first = ""
    case second = "To score you must move!"
    case third = "Move your hand to the objectives that appear, in the right order"
    case last = "When you score enough, a new friend will join your party!"
    
    mutating func next() -> Self {
        let speeches = Self.allCases
        let actualIndex = speeches.firstIndex(of: self) ?? speeches.startIndex
        let endIndex = speeches.endIndex - 1
        let nextSpeechIndex = actualIndex == endIndex ? speeches.startIndex : speeches.index(after: actualIndex)
        return speeches[nextSpeechIndex]
    }
}
