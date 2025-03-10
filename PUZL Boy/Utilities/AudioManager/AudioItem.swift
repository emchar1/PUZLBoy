//
//  AudioItem.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/5/25.
//

import AVFoundation

class AudioItem {
    
    // MARK: - Properties
    
    // Metadata
    let fileName: String
    let fileType: AudioType
    let category: AudioCategory
    let maxVolume: Float
    var currentVolume: Float
    
    // AVPlayer
    var player = AVAudioPlayer()
    
    enum AudioType: String {
        case mp3 = "mp3", wav, m4a
    }
    
    enum AudioCategory {
        case music, musicNoLoop, soundFX, soundFXLoop
    }
    
    
    // MARK: - Initialization
    
    init(fileName: String, fileType: AudioType = .mp3, category: AudioCategory, maxVolume: Float = 1.0) {
        self.fileName = fileName
        self.fileType = fileType
        self.category = category
        self.maxVolume = maxVolume
        self.currentVolume = maxVolume
    }
    
    
    // MARK: - Functions
    
    /**
     Initializes the player when needed.
     */
    func initializePlayer() {
        guard let audioURL = Bundle.main.url(forResource: fileName, withExtension: fileType.rawValue) else {
            print("Unable to find sound file: \(fileName).\(fileType.rawValue)")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: audioURL)
            player.volume = currentVolume
            player.numberOfLoops = AudioItem.getNumberOfLoops(audioItemCategory: category)
            player.prepareToPlay()
        } catch {
            print("Error initializing player for file: \(fileName). Error: \(error)")
        }
    }
    
    /**
     Returns the number of loops based on the audioItem category.
     - parameter audioItemCategory: the AudioCategory to categorize the sound
     - returns the number of loops the sound should have based on the category
     */
    static func getNumberOfLoops(audioItemCategory: AudioCategory) -> Int {
        let shouldLoop = audioItemCategory == .music || audioItemCategory == .soundFXLoop
        
        return shouldLoop ? -1 : 0
    }
    
    
}
