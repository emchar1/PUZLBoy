//
//  AchievementsTVCell.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/8/23.
//

import UIKit

class AchievementsTVCell: UITableViewCell {
    
    // MARK: - Properties
    
    class var reuseID: String { "AchievementsCell" }
    class var padding: CGFloat { UIDevice.isiPad ? 16 : 8 }
    class var imageSize: CGFloat { UIDevice.isiPad ? 154 : 88 }
    
    private var hStack: UIStackView!
    private var vStack: UIStackView!
    
    private var image: UIImageView!
    private var titleText: UILabel!
    private var descriptionText: UILabel!
    private var detailsText: UILabel!
    
    
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
        hStack.spacing = UIDevice.isiPad ? 8 : 4
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        vStack = UIStackView()
        vStack.axis = .vertical
        vStack.distribution = .fill
        vStack.translatesAutoresizingMaskIntoConstraints = false

        image = UIImageView(image: UIImage(named: "grass"))
        image.backgroundColor = .systemYellow.darkenColor(factor: 12)
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.borderWidth = UIDevice.isiPad ? 8 : 4
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = AchievementsTVCell.imageSize / 2
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        
        titleText = UILabel()
        titleText.font = UIFont(name: UIFont.gameFont, size: UIDevice.isiPad ? 32 : 20)
        titleText.textColor = UIFont.gameFontColor
        titleText.layer.shadowColor = UIColor.black.cgColor
        titleText.layer.shadowOffset = CGSize(width: -1.5, height: 1.5)
        titleText.layer.shadowRadius = 0
        titleText.layer.shadowOpacity = 0.25
        titleText.layer.masksToBounds = false
        titleText.translatesAutoresizingMaskIntoConstraints = false
        titleText.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        descriptionText = UILabel()
        descriptionText.numberOfLines = 0
        descriptionText.sizeToFit()
        descriptionText.font = UIFont(name: UIFont.chatFont, size: UIDevice.isiPad ? 30 : 18)
        descriptionText.textColor = UIFont.chatFontColor
        descriptionText.layer.shadowColor = UIColor.black.cgColor
        descriptionText.layer.shadowOffset = CGSize(width: -1, height: 1)
        descriptionText.layer.shadowRadius = 0
        descriptionText.layer.shadowOpacity = 0.25
        descriptionText.layer.masksToBounds = false
        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        descriptionText.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        detailsText = UILabel()
        detailsText.font = UIFont(name: UIFont.chatFont, size: UIDevice.isiPad ? 28 : 16)
        detailsText.textColor = .yellow.lightenColor(factor: 18)
        detailsText.layer.shadowColor = UIColor.black.cgColor
        detailsText.layer.shadowOffset = CGSize(width: -1, height: 1)
        detailsText.layer.shadowRadius = 0
        detailsText.layer.shadowOpacity = 0.25
        detailsText.layer.masksToBounds = false
        detailsText.translatesAutoresizingMaskIntoConstraints = false
        detailsText.setContentHuggingPriority(.defaultLow, for: .vertical)

        backgroundColor = .clear
    }
    
    private func layoutViews() {
        addSubview(hStack)
        hStack.addArrangedSubview(image)
        hStack.addArrangedSubview(vStack)
        vStack.addArrangedSubview(titleText)
        vStack.addArrangedSubview(descriptionText)
        vStack.addArrangedSubview(detailsText)

        
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: AchievementsTVCell.padding),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AchievementsTVCell.padding),
            trailingAnchor.constraint(equalTo: hStack.trailingAnchor, constant: AchievementsTVCell.padding),
            bottomAnchor.constraint(equalTo: hStack.bottomAnchor, constant: AchievementsTVCell.padding),
            
            image.widthAnchor.constraint(equalToConstant: AchievementsTVCell.imageSize),
            image.heightAnchor.constraint(equalToConstant: AchievementsTVCell.imageSize),
            image.topAnchor.constraint(equalTo: hStack.arrangedSubviews[0].topAnchor, constant: 0),
            image.leadingAnchor.constraint(equalTo: hStack.arrangedSubviews[0].leadingAnchor, constant: 0),
            
            vStack.topAnchor.constraint(equalTo: hStack.arrangedSubviews[1].topAnchor, constant: 0),
            vStack.leadingAnchor.constraint(equalTo: hStack.arrangedSubviews[1].leadingAnchor, constant: 0),
            hStack.arrangedSubviews[1].trailingAnchor.constraint(equalTo: vStack.trailingAnchor, constant: 0),
            hStack.arrangedSubviews[1].bottomAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 0),
            
            titleText.centerYAnchor.constraint(equalTo: vStack.arrangedSubviews[0].centerYAnchor, constant: 0),
            titleText.leadingAnchor.constraint(equalTo: vStack.arrangedSubviews[0].leadingAnchor, constant: 0),
            titleText.heightAnchor.constraint(equalToConstant: titleText.font.pointSize + 2),
            vStack.arrangedSubviews[0].trailingAnchor.constraint(equalTo: titleText.trailingAnchor, constant: 0),

            descriptionText.topAnchor.constraint(equalTo: vStack.arrangedSubviews[1].topAnchor, constant: 0),
            descriptionText.leadingAnchor.constraint(equalTo: vStack.arrangedSubviews[1].leadingAnchor, constant: 0),
            vStack.arrangedSubviews[1].trailingAnchor.constraint(equalTo: descriptionText.trailingAnchor, constant: 0),
            
            detailsText.topAnchor.constraint(equalTo: vStack.arrangedSubviews[2].topAnchor, constant: 0),
            detailsText.leadingAnchor.constraint(equalTo: vStack.arrangedSubviews[2].leadingAnchor, constant: 0),
            vStack.arrangedSubviews[2].trailingAnchor.constraint(equalTo: detailsText.trailingAnchor, constant: 0),
            vStack.arrangedSubviews[2].bottomAnchor.constraint(equalTo: detailsText.bottomAnchor, constant: 0)
        ])
    }
    
    
    // MARK: - Functions
    
    func setViews(achievement: AchievementsModel) {
        image.image = UIImage(named: achievement.isCompleted ? achievement.imageName : "questionmarknoborder")
        titleText.text = achievement.title.uppercased()
        
        if achievement.isCompleted {
            descriptionText.text = achievement.descriptionCompleted
            detailsText.text = "Acquired: \(achievement.completionDateString)"
        }
        else {
            descriptionText.text = achievement.isHidden ? "This is a hidden achievement. Keep playing to unlock it!" : achievement.descriptionNotCompleted
            detailsText.text = "Progress: \(achievement.percentComplete)%"
        }
    }
}
