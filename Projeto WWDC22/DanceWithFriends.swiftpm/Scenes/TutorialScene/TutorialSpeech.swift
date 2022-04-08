//
//  TutorialSpeech.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 05/04/22.
//

public enum TutorialSpeech: String, CaseIterable {
    case first = "Hi! How are you?"
    case second = "This is Robert, he recently moved out of town"
    case third = "Changes are very complicated, especially when you have to do it alone"
    case fourth = "This situation causes a mixture of emotions..."
    case five = "...Anxiety about being in a place where you don't know anyone..."
    case six = "...Fear of what is to come..."
    case seven = "But the hardest part is definitely the friends left behind..."
    case eight = "Making new friends in a new city may seem difficult for most people"
    case nine = "But I'll show you that with the power of music everything becomes easier!"
    
    mutating func next() -> Self {
        let speeches = Self.allCases
        let actualIndex = speeches.firstIndex(of: self) ?? speeches.startIndex
        let endIndex = speeches.endIndex - 1
        let nextSpeechIndex = actualIndex == endIndex ? speeches.startIndex : speeches.index(after: actualIndex)
        return speeches[nextSpeechIndex]
    }
}
