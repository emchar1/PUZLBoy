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
    
    static var shared: LifeSpawnerModel {
        let model = LifeSpawnerModel()
        
        //add'l setup, if needed
        
        return model
    }
    
    private let center: UNUserNotificationCenter

    static var funnyQuotes: [String] = [
        "These puzzles aren't going to solve themselves.",
        "Need a break?",
        "Expand your cranium.",
        "Flex that brain.",
        "Take a 10 minute break from your day."
    ]
    
    enum NotificationTimerError: Error {
        case timerNotSaved
    }
    
    
    // MARK: - Initialization
    
    init() {
        center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                //Granted
            }
            else {
                print("Notifications have been denied :(")
            }
        }
        
    }
    
    
    // MARK: - Notification Functions
    
    func scheduleNotification(title: String, duration: TimeInterval, repeats: Bool) {
        let content = UNMutableNotificationContent()
        let funnyQuote = LifeSpawnerModel.funnyQuotes.randomElement()
        content.title = title
        content.body = (funnyQuote == nil ? "" : funnyQuote! + " ") + "Play PUZL Boy now!"
        content.categoryIdentifier = "alert"
        content.sound = .none
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: repeats ? max(60, duration) : duration, repeats: repeats)
        let request = UNNotificationRequest.init(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func removeAllNotifications() {
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }
    
    
    // MARK: - Timer Functions
    
    func setTimer() {
        print("Timer set! All systems go!")
        UserDefaults.standard.set(Date(), forKey: K.UserDefaults.savedTime)
    }
    
    func updateTimer(add timeInSeconds: TimeInterval) {
        let savedTime = UserDefaults.standard.object(forKey: K.UserDefaults.savedTime) as? Date ?? Date()
        let updatedTime = savedTime.addingTimeInterval(timeInSeconds)
        
        UserDefaults.standard.set(updatedTime, forKey: K.UserDefaults.savedTime)
    }
    
    func removeTimer() {
        UserDefaults.standard.set(nil, forKey: K.UserDefaults.savedTime)
    }
    
    func getTimeToFinish(finishTime: TimeInterval) throws -> TimeInterval {
        let checkTime = Date(timeIntervalSinceNow: -finishTime)
        let savedTime = UserDefaults.standard.object(forKey: K.UserDefaults.savedTime) as? Date
        
        guard let savedTime = savedTime else {
            throw NotificationTimerError.timerNotSaved
        }
        
        return savedTime.timeIntervalSinceReferenceDate - checkTime.timeIntervalSinceReferenceDate
    }
    
    ///I created this method for those users that try to break the game by cancelling the Continue Menu from appearing, thus causing the coundown timer to never initiate... I feel like this is a bandaid, because the class that uses this class isn't set up properly...
    func setTimerIfNotSet() -> Bool {
        if UserDefaults.standard.object(forKey: K.UserDefaults.savedTime) as? Date == nil {
            setTimer()
            return true
        }
        
        return false
    }
    
}
