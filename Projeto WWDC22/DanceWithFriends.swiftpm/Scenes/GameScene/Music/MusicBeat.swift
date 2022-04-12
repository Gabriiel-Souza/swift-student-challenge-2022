//
//  MusicBeat.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 11/04/22.
//

import AVFoundation
protocol MusicBeatDelegate: AnyObject {
    func beatWillOccur(in time: Double)
}
/// Catch the power of music and notify when it hits the minimun value
class MusicEngine: NSObject {
    // Delegate
    private weak var delegate: MusicBeatDelegate?
    
    // Helpers
    private var isAudioInitialized = false
    private var isTapInstalled = false
    private var prevRMSValue: Float = 0
    private var mainSongPath: String?
    private var beatSongPath: String?
    private let songDelay: Float = 2
    
    // Audio Engine
    private let audioEngine: AVAudioEngine? = AVAudioEngine()
    private var audioMixer = AVAudioMixerNode()
    private var backgroundAudioPlayer: AVAudioPlayerNode? = AVAudioPlayerNode()
    private var mainAudioPlayer: AVAudioPlayerNode? = AVAudioPlayerNode()
    private var sfxAudioPlayer: AVAudioPlayerNode? = AVAudioPlayerNode()
    
    // Audio Engine Data
    private var audioFile = [AVAudioFile]()
    private var audioBuffer = [AVAudioPCMBuffer]()
    
