//
//  Extension+CGSize.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/14/23.
//

import Foundation

extension CGSize {
    //Standard
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func -(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    static func *(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }
    
    static func /(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }
    
    //LHS Scalar
    static func +(lhs: CGFloat, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs + rhs.width, height: lhs + rhs.height)
    }
    
    static func -(lhs: CGFloat, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs - rhs.width, height: lhs - rhs.height)
    }
    
    static func *(lhs: CGFloat, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs * rhs.width, height: lhs * rhs.height)
    }
    
    static func /(lhs: CGFloat, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs / rhs.width, height: lhs / rhs.height)
    }
    
    //RHS Scalar
    static func +(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width + rhs, height: lhs.height + rhs)
    }
    
    static func -(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width - rhs, height: lhs.height - rhs)
    }
    
    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
    static func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
    
}
