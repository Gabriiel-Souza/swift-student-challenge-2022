//
//  GameViewController.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 05/04/22.
//

import SpriteKit
import AVFoundation
import Vision

public class GameViewController: UIViewController {
    private var pointsProcessorHandler: (([CGPoint]) -> Void)?
    private let handPoseRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 2
        return request
    }()
    private var cameraSession: AVCaptureSession?
    private var cameraView = CameraPreview()
    private var sessionQueue = DispatchQueue(label: "CameraOutput", qos: .userInteractive)
    private var skView = SKView()
    private var skScene = CameraScene()
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraView = CameraPreview(frame: view.bounds)
        setupCamera()
        setupGameView()
        skScene = CameraScene(size: view.bounds.size)
        skView.presentScene(skScene)
    }
    
    private func setupCamera() {
        do {
            if cameraSession == nil {
                try setupAVSession()
                cameraView.previewLayer.session = cameraSession
                cameraView.previewLayer.videoGravity = .resizeAspectFill
            }
            view.addSubview(self.cameraView)
            cameraSession?.startRunning()
        } catch {
            guard let error = error as? CameraError else { return }
            print(error.getDescription())
        }
    }
    
    private func setupGameView() {
        skView = SKView(frame: view.bounds)
        skView.translatesAutoresizingMaskIntoConstraints = false
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = false
        skView.showsDrawCount = false
        view.addSubview(skView)
    }
}

// MARK: - Camera
extension GameViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    private func getCameraOrientation() -> AVCaptureVideoOrientation{
        let newOrientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            newOrientation = .landscapeRight
        default:
            newOrientation = .landscapeLeft
        }
        return newOrientation
    }
    
    private func setupAVSession() throws {
        // Get frontal camera
        guard let frontalCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw CameraError.frontalCamera
        }
        
        // Check if can use frontal camera
        guard let cameraInput = try? AVCaptureDeviceInput(device: frontalCamera) else {
            throw CameraError.deviceInput
        }
        
        // Create capture session and configure it
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        // Check and add the input to session if is valid
        guard session.canAddInput(cameraInput) else {
            throw CameraError.sessionInput
        }
        session.addInput(cameraInput)
        
        // Create and add data output to camera session
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            dataOutput.connection(with: .video)?.videoOrientation = getCameraOrientation()
        } else {
            throw CameraError.sessionDataOutput
        }
        
        // Finish session configuration
        session.commitConfiguration()
        cameraSession = session
    }
}

// MARK: - Motion Capture
extension GameViewController {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var fingerPoints: [CGPoint] = []
        
        defer {
            DispatchQueue.main.sync {
                self.skScene.drawPoints(fingerPoints, cameraView: cameraView)
            }
        }
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([handPoseRequest])
            guard let results = handPoseRequest.results?.prefix(2), !results.isEmpty else { return }
            var fingersRecognizedPoints: [VNRecognizedPoint] = []
            
            try results.forEach { observation in
                // Get Finger Points
                let fingers = try observation.recognizedPoints(.all)
                
                // Here I'll get Tip Points
                if let indexPoint = fingers[.indexTip] {
                    fingersRecognizedPoints.append(indexPoint)
                }
                
                if let littlePoint = fingers[.littleTip] {
                    fingersRecognizedPoints.append(littlePoint)
                }
                
                if let middlePoint = fingers[.middleTip] {
                    fingersRecognizedPoints.append(middlePoint)
                }
                
                if let ringPoint = fingers[.ringTip] {
                    fingersRecognizedPoints.append(ringPoint)
                }
                
                if let thumbPoint = fingers[.thumbTip] {
                    fingersRecognizedPoints.append(thumbPoint)
                }
            }
            // I don't want point with confidence <= 0.9
            fingerPoints = fingersRecognizedPoints.filter {
                $0.confidence > 0.9
            }.map {
                // Fix camera y axis
                CGPoint(x: $0.location.x, y: 1 - $0.location.y)
            }
        } catch {
            print(error.localizedDescription)
            cameraSession?.stopRunning()
        }
    }
}
