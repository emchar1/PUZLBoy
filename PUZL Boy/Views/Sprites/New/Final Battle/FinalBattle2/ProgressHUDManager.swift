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
        case sword2x, sword3x, wingedboot
    }
    
    enum ProgressBarAlignment {
        case left, center, right
    }
    
    
    // MARK: - Initialization
    
    init() {
        progressBars = [nil, nil, nil]
    }
    
    deinit {
        progressBars = [nil, nil, nil]
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
            let notificationNames: CircularProgressBar.NotificationNames
            
            switch progressBarType {
            case .sword2x:
                image = ChosenSword(type: FIRManager.chosenSword).imageName
                multiplier = 2
                multiplierColor = .yellow
                multiplierAlpha = 1
                timerIncrement = 60
                maxTimerIncrement = 180
                notificationNames = (.didSword2xTimerInitialize, .didSword2xTimerExpire)
            case .sword3x:
                image = ChosenSword(type: FIRManager.chosenSword).imageName
                multiplier = 3
                multiplierColor = .cyan
                multiplierAlpha = 1
                timerIncrement = 50
                maxTimerIncrement = 150
                notificationNames = (.didSword3xTimerInitialize, .didSword3xTimerExpire)
            case .wingedboot:
                image = "wingedboot"
                multiplier = 1
                multiplierColor = .white
                multiplierAlpha = 0
                timerIncrement = 60
                maxTimerIncrement = 180
                notificationNames = (.didBootTimerInitialize, .didBootTimerExpire)
            }
            
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
        
        guard let progressBar3x = progressBars[ProgressBarType.sword3x.rawValue],
              let progressBar2x = progressBars[ProgressBarType.sword2x.rawValue] else { return }
        
        // FIXME: - Test this logic!!! It looks confusing...
        if progressBar3x.hasTimeRemaining && !progressBar2x.hasBeenHidden {
            progressBar3x.showProgressBar(shouldPulseMultiplier: true)
            progressBar2x.hideProgressBar()
        }
        else if (progressBar2x.hasTimeRemaining && progressBar2x.hasBeenHidden) && (!progressBar3x.hasTimeRemaining && !progressBar3x.hasBeenHidden) {
            progressBar3x.hideProgressBar()
            progressBar2x.showProgressBar(shouldPulseMultiplier: true)
        }
    }
    
    func displayProgressBars(on node: SKNode, at position: CGPoint) {
        for (index, progressBar) in progressBars.enumerated() {
            guard let progressBar = progressBar, progressBar.parent == nil else { continue }
            
            let offset: CGFloat = CircularProgressBar.radius + CircularProgressBar.lineWidth / 2
            
            switch index {
            case ProgressBarType.sword2x.rawValue, ProgressBarType.sword3x.rawValue:
                progressBar.position = CGPoint(x: position.x + offset, y: position.y + offset)
            case ProgressBarType.wingedboot.rawValue:
                progressBar.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: position.y + offset)
            default:
                progressBar.position = CGPoint(x: K.ScreenDimensions.size.width - position.x - offset, y: position.y + offset)
            }
            
            node.addChild(progressBar)
        }
    }
    
    
}
