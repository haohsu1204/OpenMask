//
//  MarkerViewCell.swift
//  OpenMask
//
//  Created by House on 2020/3/2.
//  Copyright © 2020 haohsu. All rights reserved.
//

import UIKit

class MarkerViewCell: UITableViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var lbAddress: UILabel!
    
    static let cellHeight: CGFloat = 68
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
