//
//  HowToPlayTVCell.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/20/23.
//

import UIKit

class HowToPlayTVCell: UITableViewCell {
    
    // MARK: - Properties
    
    class var reuseID: String { "HowToPlayCell" }
    class var padding: CGFloat { UIDevice.isiPad ? 16 : 8 }
    class var imageSize: CGFloat { UIDevice.isiPad ? 154 : 88 }
    
    private var hStack: UIStackView!
    private var vStack: UIStackView!
    
    private var image: UIImageView!
    private var titleText: UILabel!
    private var descriptionText: UILabel!
    
    
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
        image.backgroundColor = .darkGray.darkenColor(factor: 3)
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.borderWidth = UIDevice.isiPad ? 4 : 2
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = UIDevice.isiPad ? 12 : 8
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

        backgroundColor = .clear        
    }
    
    private func layoutViews() {
        addSubview(hStack)
        hStack.addArrangedSubview(image)
        hStack.addArrangedSubview(vStack)
        vStack.addArrangedSubview(titleText)
        vStack.addArrangedSubview(descriptionText)

        
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: HowToPlayTVCell.padding),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: HowToPlayTVCell.padding),
            trailingAnchor.constraint(equalTo: hStack.trailingAnchor, constant: HowToPlayTVCell.padding),
            bottomAnchor.constraint(equalTo: hStack.bottomAnchor, constant: HowToPlayTVCell.padding),
            
            image.widthAnchor.constraint(equalToConstant: HowToPlayTVCell.imageSize),
            image.heightAnchor.constraint(equalToConstant: HowToPlayTVCell.imageSize),
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
            vStack.arrangedSubviews[1].trailingAnchor.constraint(equalTo: descriptionText.trailingAnchor, constant: 0)
        ])
    }
    
    
    // MARK: - Functions
    
    func setViews(imageName: String, title: String, requiredLevel: Int, currentLevel: Int, description: String) {
        image.image = UIImage(named: currentLevel >= requiredLevel ? imageName : "locked")
        titleText.text = currentLevel >= requiredLevel ? title.uppercased() : "LOCKED"
        descriptionText.text = currentLevel >= requiredLevel ? description : "Reach level \(requiredLevel) to unlock this tip."
    }
}
