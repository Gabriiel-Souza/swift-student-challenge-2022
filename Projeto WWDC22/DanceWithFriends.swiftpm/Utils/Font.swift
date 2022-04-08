//
//  Font.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 05/04/22.
//
import UIKit

public class Font {
    public static let main: UIFont = {
        let defaultFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let font = UIFont(name: "Fredoka One", size: 14)
        return font ?? defaultFont
    }()
}
