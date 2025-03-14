//
//  Extension+Notification.Name.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/18/22.
//

import Foundation

extension Notification.Name {
    //Continue adding notification names (identifiers) at the end, as you implement the Notification Observer Pattern Executer (NOPE). Then, setup:
    //   1. Have the posting class (giver) post a notification with this name
    //   2. Have the observing class (receiver) observe/listen for the notification and perform the #selector function accordingly.
    
    // Game Initialization
    static let presentGame = Notification.Name(rawValue: "presentGame")
    static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")
    static let iapHelperPurchaseNotification = Notification.Name("iapHelperPurchaseNotification")
    static let showMailCompose = Notification.Name(rawValue: "showMailCompose")
    static let didSendEmailFeedback = Notification.Name(rawValue: "didSendEmailFeedback")
    static let shareURL = Notification.Name(rawValue: "shareURL")
    static let shouldCancelLoadingLeaderboards = Notification.Name(rawValue: "shouldCancelLoadingLeaderboards")
    
    // Game Completion
    static let completeGameDidWin = Notification.Name(rawValue: "completeGameDidWin")
    static let completeGameDidLose = Notification.Name(rawValue: "completeGameDidLose")
    
    // Duplicate Item Timer
    static let didSword2xTimerInitialize = Notification.Name(rawValue: "sword2xTimerInitialized")
    static let didSword2xTimerExpire = Notification.Name(rawValue: "sword2xTimerExpired")
    static let didSword3xTimerInitialize = Notification.Name(rawValue: "sword3xTimerInitialized")
    static let didSword3xTimerExpire = Notification.Name(rawValue: "sword3xTimerExpired")
    static let didSwordInfTimerInitialize = Notification.Name(rawValue: "swordInfTimerInitialized")
    static let didSwordInfTimerExpire = Notification.Name(rawValue: "swordInfTimerExpired")
    static let didBootTimerInitialize = Notification.Name(rawValue: "bootTimerInitialized")
    static let didBootTimerExpire = Notification.Name(rawValue: "bootTimerExpired")
    static let didShieldTimerInitialize = Notification.Name(rawValue: "shieldTimerInitialized")
    static let didShieldTimerExpire = Notification.Name(rawValue: "shieldTimerExpired")
}
