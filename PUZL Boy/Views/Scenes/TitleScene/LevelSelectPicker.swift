//
//  LevelSelectPicker.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/3/23.
//

import UIKit

class LevelSelectPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties

    var selectedLevel: Int {
        let returnedString = String(selectedRow(inComponent: 0)) + String(selectedRow(inComponent: 1)) + String(selectedRow(inComponent: 2))

        return Int(returnedString) ?? 1
    }
    
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        delegate = self
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("deinit LevelSelectPicker")
    }
    
    // MARK: - Delegate and DataSource Functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 6
        }
        else {
            return 10
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return UIDevice.isiPad ? 40 : 30
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()

        if let view = view {
            label = view as! UILabel
        }
        
        label.font = UIFont(name: UIFont.gameFont, size: UIDevice.isiPad ? 36 : 24)
        label.textColor = .yellow
        label.textAlignment = .center
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: -2, height: 2)
        label.layer.shadowOpacity = 0.25
        label.layer.shadowRadius = 0
        label.text = String(row)
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            if row == 5 {
                
            }
        }
        print("Selected Level: \(selectedLevel)")
    }
}
