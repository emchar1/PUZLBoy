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
    case music, musicNoLoop, soundFX, soundFXLoop
}


// MARK: - AudioItem

struct AudioItem {
    let fileName: String
    let fileType: AudioType
    let category: AudioCategory
    let maxVolume: Float
    var currentVolume: Float
    var player = AVAudioPlayer()
    
    init(fileName: String, fileType: AudioType = .mp3, category: AudioCategory, maxVolume: Float = 1.0) {
        self.fileName = fileName
        self.fileType = fileType
        self.category = category
        self.maxVolume = maxVolume
        self.currentVolume = maxVolume
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
    
    let titleLogo = "titletheme"
    let overworldTheme = "overworld"
    let overworldIceTheme = "overworldice"
    let overworldPartyTheme = "overworldparty"
    let grasslandTheme = "overworldgrassland"
    private(set) var currentTheme: String
    private var audioItems: [String: AudioItem] = [:]
    

    // MARK: - Setup
    
    private init() {
        currentTheme = FireIceTheme.isFire ? overworldTheme : overworldIceTheme

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
        addAudioItem("arrowblink", category: .soundFX)
        addAudioItem("bouldersmash", category: .soundFX)
        addAudioItem("boyattack1", category: .soundFX)
        addAudioItem("boyattack2", category: .soundFX)
        addAudioItem("boyattack3", category: .soundFX)
        addAudioItem("boydead", category: .soundFX)
        addAudioItem("boygrunt1", category: .soundFX)
        addAudioItem("boygrunt2", category: .soundFX)
        addAudioItem("boypain1", category: .soundFX)
        addAudioItem("boypain2", category: .soundFX)
        addAudioItem("boypain3", category: .soundFX)
        addAudioItem("boypain4", category: .soundFX)
        addAudioItem("boyimpact", category: .soundFX)
        addAudioItem("boywin", category: .soundFX)
        addAudioItem("buttontap1", category: .soundFX)
        addAudioItem("buttontap2", category: .soundFX)
        addAudioItem("buttontap3", category: .soundFX)
        addAudioItem("buttontap4", category: .soundFX)
        addAudioItem("buttontap5", category: .soundFX)
        addAudioItem("buttontap6", category: .soundFX)
        addAudioItem("buttontap7", category: .soundFX)
        addAudioItem("chatclose", category: .soundFX)
        addAudioItem("chatopen", category: .soundFX)
        addAudioItem("chatopenprincess", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("chatopentrainer", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("chatopenvillain", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("dooropen", category: .soundFX)
        addAudioItem("enemydeath", category: .soundFX)
        addAudioItem("enemyflame", category: .soundFX)
        addAudioItem("enemyice", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("enemyroar", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("enemyscratch", category: .soundFX)
        addAudioItem("gemcollect", category: .soundFX)
        addAudioItem("gemcollectparty", category: .soundFX)
        addAudioItem("gemcollectparty2x", category: .soundFX)
        addAudioItem("gemcollectparty3x", category: .soundFX)
        addAudioItem("gemcollectpartylife", category: .soundFX)
        addAudioItem("hammerswing", category: .soundFX)
        addAudioItem("lavaappear1", category: .soundFX)
        addAudioItem("lavaappear2", category: .soundFX)
        addAudioItem("lavaappear3", category: .soundFX)
        addAudioItem("lavasizzle", category: .soundFX)
        addAudioItem("magicblast", category: .soundFX)
        addAudioItem("magichorrorimpact", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("magicteleport", category: .soundFX)
        addAudioItem("magicwarp", category: .soundFX)
        addAudioItem("marlinblast", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("moveglide", category: .soundFX)
        addAudioItem("movemarsh1", category: .soundFX)
        addAudioItem("movemarsh2", category: .soundFX)
        addAudioItem("movemarsh3", category: .soundFX)
        addAudioItem("movepoisoned1", category: .soundFX)
        addAudioItem("movepoisoned2", category: .soundFX)
        addAudioItem("movepoisoned3", category: .soundFX)
        addAudioItem("moverun1", category: .soundFX)
        addAudioItem("moverun2", category: .soundFX)
        addAudioItem("moverun3", category: .soundFX)
        addAudioItem("moverun4", category: .soundFX)
        addAudioItem("movesand1", category: .soundFX)
        addAudioItem("movesand2", category: .soundFX)
        addAudioItem("movesand3", category: .soundFX)
        addAudioItem("movesnow1", category: .soundFX)
        addAudioItem("movesnow2", category: .soundFX)
        addAudioItem("movesnow3", category: .soundFX)
        addAudioItem("movetile1", category: .soundFX)
        addAudioItem("movetile2", category: .soundFX)
        addAudioItem("movetile3", category: .soundFX)
        addAudioItem("movewalk", category: .soundFX)
        addAudioItem("partypill", category: .soundFX)
        addAudioItem("partyfast", category: .soundFX)
        addAudioItem("partyslow", category: .soundFX)
        addAudioItem("pickupheart", category: .soundFX)
        addAudioItem("pickupitem", category: .soundFX)
        addAudioItem("pickuptime", category: .soundFX)
        addAudioItem("punchwhack1", category: .soundFX)
        addAudioItem("punchwhack2", category: .soundFX)
        addAudioItem("revive", category: .soundFX)
        addAudioItem("speechbubble", category: .soundFX)
        addAudioItem("swordslash", category: .soundFX)
        addAudioItem("thunderrumble", category: .soundFX)
        addAudioItem("warp", category: .soundFX)
        addAudioItem("waterappear1", category: .soundFX)
        addAudioItem("waterappear2", category: .soundFX)
        addAudioItem("waterappear3", category: .soundFX)
        addAudioItem("waterdrown", category: .soundFX)
        addAudioItem("winlevel", category: .soundFX)
        addAudioItem("winlevelice", category: .soundFX) //NEEDS PURCHASE $1

        
        //Looped SFX
        addAudioItem("clocktick", category: .soundFXLoop)
        addAudioItem("magicdoomloop", category: .soundFXLoop)
        addAudioItem("littlegirllaugh", category: .soundFXLoop)
        
        
        //No Loop music
        addAudioItem("ageofruin", category: .musicNoLoop)
        addAudioItem("ageofruin2", category: .musicNoLoop)
        addAudioItem("gameover", category: .musicNoLoop)
        addAudioItem("gameoverice", category: .musicNoLoop) //NEEDS PURCHASE $1
        addAudioItem("titletheme", category: .musicNoLoop)

        
        //Background music
        addAudioItem("birdsambience", category: .music, maxVolume: 0.2)
        addAudioItem("continueloop", category: .music)
        addAudioItem("scarymusicbox", category: .music)
        addAudioItem("magicheartbeatloop1", category: .music) //NEEDS PURCHASE $1
        addAudioItem("magicheartbeatloop2", category: .music) //NEEDS PURCHASE $1
        addAudioItem("overworld", category: .music)
        addAudioItem("overworldice", category: .music) //NEEDS PURCHASE $15 - do I like this???
        addAudioItem("overworldparty", category: .music)
        addAudioItem("overworldgrassland", category: .music)

        
        //9/13/23 Call this AFTER adding all the audioItems above!
        updateVolumes()
    }

    /**
     Adds a sound file to the AudioItems dictionary.
     - parameters:
        - audioKey: The key and filename to add to the dictionary
        - category: The AudioCategory of the sound being added
     */
    private func addAudioItem(_ audioKey: String, category: AudioCategory, maxVolume: Float = 1.0) {
        audioItems[audioKey] = AudioItem(fileName: audioKey, category: category, maxVolume: maxVolume)
        
        if let item = audioItems[audioKey], let player = configureAudioPlayer(for: item) {
            audioItems[audioKey]!.player = player
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
            let shouldLoop = audioItem.category == .music || audioItem.category == .soundFXLoop

            var audioPlayer = audioItem.player
            
            // Memory leak here, according to instruments, but only on Simulator. Device is fine!
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioURL))
            
            audioPlayer.volume = audioItem.currentVolume
            audioPlayer.numberOfLoops = shouldLoop ? -1 : 0
            
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
        - fadeIn: ramp up time in TimeInterval before reaching max volume. Default is 0.
        - delay: adds a delay in TimeInterval before playing the sound. Default is nil.
        - pan: pan value to initialize, defaults to center of player
        - interruptPlayback: I forgot what this meant, but the default is true 🤷🏻‍♀️
     - returns: True if the player can play. False, otherwise.
     */
    @discardableResult func playSound(for audioKey: String, currentTime: TimeInterval? = nil, fadeIn: TimeInterval = 0.0, delay: TimeInterval? = nil, pan: Float = 0, interruptPlayback: Bool = true) -> Bool? {
        guard let item = audioItems[audioKey], let player = configureAudioPlayer(for: item) else {
            print("Unable to find \(audioKey) in AudioManager.audioItems[]")
            return false
        }
        
        guard interruptPlayback || audioItems[item.fileName] != nil && !audioItems[item.fileName]!.player.isPlaying else {
            return false
        }
                
        audioItems[item.fileName]!.player = player
        audioItems[item.fileName]!.player.volume = audioItems[item.fileName]!.currentVolume
        audioItems[item.fileName]!.player.pan = pan
        audioItems[item.fileName]!.player.prepareToPlay()

        if currentTime != nil {
            audioItems[item.fileName]!.player.currentTime = currentTime!
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (delay == nil ? 0 : delay!)) {
            //No need to make completions inside DispatchQueue.main.asyncAfter weak!
            let audioItem = self.audioItems[item.fileName]!
            
            if fadeIn > 0 {
                audioItem.player.setVolume(0.0, fadeDuration: 0)
                audioItem.player.play()
                audioItem.player.setVolume(audioItem.currentVolume, fadeDuration: fadeIn)
            }
            else {
                audioItem.player.play()
            }
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
     Plays an audio, then stops after a certain playForDuration amounts.
     - parameters:
        - audioKey: the key for the audio item to play
        - currentTime: currentTime to start the playback at; if nil, don't set
        - fadeIn: ramp up time in TimeInterval before reaching max volume. Default is 0.
        - playForDuration: The amount to play before beginning the stop audio process.
        - fadeOut: length of time in seconds for music to fade before stopping.
        - delay: adds a delay in TimeInterval before playing the sound. Default is nil.
        - pan: pan value to initialize, defaults to center of player
        - interruptPlayback: I forgot what this meant, but the default is true 🤷🏻‍♀️
     */
    func playSoundThenStop(for audioKey: String, currentTime: TimeInterval? = nil, fadeIn: TimeInterval = 0.0, playForDuration: TimeInterval, fadeOut: TimeInterval = 0.0, delay: TimeInterval? = nil, pan: Float = 0, interruptPlayback: Bool = true ) {

        playSound(for: audioKey, currentTime: currentTime, fadeIn: fadeIn, delay: delay, pan: pan, interruptPlayback: interruptPlayback)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + playForDuration) { [unowned self] in
            stopSound(for: audioKey, fadeDuration: fadeOut)
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
        
        item.player.pan = pan.clamp(min: -1.0, max: 1.0)
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
        
        let volumeToSet: Float = UserDefaults.standard.bool(forKey: (item.category == .music || item.category == .musicNoLoop) ? K.UserDefaults.muteMusic : K.UserDefaults.muteSoundFX) ? 0 : volume

        audioItems[audioKey]!.currentVolume = volumeToSet
        audioItems[audioKey]!.player.setVolume(volumeToSet, fadeDuration: fadeDuration)
    }
    
    func changeTheme(newTheme theme: String) {
        stopSound(for: currentTheme)
        playSound(for: theme)

        currentTheme = theme
    }
    
    /**
     Updates the volume across all audio players. Sets it to 0 (off) or maxVolume (on) based on if the app is muted or not.
     */
    func updateVolumes() {
        for (index, item) in audioItems {
            switch item.category {
            case .music, .musicNoLoop:
                let volumeToSet: Float = UserDefaults.standard.bool(forKey: K.UserDefaults.muteMusic) ? 0 : item.maxVolume
                
                audioItems[index]?.currentVolume = volumeToSet
                item.player.setVolume(volumeToSet, fadeDuration: 0.25)
            case .soundFX, .soundFXLoop:
                let volumeToSet: Float = UserDefaults.standard.bool(forKey: K.UserDefaults.muteSoundFX) ? 0 : item.maxVolume
                
                audioItems[index]?.currentVolume = volumeToSet
                item.player.volume = volumeToSet
            }
        }
    }
}
