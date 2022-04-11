//
//  SignalProcessing.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 11/04/22.
//

import Accelerate

/// Process the Signal from a Audio
class SignalProcessing {
    /// Calculates the Root Mean Square that is used to calculate the average of a function that goes above and below the x-axis
    ///
    /// - Parameters:
    ///   - data: A Float Channel Data that comes from a `AVAudioPCMBuffer.floatChannelData`
    ///   - frameLenght: The current number of valid sample frames in the buffer.
    /// - Returns: The Root Mean Square from data
    static func rms(data: UnsafeMutablePointer<Float>, frameLenght: UInt) -> Float {
        var square: Float = 0
        vDSP_measqv(data, 1, &square, frameLenght)
        var decibels = 10 * log10f(square)
        
        decibels += 40

        let dividor = Float(40/0.3)
        
        var adjustedVal = 0.3 + decibels/dividor
        
        // Cutoff
        if adjustedVal > 0.6 {
            adjustedVal = 0.6
        }
        return adjustedVal
    }
}
