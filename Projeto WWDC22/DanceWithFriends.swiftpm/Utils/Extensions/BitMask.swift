//
//  BitMask.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 10/04/22.
//

enum GameMask: UInt32 {
    case none            = 0x00000000
    case handMask        = 0x00000001
    case topArrowMask    = 0x00000010
    case leftArrowMask   = 0x00000100
    case bottomArrowMask = 0x00001000
    case rightArrowMask  = 0x00010000
}
