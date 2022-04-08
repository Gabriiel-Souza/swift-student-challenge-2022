//
//  CameraScene.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 05/04/22.
//

import SpriteKit
class CameraScene: SKScene {
    var fingerJoints: [SKShapeNode] = {
        var fingerJoints = [SKShapeNode]()
        for _ in 0...9 {
            var joint = SKShapeNode(circleOfRadius: 10)
            joint.fillColor = .blue
            joint.strokeColor = .clear
            fingerJoints.append(joint)
        }
        return fingerJoints
    }()
    
    override func didMove(to view: SKView) {
        fingerJoints.forEach { joint in
            addChild(joint)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
//        guard let cameraSession = cameraSession else { return }
//        if cameraSession.isRunning {
//            cameraSession.stopRunning()
//        }
    }
    
    func drawPoints(_ fingerTips: [CGPoint], cameraView: CameraPreview) {
        let convertedFingerPoints = fingerTips.map {
            cameraView.previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
        }
        var i = 0
        for fingerPosition in convertedFingerPoints {
            let joint = fingerJoints[i]
            joint.position = fingerPosition
            i += 1
        }
    }
}
