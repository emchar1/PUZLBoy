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
        func makeLabel(textAlignment: NSTextAlignment = .left) -> UILabel {
            let label = UILabel()
            label.font = UIFont(name: UIFont.chatFont, size: UIDevice.isiPad ? 30 : 18)
            label.textColor = UIFont.chatFontColor
            label.textAlignment = textAlignment
            label.layer.shadowColor = UIColor.black.cgColor
            label.layer.shadowOffset = CGSize(width: -1, height: 1)
            label.layer.shadowRadius = 0
            label.layer.shadowOpacity = 0.25
            label.layer.masksToBounds = false
            label.translatesAutoresizingMaskIntoConstraints = false

            return label
        }
        
        hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.spacing = 4
        hStack.translatesAutoresizingMaskIntoConstraints = false
                
        levelLabel = makeLabel()
        usernameLabel = makeLabel()
        scoreLabel = makeLabel(textAlignment: .right)

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
