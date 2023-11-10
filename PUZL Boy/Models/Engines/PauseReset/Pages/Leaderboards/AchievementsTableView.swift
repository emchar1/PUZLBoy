//
//  AchievementsTableView.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/8/23.
//

import UIKit

class AchievementsTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    
    private let sectionInProgress = 0
    private let sectionCompleted = 1
    private var achievementsInProgress: [AchievementsModel] = []
    private var achievementsCompleted: [AchievementsModel] = []

    
    // MARK: - Initialization
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        backgroundColor = .clear
        separatorStyle = .none

        delegate = self
        dataSource = self
        
        loadAchievements(completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadAchievements(completion: (() -> Void)?) {
        achievementsInProgress = []
        achievementsCompleted = []
        
        GameCenterManager.shared.loadAchievements { [unowned self] achievements, achievementDescriptions in
            for i in 0..<achievementDescriptions.count {
                let achievementFound = achievements.filter { $0.identifier == achievementDescriptions[i].identifier }.first
                let percentComplete = Int(achievementFound?.percentComplete ?? 0.0)
                let isCompleted = achievementFound?.isCompleted ?? false
                let completionDate = achievementFound?.lastReportedDate ?? nil
                
                let achievement = AchievementsModel(identifier: achievementDescriptions[i].identifier,
                                                    title: achievementDescriptions[i].title,
                                                    descriptionCompleted: achievementDescriptions[i].achievedDescription,
                                                    descriptionNotCompleted: achievementDescriptions[i].unachievedDescription,
                                                    isHidden: achievementDescriptions[i].isHidden,
                                                    percentComplete: percentComplete,
                                                    isCompleted: isCompleted,
                                                    completionDate: completionDate)
                
                if achievementFound != nil && achievementFound!.isCompleted {
                    achievementsCompleted.append(achievement)
                }
                else {
                    achievementsInProgress.append(achievement)
                }
            }
            
            completion?()
        }
    }
    
    
    // MARK: - Table View Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        var fontSize: CGFloat = UIDevice.isiPad ? 36 : 24
        
        switch section {
        case sectionInProgress: fontSize = achievementsInProgress.count > 0 ? fontSize : 0
        case sectionCompleted: fontSize = achievementsCompleted.count >  0 ? fontSize : 0
        default: break
        }
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: UIFont.gameFont, size: fontSize)
        header.textLabel?.textColor = .cyan
        header.textLabel?.layer.shadowColor = UIColor.black.cgColor
        header.textLabel?.layer.shadowOffset = CGSize(width: -1.5, height: 1.5)
        header.textLabel?.layer.shadowRadius = 0
        header.textLabel?.layer.shadowOpacity = 0.25
        header.sizeToFit()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let totalAchievements = achievementsInProgress.count + achievementsCompleted.count
        
        switch section {
        case sectionInProgress: return "IN PROGRESS (\(achievementsInProgress.count)/\(totalAchievements))"
        case sectionCompleted: return "COMPLETED (\(achievementsCompleted.count)/\(totalAchievements))"
        default: return ""
        }
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case sectionInProgress: return achievementsInProgress.count
        case sectionCompleted: return achievementsCompleted.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AchievementsTVCell.reuseID, for: indexPath) as? AchievementsTVCell else {
            return UITableViewCell()
        }
        
        var item: AchievementsModel
        
        switch indexPath.section {
        case sectionInProgress:
            item = achievementsInProgress[indexPath.row]
        case sectionCompleted:
            item = achievementsCompleted[indexPath.row]
        default: 
            //Dummy value
            item = AchievementsModel(identifier: "N/A",
                                     title: "N/A",
                                     descriptionCompleted: "N/A",
                                     descriptionNotCompleted: "N/A",
                                     isHidden: false,
                                     percentComplete: 0,
                                     isCompleted: false,
                                     completionDate: nil)
        }
        
        cell.setViews(achievement: item)
        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerHeight: CGFloat = UIDevice.isiPad ? 80 : 60
        
        switch section {
        case sectionInProgress:
            return achievementsInProgress.count > 0 ? headerHeight : 0
        case sectionCompleted:
            return achievementsCompleted.count > 0 ? headerHeight : 0
        default:
            return headerHeight
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowHeight: CGFloat = AchievementsTVCell.imageSize + 2 * AchievementsTVCell.padding

        switch indexPath.section {
        case sectionInProgress:
            return achievementsInProgress.count > 0 ? rowHeight : 0
        case sectionCompleted:
            return achievementsCompleted.count > 0 ? rowHeight : 0
        default:
            return rowHeight
        }
    }
    
    
}
