//
//  DuplicateItemTimerManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/20/25.
//

import Foundation

protocol DuplicateItemTimerManagerDelegate: AnyObject {
    func didInitializeSword2x(_ manager: DuplicateItemTimerManager)
    func didExpireSword2x(_ manager: DuplicateItemTimerManager)
    func didInitializeSword3x(_ manager: DuplicateItemTimerManager)
    func didExpireSword3x(_ manager: DuplicateItemTimerManager)
    func didInitializeSword8(_ manager: DuplicateItemTimerManager)
    func didExpireSword8(_ manager: DuplicateItemTimerManager)
    func didInitializeBoot(_ manager: DuplicateItemTimerManager)
    func didExpireBoot(_ manager: DuplicateItemTimerManager)
    func didInitializeShield(_ manager: DuplicateItemTimerManager)
    func didExpireShield(_ manager: DuplicateItemTimerManager)
}

class DuplicateItemTimerManager {
    
    // MARK: - Properties
    
    private(set) var isRunningSword2x: Bool = false
    private(set) var isRunningSword3x: Bool = false
    private(set) var isRunningSword8: Bool = false
    private(set) var isRunningBoot: Bool = false
    private(set) var isRunningShield: Bool = false
    
    weak var delegate: DuplicateItemTimerManagerDelegate?
    
    
    // MARK: - Initialization
    
    init() {
        //Custom initialization, if needed
    }
    
    deinit {
        print("deinit DuplicateItemTimerManager")
    }
    
    func addObserver(_ observer: Any) {
        let observer = self
        NotificationCenter.default.addObserver(observer, selector: #selector(initializedSword2x), name: .didSword2xTimerInitialize, object: nil)
        NotificationCenter.default.addObserver(observer, selector: #selector(expiredSword2x), name: .didSword2xTimerExpire, object: nil)
        NotificationCenter.default.addObserver(observer, selector: #selector(initializedSword3x), name: .didSword3xTimerInitialize, object: nil)
        NotificationCenter.default.addObserver(observer, selector: #selector(expiredSword3x), name: .didSword3xTimerExpire, object: nil)
        NotificationCenter.default.addObserver(observer, selector: #selector(initializedSword8), name: .didSwordInfTimerInitialize, object: nil)
        NotificationCenter.default.addObserver(observer, selector: #selector(expiredSword8), name: .didSwordInfTimerExpire, object: nil)
        NotificationCenter.default.addObserver(observer, selector: #selector(initializedBoot), name: .didBootTimerInitialize, object: nil)
        NotificationCenter.default.addObserver(observer, selector: #selector(expiredBoot), name: .didBootTimerExpire, object: nil)
        NotificationCenter.default.addObserver(observer, selector: #selector(initializedShield), name: .didShieldTimerInitialize, object: nil)
        NotificationCenter.default.addObserver(observer, selector: #selector(expiredShield), name: .didShieldTimerExpire, object: nil)
    }
    
    
    // MARK: - Functions
    
    @objc private func initializedSword2x() {
        isRunningSword2x = true
        delegate?.didInitializeSword2x(self)
    }
    
    @objc private func expiredSword2x() {
        isRunningSword2x = false
        delegate?.didExpireSword2x(self)
    }
    
    @objc private func initializedSword3x() {
        isRunningSword3x = true
        delegate?.didInitializeSword3x(self)
    }
    
    @objc private func expiredSword3x() {
        isRunningSword3x = false
        delegate?.didExpireSword3x(self)
    }
    
    @objc private func initializedSword8() {
        isRunningSword8 = true
        delegate?.didInitializeSword8(self)
    }
    
    @objc private func expiredSword8() {
        isRunningSword8 = false
        delegate?.didExpireSword8(self)
    }
    
    @objc private func initializedBoot() {
        isRunningBoot = true
        delegate?.didInitializeBoot(self)
    }
    
    @objc private func expiredBoot() {
        isRunningBoot = false
        delegate?.didExpireBoot(self)
    }
    
    @objc private func initializedShield() {
        isRunningShield = true
        delegate?.didInitializeShield(self)
    }
    
    @objc private func expiredShield() {
        isRunningShield = false
        delegate?.didExpireShield(self)
    }

}
