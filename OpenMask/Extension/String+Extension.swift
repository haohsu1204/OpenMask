//
//  String+Extension.swift
//  OpenMask
//
//  Created by House on 2020/3/2.
//  Copyright © 2020 haohsu. All rights reserved.
//

import UIKit

extension String {
    
    func transformingHalfwidthFullwidth() -> String {
        let string = NSMutableString(string: self)
        CFStringTransform(string, nil, kCFStringTransformFullwidthHalfwidth, false)
        return String(string)
    }
}
