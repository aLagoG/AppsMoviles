//
//  TreeTableViewCell.swift
//  RATreeViewExamples
//
//  Created by Rafal Augustyniak on 22/11/15.
//  Copyright © 2015 com.Augustyniak. All rights reserved.
//

import UIKit

class TreeTableViewCell : UITableViewCell {

    @IBOutlet private weak var additionalButton: UIButton!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var customTitleLabel: UILabel!
    
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var priorityColor: UIView!
    
    private var additionalButtonHidden : Bool {
        get {
            return additionalButton.isHidden;
        }
        set {
            additionalButton.isHidden = newValue;
        }
    }

    override func awakeFromNib() {
        selectedBackgroundView? = UIView()
        selectedBackgroundView?.backgroundColor = .clear
    }

    var additionButtonActionBlock : ((TreeTableViewCell) -> Void)?;

    func setup(withTitle title: String, detailsText: String, level : Int, additionalButtonHidden: Bool, lugar: String) {
        priorityColor.layer.cornerRadius = priorityColor.bounds.height
        customTitleLabel.text = title
        detailsLabel.text = detailsText
        placeLabel.text = lugar
        
        self.additionalButtonHidden = additionalButtonHidden
        
        let backgroundColor: UIColor
        if level == 0 {
            backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        } else if level == 1 {
            backgroundColor = UIColor(red: 209.0/255.0, green: 238.0/255.0, blue: 252.0/255.0, alpha: 1.0)
        } else {
            backgroundColor = UIColor(red: 224.0/255.0, green: 248.0/255.0, blue: 216.0/255.0, alpha: 1.0)
        }
        self.priorityColor.backgroundColor = UIColor.clear
        self.backgroundColor = backgroundColor
        self.contentView.backgroundColor = backgroundColor
        customTitleLabel.textColor = UIColor.black
        detailsLabel.textColor = UIColor.black
        let left = 11.0 + 20.0 * CGFloat(level) + 25
        self.customTitleLabel.frame.origin.x = left
        self.detailsLabel.frame.origin.x = left
        self.placeLabel.frame.origin.x = left + detailsLabel.frame.width
        self.priorityColor.frame.origin.x = left - 28
    }

    func additionButtonTapped(_ sender : AnyObject) -> Void {
        if let action = additionButtonActionBlock {
            action(self)
        }
    }
    func done(){
        customTitleLabel.textColor = UIColor.lightGray
        detailsLabel.textColor = UIColor.lightGray
        placeLabel.textColor = UIColor.lightGray
    }
    
    func setColor(_ priority : Int64){
        switch (priority){
        case 1:
            self.priorityColor.backgroundColor = UIColor.clear
            break
        case 2:
            self.priorityColor.backgroundColor = UIColor(red: 255.0/255.0, green: 123.0/255.0, blue: 84.0/255.0, alpha: 1.0)
            break
        case 3:
            self.priorityColor.backgroundColor = UIColor(red: 255.0/255.0, green: 84.0/255.0, blue: 84.0/255.0, alpha: 1.0)
            break
        default:
            break
        }
    }

}
