//
//  LeaderboardsTableView.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/22/23.
//

import UIKit

protocol LeaderboardsTableViewDelegate: AnyObject {
    func didTapRow(scoreEntry: GameCenterManager.Score)
}

class LeaderboardsTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    // Public Properties
    var scores: [GameCenterManager.Score] = []
    var leaderboardType: LeaderboardsPage.LeaderboardType!
    weak var leaderboardsTableViewDelegate: LeaderboardsTableViewDelegate?
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        backgroundColor = .clear
        separatorStyle = .none

        delegate = self
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Table View Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(scores.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardsTVCell.reuseID, for: indexPath) as? LeaderboardsTVCell else {
            return UITableViewCell()
        }
        
        if scores.count == 0 {
            cell.setViewsNoData()
        }
        else {
            cell.setViews(level: scores[indexPath.row].level,
                          username: scores[indexPath.row].username,
                          score: scores[indexPath.row].score,
                          isLocalPlayer: scores[indexPath.row].isLocalPlayer)
        }

        if leaderboardType == .level {
            cell.selectionStyle = .none
        }
        else {
            let selectionBackgroundView = UIView()
            selectionBackgroundView.backgroundColor = DayTheme.skyColor.top.lightenColor(factor: 6)

            cell.selectedBackgroundView = selectionBackgroundView
            cell.selectionStyle = .default
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIDevice.isiPad ? 52 : 38
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard leaderboardType == .all else { return }
        
        leaderboardsTableViewDelegate?.didTapRow(scoreEntry: scores[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
