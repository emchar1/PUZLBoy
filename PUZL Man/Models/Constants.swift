//
//  Constants.swift
//  PUZL Man
//
//  Created by Eddie Char on 10/2/22.
//

import Foundation

struct K {
    // 2048/1536 = 4/3 = 1.33333
    // 19.5/9 = 6.5/3 = 2.1666667
    // 2048/2.1666667 = 945
    //    (1536 - 945)/2 = 296

    static let width: CGFloat = 1536
    static let height: CGFloat = 2048
    static let ratio: CGFloat = width / height //1.333333
    static let iPhoneRatio: CGFloat = 19.5 / 9 //2.1666667
    static let iPhoneWidth: CGFloat = height / iPhoneRatio //945
    static let iPhoneMargin: CGFloat = (width - iPhoneWidth) / 2 //296
    static let topMargin: CGFloat = 180
    static let bottomMargin: CGFloat = 80
}
