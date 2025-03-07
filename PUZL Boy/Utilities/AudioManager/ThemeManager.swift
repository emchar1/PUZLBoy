//
//  ThemeManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/6/25.
//

enum ThemeManager {
    
    // MARK: - Properties
    
    static var currentTheme: Theme = mainTheme
    static var mainTheme: Theme { !AgeOfRuin.isActive ? .ageOfBalance : .ageOfRuin }
    
    enum Theme {
        case ageOfBalance, ageOfRuin, party, tiki
    }
    
    enum Sound {
        case overworld, win, lose, title
    }
    
    private static let audioMap: [Theme: [Sound: String]] = [
        .ageOfBalance: [
            .overworld:     "overworld",
            .win:           "winlevel",
            .lose:          "gameover",
            .title:         "titletheme"
        ],
        .ageOfRuin: [
            .overworld:     "overworldageofruin",
            .win:           "winlevelageofruin",
            .lose:          "gameoverageofruin",
            .title:         "titlethemeageofruin"
        ],
        .party: [
            .overworld:     "overworldparty",
            .win:           "winlevel",
            .lose:          "gameover",
            .title:         "titletheme"
        ],
        .tiki: [
            .overworld:     "overworldmarimba",
            .win:           "winlevel",
            .lose:          "gameover",
            .title:         "titletheme"
        ]
    ]
    
    
    // MARK: - Functions
    
    /**
     Stops the current overworld theme and changes the current theme to a new theme.
     - parameters:
        - newTheme: the new theme to change to.
        - shouldPlayNewTheme: plays the new theme's overworld, if true.
     */
    static func changeTheme(to newTheme: Theme, shouldPlayNewTheme: Bool) {
        //Need to forceStop = true here because AudioItem is now a class (reference type). Otherwise, sound doesn't stop properly 3/5/25.
        AudioManager.shared.stopSound(for: getCurrentThemeAudio(sound: .overworld), forceStop: true)
        
        currentTheme = newTheme
        
        if shouldPlayNewTheme {
            AudioManager.shared.playSound(for: getCurrentThemeAudio(sound: .overworld))
        }
    }
    
    /**
     Convenience function for getAudio(). Returns the audio file name for the currentThem, given the sound type.
     - parameter sound: the type of sound to return
     - returns: the audio filename
     */
    static func getCurrentThemeAudio(sound: Sound) -> String {
        getAudio(theme: currentTheme, sound: sound)
    }
    
    /**
     Returns the audio file name, given the theme and sound type.
     - parameters:
        - theme: the theme for which to obtain the sound file
        - sound: the type of sound to return
     - returns: the audio filename
     */
    static func getAudio(theme: Theme, sound: Sound) -> String {
        guard let audioFile = audioMap[theme]?[sound] else {
            assertionFailure("ThemeManager missing sound file for: \(theme) - \(sound).")
            return "boydead"
        }
        
        return audioFile
    }
    
    
}
