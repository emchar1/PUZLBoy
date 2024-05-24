//
//  NotificationsRequestView.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/24/24.
//

import UIKit

class NotificationsRequestView: UIView {

    // MARK: - Properties

    private var backgroundView: UIView!
    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var proceedButton: UIButton!
    

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .blue.darkenColor(factor: 6)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont(name: UIFont.gameFont, size: 24)
        titleLabel.textColor = .yellow
        titleLabel.textAlignment = .center
        titleLabel.shadowColor = .darkGray
        titleLabel.shadowOffset = CGSize(width: -2, height: 2)
        titleLabel.text = "NOTIFICATION REQUEST"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        descriptionLabel = UILabel()
        descriptionLabel.font = UIFont(name: UIFont.chatFont, size: 22)
        descriptionLabel.textColor = .yellow
        descriptionLabel.shadowColor = .darkGray
        descriptionLabel.shadowOffset = CGSize(width: -1, height: 1)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "This game sends notifications to remind you of news and updates. Tap OK below, then Allow on the following pop-up window."
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        proceedButton = UIButton(type: .system)
        proceedButton.setTitle("OK", for: .normal)
        proceedButton.backgroundColor = .green
        proceedButton.titleLabel?.font = UIFont(name: UIFont.chatFont, size: 22)
        proceedButton.tintColor = .blue.darkenColor(factor: 6)
        proceedButton.layer.cornerRadius = UIDevice.isiPad ? 37.5 : 25
        proceedButton.layer.shadowRadius = UIDevice.isiPad ? 6 : 4
        proceedButton.layer.shadowColor = UIColor.black.cgColor
        proceedButton.layer.shadowOpacity = 0.3
        proceedButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func layoutViews() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(proceedButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: frame.width * 0.8),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalToConstant: frame.width * 0.8),
            
            proceedButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            proceedButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            proceedButton.widthAnchor.constraint(equalToConstant: 100),
            proceedButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    
    // MARK: - Functions
}
