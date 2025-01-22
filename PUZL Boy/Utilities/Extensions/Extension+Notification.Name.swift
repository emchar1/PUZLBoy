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
    
    static let presentGame = Notification.Name(rawValue: "presentGame")
    static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")
    static let iapHelperPurchaseNotification = Notification.Name("iapHelperPurchaseNotification")
    static let showMailCompose = Notification.Name(rawValue: "showMailCompose")
    static let didSendEmailFeedback = Notification.Name(rawValue: "didSendEmailFeedback")
    static let shareURL = Notification.Name(rawValue: "shareURL")
    static let shouldCancelLoadingLeaderboards = Notification.Name(rawValue: "shouldCancelLoadingLeaderboards")
    static let completeGameDidWin = Notification.Name(rawValue: "completeGameDidWin")
    static let completeGameDidLose = Notification.Name(rawValue: "completeGameDidLose")
}
