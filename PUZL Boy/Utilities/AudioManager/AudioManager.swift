//
//  AudioManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/16/22.
//

import AVFoundation

class AudioManager {
    
    // MARK: - Properties
    
    private var audioItems: [String: AudioItem] = [:]
    
    static let shared: AudioManager = {
        let instance = AudioManager()
        //additional setup, if needed
        return instance
    }()
    

    // MARK: - Initialization
    
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
        
        setupAudioItems()
        updateVolumes() //9/13/23 Call this AFTER setting up audioItems!
    }
    
    ///Initializes all the audio items, files, players, etc.
    private func setupAudioItems() {
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
        addAudioItem("buttontap5", category: .soundFX) //not purchased $5
        addAudioItem("buttontap6", category: .soundFX)
        addAudioItem("buttontap7", category: .soundFX)
        addAudioItem("chatclose", category: .soundFX)
        addAudioItem("chatopen", category: .soundFX)
        addAudioItem("chatopenelder", category: .soundFX)
        addAudioItem("chatopenprincess", category: .soundFX)
        addAudioItem("chatopenstatue", category: .soundFX)
        addAudioItem("chatopentrainer", category: .soundFX)
        addAudioItem("chatopenvillain", category: .soundFX)
        addAudioItem("dooropen", category: .soundFX)
        addAudioItem("enemydeath", category: .soundFX)
        addAudioItem("enemyflame", category: .soundFX)
        addAudioItem("enemyice", category: .soundFX)
        addAudioItem("enemyroar", category: .soundFX)
        addAudioItem("enemyscratch", category: .soundFX) //not purchased $3
        addAudioItem("forcefield", category: .soundFX)
        addAudioItem("forcefield2", category: .soundFX)
        addAudioItem("gemcollect", category: .soundFX)
        addAudioItem("gemcollectparty", category: .soundFX)
        addAudioItem("gemcollectparty2x", category: .soundFX)
        addAudioItem("gemcollectparty3x", category: .soundFX)
        addAudioItem("gemcollectpartylife", category: .soundFX)
        addAudioItem("hammerswing", category: .soundFX)
        addAudioItem("lavaappear1", category: .soundFX) //not purchased $2
        addAudioItem("lavaappear2", category: .soundFX) //not purchased $3
        addAudioItem("lavaappear3", category: .soundFX) //not purchased $4
        addAudioItem("lavasizzle", category: .soundFX) //not purchased $10
        addAudioItem("lightsoff", category: .soundFX)
        addAudioItem("lightson", category: .soundFX)
        addAudioItem("magicblast", category: .soundFX)
        addAudioItem("magicdisappear", category: .soundFX)
        addAudioItem("magicdisappear2", category: .soundFX) //NEEDS PURCHASE $2
        addAudioItem("magicdisappear2b", category: .soundFX) //NEEDS PURCHASE $1 - either this or the one above!
        addAudioItem("magicelderbanish", category: .soundFX)
        addAudioItem("magicelderexplosion", category: .soundFX)
        addAudioItem("magicelderreduce", category: .soundFX)
        addAudioItem("magichorrorimpact", category: .soundFX)
        addAudioItem("magichorrorimpact2", category: .soundFX) //NEEDS PURCHASE $2
        addAudioItem("magicteleport", category: .soundFX)
        addAudioItem("magicteleport2", category: .soundFX)
        addAudioItem("magicwarp", category: .soundFX) //not purchased $2
        addAudioItem("magicwarp2", category: .soundFX)
        addAudioItem("marlinblast", category: .soundFX)
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
        addAudioItem("movesand3", category: .soundFX) //not purchased $5
        addAudioItem("movesnow1", category: .soundFX) //not purchased $1
        addAudioItem("movesnow2", category: .soundFX)
        addAudioItem("movesnow3", category: .soundFX)
        addAudioItem("movetile1", category: .soundFX)
        addAudioItem("movetile2", category: .soundFX)
        addAudioItem("movetile3", category: .soundFX)
        addAudioItem("movewalk", category: .soundFX) //not purchased $3
        addAudioItem("partypill", category: .soundFX)
        addAudioItem("partyfast", category: .soundFX)
        addAudioItem("partyslow", category: .soundFX)
        addAudioItem("pickupheart", category: .soundFX)
        addAudioItem("pickupitem", category: .soundFX)
        addAudioItem("pickuptime", category: .soundFX)
        addAudioItem("punchwhack1", category: .soundFX)
        addAudioItem("punchwhack2", category: .soundFX)
        addAudioItem("realmtransition", category: .soundFX)
        addAudioItem("revive", category: .soundFX)
        addAudioItem("sadaccent", category: .soundFX)
        addAudioItem("scarylaugh", category: .soundFX)
        addAudioItem("shieldcast", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("shieldcast2", category: .soundFX) //NEEDS PURCHASE $0
        addAudioItem("speechbubble", category: .soundFX) //not purchased $2
        addAudioItem("swordparry", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("swordslash", category: .soundFX)
        addAudioItem("swordthrow", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("swordthud", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("touchstatue", category: .soundFX)
        addAudioItem("thunderrumble", category: .soundFX)
        
        
        //FINAL BATTLE SCENE 2 SFX
        addAudioItem("villainattack1", category: .soundFX) //NEEDS PURCHASE $2
        addAudioItem("villainattack2", category: .soundFX) //NEEDS PURCHASE $2
        addAudioItem("villainattack3", category: .soundFX) //NEEDS PURCHASE $2
        addAudioItem("villainattackbombtick", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("villainattackbombticklarge", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("villainattackspecialbomb", category: .soundFX) //NEEDS PURCHASE $3
        addAudioItem("villainattackwand", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("villaindead", category: .soundFX) //NEEDS PURCHASE $2
        addAudioItem("villainpain1", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("villainpain2", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("villainpain3", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("gameendlose", category: .soundFX)
        addAudioItem("gameendwin1", category: .soundFX)
        addAudioItem("gameendwin2", category: .soundFXLoop)

        
        addAudioItem("warp", category: .soundFX)
        addAudioItem("waterappear1", category: .soundFX) //not purchased $3
        addAudioItem("waterappear2", category: .soundFX)
        addAudioItem("waterappear3", category: .soundFX)
        addAudioItem("waterdrown", category: .soundFX)
        addAudioItem("winlevel", category: .soundFX)
        addAudioItem("winlevelageofruin", category: .soundFX)
        addAudioItem("winlevel3stars", category: .soundFX)
        addAudioItem("ydooropen", category: .soundFX) //NEEDS PURCHASE $1
        addAudioItem("zdooropen", category: .soundFX) //TEST FOR FUN ONLY

        
        //Looped SFX
        addAudioItem("clocktick", category: .soundFXLoop)
        addAudioItem("littlegirllaugh", category: .soundFXLoop)
        addAudioItem("magicdoomloop", category: .soundFXLoop)
        addAudioItem("magmoorcreepystrings", category: .soundFXLoop)
        addAudioItem("shieldpulse", category: .soundFXLoop) //NEEDS PURCHASE $1

        
        //No Loop music
        addAudioItem("ageofruin", category: .musicNoLoop)
        addAudioItem("ageofruin2", category: .musicNoLoop)
        addAudioItem("bossbattle1", category: .musicNoLoop)
        addAudioItem("gameover", category: .musicNoLoop)
        addAudioItem("gameoverageofruin", category: .musicNoLoop)
        addAudioItem("titlechapter", category: .musicNoLoop)
        addAudioItem("titletheme", category: .musicNoLoop)
        addAudioItem("titlethemeageofruin", category: .musicNoLoop)

        
        //Background music
        addAudioItem("birdsambience", category: .music, maxVolume: 0.2)
        addAudioItem("bossbattle0", category: .music)
        addAudioItem("bossbattle2", category: .music)
        addAudioItem("bossbattle3", category: .music)
        addAudioItem("continueloop", category: .music)
        addAudioItem("magicheartbeatloop1", category: .music)
        addAudioItem("magicheartbeatloop2", category: .music)
        addAudioItem("magmoorcreepypulse", category: .music)
        addAudioItem("overworld", category: .music)
        addAudioItem("overworldageofruin", category: .music)
        addAudioItem("overworldgrassland", category: .music)
        addAudioItem("overworldmarimba", category: .music)
        addAudioItem("overworldparty", category: .music)
        addAudioItem("scarymusicbox", category: .music)
    }
    
    /**
     Adds a sound file to the AudioItems dictionary.
     - parameters:
        - audioKey: The key and filename to add to the dictionary
        - category: The AudioCategory of the sound being added
        - maxVolume: The maximum volume to set, defaults to 1.0
     */
    private func addAudioItem(_ audioKey: String, category: AudioItem.AudioCategory, maxVolume: Float = 1.0) {
        let item = AudioItem(fileName: audioKey, category: category, maxVolume: maxVolume)
        item.initializePlayer()
        
        audioItems[audioKey] = item
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (delay ?? 0)) {
            //No need to make completions inside DispatchQueue.main.asyncAfter weak!
            
            //For debugging. Uncomment this to see if audio is being interrupted by playing it while it's already playing 3/1/25
            if item.player.isPlaying {
                print("WARNING: Attempting to play audio \(audioKey) while it is already playing!")
            }
            
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration) {
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + playForDuration + (delay ?? 0)) {
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
