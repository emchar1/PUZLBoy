//
//  LifeSpawnerModel.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/12/23.
//

import UserNotifications

class LifeSpawnerModel {

    // MARK: - Properties
    
    static let defaultLives = 5
    static let durationMoreLives: TimeInterval = 30 * 60
    static let durationReminder: TimeInterval = 24 * 60 * 60
    static let playPUZLBoy = "Play PUZL Boy now!"
    
    static var shared: LifeSpawnerModel {
        let model = LifeSpawnerModel()
        
        //add'l setup, if needed
        
        return model
    }

    static var funnyQuotes: [String] = [
        "These puzzles aren't going to solve themselves. " + playPUZLBoy,
        "Need a break? " + playPUZLBoy,
        "Expand your cranium. " + playPUZLBoy,
        "Flex that brain. " + playPUZLBoy,
        "Take a 10 minute break from your day. " + playPUZLBoy,
        "Visit 5playapps.com and download our other exciting mobile apps!"
    ]
    
    enum NotificationTimerError: Error {
        case timerNotSaved
    }
    
    
    // MARK: - Initialization
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                //Granted
            }
            else {
                print("Notifications have been denied :(")
            }
        }
        
    }
    
    
    // MARK: - Notification Functions
    
    /**
     Triggers a Notification message to the device after a certain amount of time has elapsed, i.e. to keep playing.
     - parameters:
        - title: the title of the Notification
        - duration: amount of time required before the Notification is triggered
        - repeats: determines if Notification should trigger repeatedly or not
     */
    func scheduleNotification(title: String, duration: TimeInterval, repeats: Bool) {
        let content = UNMutableNotificationContent()
        let funnyQuote = LifeSpawnerModel.funnyQuotes.randomElement()
        content.title = title
        content.body = funnyQuote ?? LifeSpawnerModel.playPUZLBoy
        content.categoryIdentifier = "alert"
        content.sound = .none
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: repeats ? max(60, duration) : duration, repeats: repeats)
        let request = UNNotificationRequest.init(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /**
     Just like the function says - it removes/cancels all delivered and pending Notifications.
     */
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    
    // MARK: - Timer Functions
    
    /**
     Sets the savedTime key in UserDefaults.
     */
    func setTimer() {
        print("Timer set! All systems go!")
        UserDefaults.standard.set(Date(), forKey: K.UserDefaults.savedTime)
    }
    
    /**
     Adds time to the current timer in play.
     - parameter timeInSeconds: the time to add to the existing timer
     */
    func updateTimer(add timeInSeconds: TimeInterval) {
        let savedTime = UserDefaults.standard.object(forKey: K.UserDefaults.savedTime) as? Date ?? Date()
        let updatedTime = savedTime.addingTimeInterval(timeInSeconds)
        
        UserDefaults.standard.set(updatedTime, forKey: K.UserDefaults.savedTime)
    }
    
    /**
     Removes the existing timer in UserDefaults. Usually runs concurrent with removeAllNotifications().
     */
    func removeTimer() {
        UserDefaults.standard.set(nil, forKey: K.UserDefaults.savedTime)
    }
    
    /**
     Returns the remaining time left in the UserDefaults savedTime key.
        - returns: the remaining time left on the timer in question
     */
    func getTimeToFinishUntilMoreLives() throws -> TimeInterval {
        guard let savedTime = UserDefaults.standard.object(forKey: K.UserDefaults.savedTime) as? Date else {
            throw NotificationTimerError.timerNotSaved
        }

        let checkTime = Date(timeIntervalSinceNow: -LifeSpawnerModel.durationMoreLives)

        return savedTime.timeIntervalSinceReferenceDate - checkTime.timeIntervalSinceReferenceDate
    }
    
    /**
     I created this method for those users that try to break the game by cancelling the Continue Menu from appearing, thus causing the coundown timer to never initiate... I feel like this is a bandaid, because the class that uses this class isn't set up properly...
     */
    func setTimerIfNotSet() -> Bool {
        if UserDefaults.standard.object(forKey: K.UserDefaults.savedTime) as? Date == nil {
            setTimer()
            return true
        }
        
        return false
    }
    
}
