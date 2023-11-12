//
//  LeaderboardsTVCell.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/22/23.
//

import UIKit

class LeaderboardsTVCell: UITableViewCell {
    
    // MARK: - Properties
    
    class var reuseID: String { "LeaderboardsCell" }
    class var padding: CGFloat { 8 }
    
    private var hStack: UIStackView!
    private var levelLabel: UILabel!
    private var usernameLabel: UILabel!
    private var scoreLabel: UILabel!
    
    private var leftCellConstraint: NSLayoutConstraint!
    private var rightCellConstraint: NSLayoutConstraint!
    private let leftConstant: CGFloat = UIDevice.isiPad ? 60 : 40
    private let rightConstant: CGFloat = UIDevice.isiPad ? 120 : 80
    
    
    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.spacing = 4
        hStack.translatesAutoresizingMaskIntoConstraints = false
                
        levelLabel = UILabel()
        levelLabel.font = UIFont(name: UIFont.chatFont, size: UIDevice.isiPad ? 30 : 18)
        levelLabel.textColor = UIFont.chatFontColor
        levelLabel.layer.shadowColor = UIColor.black.cgColor
        levelLabel.layer.shadowOffset = CGSize(width: -1, height: 1)
        levelLabel.layer.shadowRadius = 0
        levelLabel.layer.shadowOpacity = 0.25
        levelLabel.layer.masksToBounds = false
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        
        usernameLabel = UILabel()
        usernameLabel.font = UIFont(name: UIFont.chatFont, size: UIDevice.isiPad ? 30 : 18)
        usernameLabel.textColor = UIFont.chatFontColor
        usernameLabel.layer.shadowColor = UIColor.black.cgColor
        usernameLabel.layer.shadowOffset = CGSize(width: -1, height: 1)
        usernameLabel.layer.shadowRadius = 0
        usernameLabel.layer.shadowOpacity = 0.25
        usernameLabel.layer.masksToBounds = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scoreLabel = UILabel()
        scoreLabel.font = UIFont(name: UIFont.chatFont, size: UIDevice.isiPad ? 30 : 18)
        scoreLabel.textColor = UIFont.chatFontColor
        scoreLabel.textAlignment = .right
        scoreLabel.layer.shadowColor = UIColor.black.cgColor
        scoreLabel.layer.shadowOffset = CGSize(width: -1, height: 1)
        scoreLabel.layer.shadowRadius = 0
        scoreLabel.layer.shadowOpacity = 0.25
        scoreLabel.layer.masksToBounds = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .clear
    }
    
    private func layoutViews() {
        addSubview(hStack)
        hStack.addArrangedSubview(levelLabel)
        hStack.addArrangedSubview(usernameLabel)
        hStack.addArrangedSubview(scoreLabel)
        
        leftCellConstraint = hStack.arrangedSubviews[0].widthAnchor.constraint(equalToConstant: leftConstant)
        rightCellConstraint = hStack.arrangedSubviews[2].widthAnchor.constraint(equalToConstant: rightConstant)

        
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: LeaderboardsTVCell.padding),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LeaderboardsTVCell.padding),
            trailingAnchor.constraint(equalTo: hStack.trailingAnchor, constant: LeaderboardsTVCell.padding),
            bottomAnchor.constraint(equalTo: hStack.bottomAnchor, constant: LeaderboardsTVCell.padding),

            leftCellConstraint,
            rightCellConstraint,

            levelLabel.centerYAnchor.constraint(equalTo: hStack.arrangedSubviews[0].centerYAnchor, constant: 0),
            levelLabel.leadingAnchor.constraint(equalTo: hStack.arrangedSubviews[0].leadingAnchor, constant: 0),
            hStack.arrangedSubviews[0].trailingAnchor.constraint(equalTo: levelLabel.trailingAnchor, constant: 0),

            usernameLabel.centerYAnchor.constraint(equalTo: hStack.arrangedSubviews[1].centerYAnchor, constant: 0),
            usernameLabel.leadingAnchor.constraint(equalTo: hStack.arrangedSubviews[1].leadingAnchor, constant: 0),
            hStack.arrangedSubviews[1].trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor, constant: 0),

            scoreLabel.centerYAnchor.constraint(equalTo: hStack.arrangedSubviews[2].centerYAnchor, constant: 0),
            scoreLabel.leadingAnchor.constraint(equalTo: hStack.arrangedSubviews[2].leadingAnchor, constant: 0),
            hStack.arrangedSubviews[2].trailingAnchor.constraint(equalTo: scoreLabel.trailingAnchor, constant: 0)
        ])
    }
    
    
    // MARK: - Functions
    
    func setViews(level: Int, username: String?, score: Int?, isLocalPlayer: Bool?) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        usernameLabel.textAlignment = .left
        leftCellConstraint.constant = leftConstant
        rightCellConstraint.constant = rightConstant

        levelLabel.text = "\(level)"

        if let username = username, let isLocalPlayer = isLocalPlayer {
            usernameLabel.text = (isLocalPlayer ? "🏆 " : "") + username
        }
        else {
            usernameLabel.text = "-"
        }
            
        if let score = score {
            scoreLabel.text = numberFormatter.string(from: NSNumber(value: score))
        }
        else {
            scoreLabel.text = "-"
        }
    }
    
    func setViewsNoData() {
        usernameLabel.textAlignment = .center
        leftCellConstraint.constant = 0
        rightCellConstraint.constant = 0

        levelLabel.text = ""
        usernameLabel.text = "No Data!"
        scoreLabel.text = ""
    }
}