    init(delegate: MusicBeatDelegate) {
        self.delegate = delegate
        let path = Bundle.main.path(forResource: "song", ofType: "mp3")
        mainSongPath = path
        let beatPath = Bundle.main.path(forResource: "song2", ofType: "mp3")
        beatSongPath = beatPath
        super.init()
        setupSong()
    }
    // MARK: - Setups
    /// Pass a `Music` name to start Engine
    public func setupSong() {
        isAudioInitialized = false
        if let mainSongPath = mainSongPath, let beatSongPath = beatSongPath {
            let mainSongUrl = URL(fileURLWithPath: mainSongPath)
            let beatSongUrl = URL(fileURLWithPath: beatSongPath)
            setupEngine(mainSongUrl: mainSongUrl, beatSongUrl: beatSongUrl)
        }
    }
    /// Setup Music engine
    /// - Parameter filePathUrl: Song url to be played
    private func setupEngine(mainSongUrl: URL, beatSongUrl: URL) {
        // Setup PlayerNode
        do {
            for i in 0...1 {
                audioFile.append(try AVAudioFile(forReading: i == 0 ? beatSongUrl : mainSongUrl))
                let audioFormat = audioFile[i].processingFormat
                let audioFrameCount = UInt32(audioFile[i].length)
                
                audioBuffer.append(AVAudioPCMBuffer(pcmFormat: audioFormat,
                                                    frameCapacity: audioFrameCount)!)
                try audioFile[i].read(into: audioBuffer[i])
            }
            if let audioEngine = audioEngine {
                audioMixer = audioEngine.mainMixerNode
            }
            
            let audioPlayers = [backgroundAudioPlayer, mainAudioPlayer, sfxAudioPlayer]
            
            for i in 0..<audioPlayers.count-1 {
                guard let audioplayer = audioPlayers[i] else { return }
                audioEngine?.attach(audioplayer)
                audioEngine?.connect(audioplayer,
                                     to: audioMixer,
                                     fromBus: 0,
                                     toBus: i,
                                     format: audioBuffer[i].format)
            }
            
            // Prepare and Start Engine
            audioEngine?.prepare()
            try audioEngine?.start()
            
            // Setup the audio session to play sound and activate the audio session
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.soloAmbient)
            try AVAudioSession.sharedInstance().setMode(AVAudioSession.Mode.default)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch {
            print("Error on PlayerNode initialize: \(error.localizedDescription)")
        }
    }
    /// Setup the main song
    @objc private func setupMainSong() {
        mainAudioPlayer?.volume = 1
        mainAudioPlayer?.scheduleBuffer(self.audioBuffer[1],at: nil, options: .interrupts) { [weak self] in
            guard let self = self else { return }
            // Song Finished
            self.prevRMSValue = 0
            self.songDidFinished()
        }
        isAudioInitialized = true
        backgroundAudioPlayer?.play()
        mainAudioPlayer?.play()
    }
    // MARK: - Music Beat
    /// Add a observer that will proccess the audio data and send a notification for GameScene if necessary
    private func installTap() {
        if isTapInstalled {
            backgroundAudioPlayer?.removeTap(onBus: 0)
        }
        backgroundAudioPlayer?.installTap(onBus: 0,
                                          bufferSize: 1024,
                                          format: nil) { [weak self] (buffer, time) in
            guard let self = self else { return }
            self.processAudioData(buffer: buffer)
        }
        isTapInstalled = true
    }
    /// Proccess the audio data to detect the beats
    /// - Parameter buffer: The `AVAudioPCMBuffer` from actual Song
    private func processAudioData(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frames = buffer.frameLength
        
        let rmsValue = SignalProcessing.rms(data: channelData, frameLenght: UInt(frames))

        if rmsValue > 0 && prevRMSValue <= 0 {
            /* Only notificate GameScene if has a minimum value and previous value isn't the same
             This prevines to send multiple Notifications due the beat plays for more than 0.1 second
             */
            delegate?.beatWillOccur(in: Double(songDelay))
        }
        prevRMSValue = rmsValue
    }
    // MARK: - Audio Player Control
    /// If the audio isn't initialized yet, the Background player will start at time 00:02 in music and the Main Player will start at 00:00
    public func playMusic() {
        if !isAudioInitialized {
            // Setup tracking song
            backgroundAudioPlayer?.volume = 0
            
            let songFormat = audioFile[0].processingFormat
            let songLengthSamples = audioFile[0].length
            let sampleRateSong = Float(songFormat.sampleRate)
            let startSample = floor(songDelay * sampleRateSong)
            let lengthSamples = Float(songLengthSamples) - startSample
            
            backgroundAudioPlayer?.scheduleSegment(audioFile[0],
                                                   startingFrame: AVAudioFramePosition(startSample),
                                                   frameCount: AVAudioFrameCount(lengthSamples),
                                                   at: nil,
                                                   completionHandler: nil)
            installTap()
            setupMainSong()
        } else {
            backgroundAudioPlayer?.play()
            mainAudioPlayer?.play()
        }
    }
    /// Pause the music
    public func pauseMusic() {
        mainAudioPlayer?.pause()
        backgroundAudioPlayer?.pause()
    }
    /// Reset the Main and Background Players
    func resetAudioPlayer() {
        backgroundAudioPlayer?.pause()
        mainAudioPlayer?.pause()
        audioFile.removeAll()
        audioBuffer.removeAll()
        do {
            if let mainSongPath = mainSongPath, let beatSongPath = beatSongPath {
                let mainSongUrl = URL(fileURLWithPath: mainSongPath)
                let beatSongUrl = URL(fileURLWithPath: beatSongPath)
                for i in 0...1 {
                    audioFile.append(try AVAudioFile(forReading: i == 0 ? beatSongUrl : mainSongUrl))
                    let audioFormat = audioFile[i].processingFormat
                    let audioFrameCount = UInt32(audioFile[i].length)
                    
                    audioBuffer.append(AVAudioPCMBuffer(pcmFormat: audioFormat,
                                                        frameCapacity: audioFrameCount)!)
                    try audioFile[i].read(into: audioBuffer[i])
                }
                playMusic()
            }
        } catch {
            print("Failed in reset Audio Player: \(error.localizedDescription)")
        }
    }
    /// Play Next song after the actual end
    private func songDidFinished() {
        restartSong()
    }
    /// Restart the actual song
    func restartSong() {
        isAudioInitialized = false
        resetAudioPlayer()
    }
    
    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

