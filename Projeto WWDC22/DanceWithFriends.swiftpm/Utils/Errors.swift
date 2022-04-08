//
//  CameraPreview.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 05/04/22.
//

public enum CameraError: Error {
    case
    frontalCamera,
    deviceInput,
    sessionInput,
    sessionDataOutput
    
    public func getDescription() -> String {
        switch self {
        case .frontalCamera:
            return "Couldn't find a frontal camera."
        case .deviceInput:
            return "Couldn't create camera device input."
        case .sessionInput:
            return "Couldn't add camera input to the session."
        case .sessionDataOutput:
            return "Couldn't add camera data output to the session."
        }
    }
}

