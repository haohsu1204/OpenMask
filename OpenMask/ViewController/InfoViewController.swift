//
//  InfoViewController.swift
//  OpenMask
//
//  Created by House on 2020/2/29.
//  Copyright © 2020 haohsu. All rights reserved.
//

import UIKit

class InfoViewController: BaseViewController {

    @IBOutlet weak var vHandle: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbBusinessHours: UILabel!
    @IBOutlet weak var lbAdultCount: UILabel!
    @IBOutlet weak var lbChildCount: UILabel!
    @IBOutlet weak var lbUpdateTime: UILabel!
    
    var marker: Marker? {
        didSet {
            refreshInterface()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshInterface()
    }
    
    override func initInterface() {
        super.initInterface()
        
        self.view.layer.cornerRadius = 4
        self.vHandle.layer.cornerRadius = 4
    }
  
    private func refreshInterface() {
        if let data = self.marker {
            self.lbName.text = data.title
            self.lbAdultCount.text = String(data.adultCount)
            self.lbChildCount.text = String(data.childCount)
            self.lbUpdateTime.text = String(format: localizedString("hint_update_time"), data.updateTime)
            self.lbBusinessHours.text = data.currentBusinessHour()
        }
    }

}
