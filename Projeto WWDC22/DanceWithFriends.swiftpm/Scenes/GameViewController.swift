//
//  GameViewController.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 05/04/22.
//

import SpriteKit
import AVFoundation
import Vision

enum ScenePresenting {
    case home
    case tutorial
    case game
    case final
}

class GameViewController: UIViewController {
    // MARK: - Variables
    // Camera
    private var cameraSession: AVCaptureSession?
    private lazy var cameraView = CameraPreview(frame: .zero)
    private lazy var sessionQueue = DispatchQueue(label: "CameraOutput", qos: .userInteractive)
    // Vision
    private var pointsProcessorHandler: (([CGPoint]) -> Void)?
    private let handPoseRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        return request
    }()
    // Game View
    private var skView = SKView()
    private let sceneSize = CGSize(width: 700, height: 500)
    private var skScene = SKScene()
    var sceneToPresent = ScenePresenting.home {
        didSet {
            setupScene()
        }
    }
    // MARK: - Lyfe Cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup
    private func setup() {
        setupGameView()
        setupScene()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func orientationDidChange() {
        cameraView.previewLayer.connection?.videoOrientation = getCameraOrientation()
    }
    
    private func setupGameView() {
        skView = SKView(frame: CGRect(origin: .zero, size: sceneSize))
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.contentMode = .scaleToFill
        view.addSubview(cameraView)
        view.addSubview(skView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        if sceneToPresent == .home {
            // SKView
            skView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                skView.topAnchor.constraint(equalTo: view.topAnchor),
                skView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                skView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                skView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        } else {
            // Camera
            cameraView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cameraView.topAnchor.constraint(equalTo: skView.topAnchor),
                cameraView.trailingAnchor.constraint(equalTo: skView.trailingAnchor),
                cameraView.leadingAnchor.constraint(equalTo: skView.leadingAnchor),
                cameraView.bottomAnchor.constraint(equalTo: skView.bottomAnchor)
            ])
        }
    }
    
    private func setupScene() {
        skView.presentScene(nil)
        switch sceneToPresent {
//        case .intro:
//            skScene = IntroScene(size: sceneSize, gameVC: self)
        case .home:
            skScene = HomeScene(size: sceneSize, part: .first, gameVC: self)
        case .tutorial:
            skScene = TextScene(size: sceneSize, type: .tutorial, gameVC: self)
        case .game:
            setupCamera()
            skScene = GameScene(size: sceneSize, gameVC: self)
        case .final:
            skScene = TextScene(size: sceneSize, type: .final, gameVC: self)
        }
        skScene.scaleMode = .fill
        if sceneToPresent != .home {
            skView.presentScene(skScene, transition: .fade(withDuration: 1.0))
        } else {
            skView.presentScene(skScene)
        }
    }
}
// MARK: - Camera
extension GameViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    /// Get camera orientation based on device state
    /// - Returns: The camera orientation to be used
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
    /// Setup and start camera session
    private func setupCamera() {
        do {
            if cameraSession == nil {
                try setupAVSession()
                cameraView.previewLayer.session = cameraSession
                cameraView.previewLayer.videoGravity = .resizeAspectFill
                cameraView.previewLayer.connection?.videoOrientation = getCameraOrientation()
            }
            setupConstraints()
            cameraSession?.startRunning()
        } catch {
            guard let error = error as? CameraError else { return }
            print(error.getDescription())
        }
        setupObservers()
    }
    /// Setup frontal camera and do initial configuration
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
        guard let scene = skScene as? GameScene else { return }
        var wristPoint: CGPoint = .zero

        defer {
            DispatchQueue.main.sync {
                scene.proccessPoint(wristPoint, cameraView: cameraView)
            }
        }

        let imageRequest = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try imageRequest.perform([handPoseRequest])
            guard let result = handPoseRequest.results?.first else { return }
            
            let wristRecognizedPoint = try result.recognizedPoint(.wrist)
            // I don't want point with confidence <= 0.7;
            if wristRecognizedPoint.confidence > 0.7 {
                // Fix camera axis
                let x = (wristRecognizedPoint.location.x)
                let y = (wristRecognizedPoint.location.y)
                wristPoint = CGPoint(x: x, y: y)
            }
        } catch {
            print(error.localizedDescription)
            cameraSession?.stopRunning()
        }
    }
}
