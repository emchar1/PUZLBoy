//
//  AudioItem.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/5/25.
//

import AVFoundation

struct AudioItem {
    
    // MARK: - Properties
    
    let fileName: String
    let fileType: AudioType
    let category: AudioCategory
    let maxVolume: Float
    var currentVolume: Float
    var player = AVAudioPlayer()
    var isPlaying: Bool
    
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
        self.isPlaying = false
    }
}
