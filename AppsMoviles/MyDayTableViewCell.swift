//
//  MyDayTableViewCell.swift
//  AppsMoviles
//
//  Created by Héctor Iván Aguirre Arteaga on 14/11/17.
//

import UIKit

class MyDayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var placeL: UILabel!
    @IBOutlet weak var desL: UILabel!
    @IBOutlet weak var priorV: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
