//
//  ProgressHUDManager.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/12/25.
//

import SpriteKit

class ProgressHUDManager {
    
    // MARK: - Properties
    
    private var progressBars: [CircularProgressBar?]
    
    enum ProgressBarType: Int {
        case sword2x, sword3x, swordInf, wingedboot, shield
    }
    
    enum ProgressBarAlignment {
        case left, center, right
    }
    
    
    // MARK: - Initialization
    
    init() {
        progressBars = [nil, nil, nil, nil, nil]
    }
    
    deinit {
        for progressBar in progressBars {
            progressBar?.stopTimer()
        }
        
        progressBars = [nil, nil, nil, nil, nil]
        progressBars = []
        
        print("deinit ProgressHUDManager")
    }
    
    
    // MARK: - Functions
    
    func setTimer(for progressBarType: ProgressBarType) {
        if progressBars[progressBarType.rawValue] == nil {
            let image: String
            let multiplier: Int
            let multiplierColor: UIColor
            let multiplierAlpha: CGFloat
            let timerIncrement: TimeInterval
            let maxTimerIncrement: TimeInterval
            let notificationNames: CircularProgressBar.NotificationNames?
            
            switch progressBarType {
            case .sword2x:
                image = ChosenSword(type: FIRManager.chosenSword).imageName
                multiplier = 2
                multiplierColor = .yellow
                multiplierAlpha = 1
                timerIncrement = 60
                notificationNames = (.didSword2xTimerInitialize, .didSword2xTimerExpire)
            case .sword3x:
                image = ChosenSword(type: FIRManager.chosenSword).imageName
                multiplier = 3
                multiplierColor = .cyan
                multiplierAlpha = 1
                timerIncrement = 50
                notificationNames = (.didSword3xTimerInitialize, .didSword3xTimerExpire)
            case .swordInf:
                image = ChosenSword(type: FIRManager.chosenSword).imageName
                multiplier = Int(ChosenSword.infiniteMultiplier)
                multiplierColor = .white
                multiplierAlpha = 1
                timerIncrement = 20
                notificationNames = (.didSwordInfTimerInitialize, .didSwordInfTimerExpire)
            case .wingedboot:
                image = "wingedboot"
                multiplier = 1
                multiplierColor = .white
                multiplierAlpha = 0
                timerIncrement = 40
                notificationNames = (.didBootTimerInitialize, .didBootTimerExpire)
            case .shield:
                image = "shield"
                multiplier = 1
                multiplierColor = .white
                multiplierAlpha = 0
                timerIncrement = 30
                notificationNames = (.didShieldTimerInitialize, .didShieldTimerExpire)
            }
            
            maxTimerIncrement = 3 * timerIncrement
            
            progressBars[progressBarType.rawValue] = CircularProgressBar(image: image,
                                                                         multiplier: multiplier,
                                                                         multiplierColor: multiplierColor,
                                                                         multiplierAlpha: multiplierAlpha,
                                                                         timerIncrement: timerIncrement,
                                                                         maxTimerIncrement: maxTimerIncrement,
                                                                         notificationNames: notificationNames)
            
            progressBars[progressBarType.rawValue]?.zPosition = K.ZPosition.itemsPoints
        }
        
        progressBars[progressBarType.rawValue]?.setTimer()
    }
    
    func updateTimers() {
        for progressBar in progressBars {
            guard let progressBar = progressBar else { continue }
            
            progressBar.updateRemainingTime()
        }
        
        let bar8 = progressBars[ProgressBarType.swordInf.rawValue]
        let bar3 = progressBars[ProgressBarType.sword3x.rawValue]
        let bar2 = progressBars[ProgressBarType.sword2x.rawValue]
        
        if bar8?.isRunning ?? false {
            bar8?.showProgressBar(shouldPulseMultiplier: !(bar8?.isShowing ?? true))
            bar3?.hideProgressBar()
            bar2?.hideProgressBar()
        }
        else if bar3?.isRunning ?? false {
            bar8?.hideProgressBar()
            bar3?.showProgressBar(shouldPulseMultiplier: !(bar3?.isShowing ?? true))
            bar2?.hideProgressBar()
        }
        else if bar2?.isRunning ?? false {
            bar8?.hideProgressBar()
            bar3?.hideProgressBar()
            bar2?.showProgressBar(shouldPulseMultiplier: !(bar2?.isShowing ?? true))
        }
    }
    
    func displayProgressBars(on node: SKNode, at position: CGPoint) {
        for (index, progressBar) in progressBars.enumerated() {
            guard let progressBar = progressBar, progressBar.parent == nil else { continue }
            
            let offset: CGFloat = CircularProgressBar.radius + CircularProgressBar.lineWidth / 2
            
            switch index {
            case ProgressBarType.sword2x.rawValue, ProgressBarType.sword3x.rawValue, ProgressBarType.swordInf.rawValue:
                progressBar.position = position + offset
            case ProgressBarType.wingedboot.rawValue:
                progressBar.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: position.y + offset)
            case ProgressBarType.shield.rawValue:
                progressBar.position = CGPoint(x: K.ScreenDimensions.size.width - position.x - offset, y: position.y + offset)
            default:
                progressBar.position = position - offset
            }
            
            node.addChild(progressBar)
        }
    }
    
    
}
