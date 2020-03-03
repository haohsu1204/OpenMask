//
//  UIView+Extension.swift
//  OpenMask
//
//  Created by House on 2020/2/29.
//  Copyright © 2020 haohsu. All rights reserved.
//

import UIKit

extension UIView {
    
    func addShadoow() {
        self.layer.shadowColor = UIColor.init(white: 0, alpha: 0.6).cgColor
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
}
