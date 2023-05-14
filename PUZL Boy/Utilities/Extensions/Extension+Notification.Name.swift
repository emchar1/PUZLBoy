//
//  Extension+Notification.Name.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/18/22.
//

import Foundation

extension Notification.Name {
    static let presentGame = Notification.Name(rawValue: "presentGame")
    static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")
    static let iapHelperPurchaseNotification = Notification.Name("iapHelperPurchaseNotification")
    static let showMailCompose = Notification.Name(rawValue: "showMailCompose")
}
