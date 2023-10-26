//
//  LeaderboardsTableView.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/22/23.
//

import UIKit

class LeaderboardsTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    var scores: [GameCenterManager.Score] = []
    
    
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
        return scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardsTVCell.reuseID, for: indexPath) as? LeaderboardsTVCell else {
            return UITableViewCell()
        }
        
        cell.setViews(level: scores[indexPath.row].level, 
                      username: scores[indexPath.row].username,
                      score: scores[indexPath.row].score,
                      isLocalPlayer: scores[indexPath.row].isLocalPlayer)

        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIDevice.isiPad ? 44 : 34
    }
    
    
}
