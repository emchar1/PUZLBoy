//
//  AudioManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/16/22.
//

import Foundation
import AVFoundation


// MARK: - Audio Enums

enum AudioType: String {
    case mp3 = "mp3", wav, m4a
}

enum AudioCategory {
    case music, soundFX
}


// MARK: - AudioItem

struct AudioItem {
    let fileName: String
    let fileType: AudioType
    let category: AudioCategory
    let maxVolume: Float
    var player = AVAudioPlayer()
    
    init(fileName: String, fileType: AudioType = .mp3, category: AudioCategory, maxVolume: Float = 1.0) {
        self.fileName = fileName
        self.fileType = fileType
        self.category = category
        self.maxVolume = maxVolume
    }
}


// MARK: - AudioManager

class AudioManager {
    
    // MARK: - Properties
    
    static let shared: AudioManager = {
        let instance = AudioManager()
        //additional setup, if needed
        return instance
    }()
    
    let overworldTheme = "overworld6"
    private var audioItems: [String: AudioItem] = [:]
    

    // MARK: - Setup
    
    private init() {
        do {
            //ambient: Your app’s audio plays even while Music app music or other background audio is playing, and is silenced by the phone’s Silent switch and screen locking.
            //soloAmbient: (the default) Your app stops Music app music or other background audio from playing, and is silenced by the phone’s Silent switch and screen locking.
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch {
            print(error)
        }
        
        //Sound FX
        addAudioItem("bouldersmash", category: .soundFX)
        addAudioItem("boyattack1", category: .soundFX)
        addAudioItem("boyattack2", category: .soundFX)
        addAudioItem("boyattack3", category: .soundFX)
        addAudioItem("boydead", category: .soundFX)
        addAudioItem("boygrunt1", category: .soundFX)
        addAudioItem("boygrunt2", category: .soundFX)
        addAudioItem("buttontap", category: .soundFX)
        addAudioItem("chatclose", category: .soundFX)
        addAudioItem("chatopen2", category: .soundFX)
        addAudioItem("dooropen", category: .soundFX)
        addAudioItem("enemydeath", category: .soundFX)
        addAudioItem("gameover", category: .soundFX)
        addAudioItem("gemcollect", category: .soundFX)
        addAudioItem("hammerswing", category: .soundFX)
        addAudioItem("moveglide", category: .soundFX)
        addAudioItem("movemarsh", category: .soundFX)
        addAudioItem("movepoisoned", category: .soundFX)
        addAudioItem("moverun1", category: .soundFX)
        addAudioItem("moverun2", category: .soundFX)
        addAudioItem("moverun3", category: .soundFX)
        addAudioItem("moverun4", category: .soundFX)
        addAudioItem("movewalk", category: .soundFX)
        addAudioItem("pickupheart", category: .soundFX)
        addAudioItem("pickupitem", category: .soundFX)
        addAudioItem("revive", category: .soundFX)
        addAudioItem("swordslash", category: .soundFX)
        addAudioItem("warp", category: .soundFX)
        addAudioItem("winlevel", category: .soundFX)
        
        //Background music
        addAudioItem("overworld_egg", category: .music)
        addAudioItem("overworld_galaxy", category: .music)
        addAudioItem("overworld_throwback", category: .music)
        addAudioItem("overworld", category: .music)
        addAudioItem("overworld2", category: .music)
        addAudioItem("overworld3", category: .music)
        addAudioItem("overworld4", category: .music)
        addAudioItem("overworld5", category: .music)
        addAudioItem("overworld6", category: .music)
    }

    /**
     Adds a sound file to the AudioItems dictionary.
     - parameters:
        - audioKey: The key and filename to add to the dictionary
        - category: The AudioCategory of the sound being added
     */
    private func addAudioItem(_ audioKey: String, category: AudioCategory) {
        audioItems[audioKey] = AudioItem(fileName: audioKey, category: category)
        
        if let item = audioItems[audioKey], let player = configureAudioPlayer(for: item) {
            audioItems[audioKey]?.player = player
        }
    }
    
    /**
     Helper method for setupSounds() and playSound(); for some reason need to re-create the player if re-playing the sound. Takes in an AudioItem, sets up and returns the new player.
     - parameter audioItem: AudioItem to configure the player
     - returns: an AudioPlayer optional object
     */
    private func configureAudioPlayer(for audioItem: AudioItem) -> AVAudioPlayer? {
        guard let audioURL = Bundle.main.path(forResource: audioItem.fileName, ofType: audioItem.fileType.rawValue) else {
            print("Unable to find sound file: \(audioItem.fileName).\(audioItem.fileType.rawValue)")
            return nil
        }
        
        do {
            var audioPlayer = audioItem.player
            
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioURL))
            audioPlayer.volume = UserDefaults.standard.bool(forKey: K.UserDefaults.soundIsMuted) ? 0.0 : audioItem.maxVolume
            audioPlayer.numberOfLoops = audioItem.category == .music ? -1 : 0
            
            return audioPlayer
        }
        catch {
            print(error)
        }
        
