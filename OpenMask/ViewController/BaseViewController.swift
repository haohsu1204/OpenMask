//
//  BaseViewController.swift
//  OpenMask
//
//  Created by House on 2020/2/6.
//  Copyright © 2020 haohsu. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    let appDelegate :AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // disable dark mode
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterNotification()
    }

    func initInterface() {}
    
    func registerNotification() {}
    
    func unregisterNotification() {}
}
