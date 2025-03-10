//
//  AudioManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/16/22.
//

import AVFoundation

class AudioManager {
    
    // MARK: - Properties
    
    private let audioQueue = DispatchQueue(label: "com.5play-apps.PUZL-Boy.AudioQueue")
    private var audioItems: [String: AudioItem] = [:]
    
    static let shared: AudioManager = {
        let instance = AudioManager()
        //additional setup, if needed
        return instance
    }()
    
    
    // MARK: - Initialization
    
    private init() {
        //Including within DispatchQueue here per ChatGPT 3/8/25
        DispatchQueue.main.async {
            do {
                //ambient: Your app’s audio plays even while Music app music or other background audio is playing, and is silenced by the phone’s Silent switch and screen locking.
                //soloAmbient: (the default) Your app stops Music app music or other background audio from playing, and is silenced by the phone’s Silent switch and screen locking.
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            }
            catch {
                print(error)
            }
        }
        
        setupAudioItems()
        updateVolumes() //9/13/23 Call this AFTER setting up audioItems!
    }
    
    ///Initializes all the audio items, files, players, etc.
    private func setupAudioItems() {
        for libraryEntry in AudioLibrary.audioItems {
            let item = AudioItem(fileName: libraryEntry.audioKey, category: libraryEntry.category, maxVolume: libraryEntry.maxVolume)
            item.initializePlayer()
            
            audioItems[libraryEntry.audioKey] = item
        }
    }
    
    
    // MARK: - Playback Functions
    
    /**
     Plays a sound for a given key that exists in the audioItems dictionary.
     - parameters:
        - audioKey: the key for the audio item to play
        - currentTime: currentTime to start the playback at; if nil, don't set
        - fadeIn: ramp up time in TimeInterval before reaching max volume. Default is 0.
        - delay: adds a delay in TimeInterval before playing the sound. Default is nil.
        - pan: pan value to initialize, defaults to center of player
        - interruptPlayback: if false, if sound is currently playing and call to playSound() is made, let existing playback play and cancel call to playSound().
        - shouldLoop: if non-nil, override the audio item's category property, to determine whether to loop playback or not
     - returns: True if the player can play. False, otherwise.
     */
    @discardableResult func playSound(for audioKey: String,
                                      currentTime: TimeInterval? = nil,
                                      fadeIn: TimeInterval = 0.0,
                                      delay: TimeInterval? = nil,
                                      pan: Float = 0,
                                      interruptPlayback: Bool = true,
                                      shouldLoop: Bool? = nil) -> Bool {
        
        guard let item = audioItems[audioKey] else {
            print("Unable to find \(audioKey) in AudioManager.audioItems[]")
            return false
        }
        
        guard interruptPlayback || !item.player.isPlaying else { return false }
        
        item.player.volume = item.currentVolume
        item.player.pan = pan
        item.player.currentTime = currentTime ?? 0
        
        if let shouldLoop = shouldLoop {
            item.player.numberOfLoops = shouldLoop ? -1 : 0
        }
        else {
            //If shouldLoop is nil, rever to item's category definition
            item.player.numberOfLoops = AudioItem.getNumberOfLoops(audioItemCategory: item.category)
        }
        
        audioQueue.asyncAfter(deadline: .now() + (delay ?? 0)) {
            //No need to make completions inside Queue weak!
            
//            //For debugging. Uncomment this to see if audio is being interrupted by playing it while it's already playing 3/1/25
//            if item.player.isPlaying {
//                print("WARNING: Attempting to play audio \(audioKey) while it is already playing!")
//            }
            
            if fadeIn > 0 {
                item.player.setVolume(0.0, fadeDuration: 0)
                item.player.play()
                item.player.setVolume(item.currentVolume, fadeDuration: fadeIn)
            }
            else {
                item.player.play()
            }
        }
        
        return true
    }
    