        return nil
    }
    
    
    // MARK: - Playback
    
    /**
     Plays a sound for a given key that exists in the audioItems dictionary.
     - parameters:
        - audioKey: the key for the audio item to play
        - currentTime: currentTime to start the playback at; if nil, don't set
        - pan: pan value to initialize, defaults to center of player
     - returns: True if the player can play. False, otherwise.
     */
    @discardableResult func playSound(for audioKey: String, currentTime: TimeInterval? = nil, delay: TimeInterval? = nil, pan: Float = 0, interruptPlayback: Bool = true) -> Bool? {
        guard let item = audioItems[audioKey], let player = configureAudioPlayer(for: item) else {
            print("Unable to find \(audioKey) in AudioManager.audioItems[]")
            return false
        }
        
        guard interruptPlayback || audioItems[item.fileName] != nil && !audioItems[item.fileName]!.player.isPlaying else {
            return false
        }
                
        audioItems[item.fileName]?.player = player
        audioItems[item.fileName]?.player.pan = pan
        audioItems[item.fileName]?.player.prepareToPlay()

        if currentTime != nil {
            audioItems[item.fileName]?.player.currentTime = currentTime!
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (delay == nil ? 0 : delay!)) {
            self.audioItems[item.fileName]?.player.play()
        }
                
        return true
    }
    
    /**
     Stops playing a specified audio item, with decrescendo if needed.
     - parameters:
        - audioKey: the key for the audio item to stop
        - fadeDuration: length of time in seconds for music to fade before stopping.
     */
    func stopSound(for audioKey: String, fadeDuration: TimeInterval = 0.0) {
        guard let item = audioItems[audioKey] else {
            print("Unable to find \(audioKey) in AudioManager.audioItems[]")
            return
        }
        
        item.player.setVolume(0.0, fadeDuration: fadeDuration)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration) {
            item.player.stop()
        }
    }
    
    /**
     Sets the pan of the audioItem.
     - parameters:
        - audioKey: the key for the audio item to set the pan for
        - pan: pan value to set to
     */
    func setPan(for audioKey: String, to pan: Float) {
        guard let item = audioItems[audioKey] else {
            print("Unable to find \(audioKey) in AudioManager.audioItems[]")
            return
        }
        
        let panAdusted = pan.clamp(min: -1.0, max: 1.0)
        
        item.player.pan = panAdusted
    }
    
    /**
     Lowers the volume of the specified audio item to 0, with decrescendo if needed.
     - parameters:
        - audioKey: the key for the audio item to stop
        - fadeDuration: length of time in seconds for music to fade before volume gets to zero.
     */
    func lowerVolume(for audioKey: String, fadeDuration: TimeInterval = 0.0) {
        adjustVolume(to: 0, for: audioKey, fadeDuration: fadeDuration)
    }
    
    /**
     Returns  the volume of the specified audio item to 1, with crescendo if needed.
     - parameters:
        - audioKey: the key for the audio item to resume
        - fadeDuration: length of time in seconds for music to fade before resuming to regular volume.
     */
    func raiseVolume(for audioKey: String, fadeDuration: TimeInterval = 0.0) {
        adjustVolume(to: 1, for: audioKey, fadeDuration: fadeDuration)
    }
    
    /**
     Sets the volume of the audioItem to the selected volume.
     - parameters:
        - audioKey: the key for the audio item to set the volume for
        - volume: the new volume to set
        - fadeDuration: the rate of volume change before reaching the desired volume
     */
    func adjustVolume(to volume: Float, for audioKey: String, fadeDuration: TimeInterval = 0) {
        guard let item = audioItems[audioKey] else {
            print("Unable to find \(audioKey) in AudioManager.audioItems[]")
            return
        }
        
        item.player.setVolume(volume, fadeDuration: fadeDuration)
    }
    
//    /**
//     Updates the volume across all audio players. Sets it to 0 (off) or 1 (on) based on if the app is muted or not.
//     */
//    func updateVolumes() {
//        for (_, item) in audioItems {
//            let volumeToSet: Float = UserDefaults.standard.bool(forKey: K.UserDefaults.SoundIsMuted) ? 0.0 : item.maxVolume
//
//            if item.category == .music {
//                item.player.setVolume(volumeToSet, fadeDuration: 0.25)
//            }
//            else {
//                item.player.volume = volumeToSet
//            }
//        }
//    }
}
