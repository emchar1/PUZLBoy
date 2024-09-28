//
//  Counter.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/26/24.
//

import Foundation

struct Counter {
    
    // MARK: - Properties
    
    let maxCount: CGFloat
    let step: CGFloat
    let shouldLoop: Bool
    
    private var count: CGFloat {
        didSet {
            if count > maxCount {
                count = shouldLoop ? 0 : maxCount
            }
            else if count < 0 {
                count = shouldLoop ? maxCount : 0
            }
        }
    }

    
    // MARK: - Initialization
    
    init(maxCount: CGFloat, step: CGFloat = 1, shouldLoop: Bool = true) {
        self.maxCount = maxCount
        self.step = step
        self.shouldLoop = shouldLoop

        self.count = 0
    }

    
    // MARK: - Functions
    
    mutating func reset() {
        count = 0
    }
    
    mutating func increment(by newValue: CGFloat? = nil) {
        count += newValue ?? step
    }
    
    mutating func decrement(by newValue: CGFloat? = nil) {
        count -= newValue ?? step
    }
    
    mutating func setCount(to newValue: CGFloat) {
        count = newValue
    }
    
    func getCount() -> CGFloat {
        return count
    }
    
}