    /**
     Stops playing a specified audio item, with decrescendo if needed.
     - parameters:
        - audioKey: the key for the audio item to stop
        - fadeDuration: length of time in seconds for music to fade before stopping.
        - forceStop: if true, stops current playback immediately, regardless of if the audio item is currently playing or not.
     */
    func stopSound(for audioKey: String, fadeDuration: TimeInterval = 0.0, forceStop: Bool = false) {
        guard let item = audioItems[audioKey] else {
            print("Unable to find \(audioKey) in AudioManager.audioItems[]")
            return
        }
        
        guard forceStop || item.player.isPlaying else { return }
        
        item.player.setVolume(0.0, fadeDuration: fadeDuration)
        
        audioQueue.asyncAfter(deadline: .now() + fadeDuration) {
            //Need the guard here again due to the async nature of this function and potential race conditions if stopSound() is called multiple times.
            guard forceStop || item.player.isPlaying else { return }
            
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
        - interruptPlayback: if false, if sound is currently playing and call to playSound() is made, let existing playback play and cancel call to playSound().
        - shouldLoop: if non-nil, override the audio item's category property, to determine whether to loop playback or not
     */
    func playSoundThenStop(for audioKey: String,
                           currentTime: TimeInterval? = nil,
                           fadeIn: TimeInterval = 0.0,
                           playForDuration: TimeInterval,
                           fadeOut: TimeInterval = 0.0,
                           delay: TimeInterval? = nil,
                           pan: Float = 0,
                           interruptPlayback: Bool = true,
                           shouldLoop: Bool? = nil) {
        
        playSound(for: audioKey,
                  currentTime: currentTime,
                  fadeIn: fadeIn,
                  delay: delay,
                  pan: pan,
                  interruptPlayback: interruptPlayback,
                  shouldLoop: shouldLoop)
        
        audioQueue.asyncAfter(deadline: .now() + playForDuration + (delay ?? 0)) {
            self.stopSound(for: audioKey, fadeDuration: fadeOut)
        }
    }
    
    
    // MARK: - Sound Customization Functions
    
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
        
        item.currentVolume = volumeToSet
        item.player.setVolume(volumeToSet, fadeDuration: fadeDuration)
    }
    
    /**
     Updates the volume across all audio players. Sets it to 0 (off) or maxVolume (on) based on if the app is muted or not.
     */
    func updateVolumes() {
        for (_, item) in audioItems {
            let volumeToSet: Float
            let fadeDuration: TimeInterval
            
            switch item.category {
            case .music, .musicNoLoop:
                volumeToSet = UserDefaults.standard.bool(forKey: K.UserDefaults.muteMusic) ? 0 : item.maxVolume
                fadeDuration = 0.25
            case .soundFX, .soundFXLoop:
                volumeToSet = UserDefaults.standard.bool(forKey: K.UserDefaults.muteSoundFX) ? 0 : item.maxVolume
                fadeDuration = 0
            }
            
            item.currentVolume = volumeToSet
            item.player.setVolume(volumeToSet, fadeDuration: fadeDuration)
        }
    }
    
    
    // MARK: - Getters
    
    /**
     Gets the AudioItem for the given filename.
     - parameter filename: String name of the file in question.
     - returns: an AudioItem, for which to manipulate.
     */
    func getAudioItem(filename: String) -> AudioItem? {
        return audioItems[filename]
    }
    
    /**
     Gets a list of audioItem filenames that are currently playing.
     */
    func getActiveSoundsPlaying() -> [String] {
        return audioItems.values.filter { $0.player.isPlaying }.map(\.fileName)
    }
    
    /**
     Checks if the current sound or music is playing, returns true if so.
     - parameter audioKey: the string value of the sound or music
     - returns: true if it is playing
     */
    func isPlaying(audioKey: String) -> Bool {
        guard let item = audioItems[audioKey] else { return false }
        
        return item.player.isPlaying
    }
    
    
}
