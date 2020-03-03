//
//  Marker.swift
//  OpenMask
//
//  Created by House on 2020/2/28.
//  Copyright © 2020 haohsu. All rights reserved.
//

import UIKit

class Marker: NSObject {

    var code: String = ""
    
    var title: String = ""
    
    var address: String = ""
    
    var latitude: Double = 0
    
    var longitude: Double = 0
    
    var adultCount: Int = 0
    
    var childCount: Int = 0
    
    var updateTime: String = ""
    
    var businessHours: [String] = Array()
    
    var isValid: Bool = false
    
    init(data: [String:Any]) {
        
        if let value = data["code"] as? String {
            self.code = value
        }
        
        if let value = data["name"] as? String {
            self.title = value.transformingHalfwidthFullwidth()
        }
        
        if let value = data["address"] as? String {
            self.address = value.transformingHalfwidthFullwidth()
        }
        
        if let value = data["location"] as? [String:Any] {
            self.latitude = value["lat"] as! Double
            self.longitude = value["lon"] as! Double
            self.isValid = true
        }
        
        if let value = data["adult_count"] as? String {
            self.adultCount = Int(value) ?? 0
        }
        
        if let value = data["child_count"] as? String {
            self.childCount = Int(value) ?? 0
        }
        
        if let value = data["updated_at"] as? String {
            self.updateTime = value
        }
        
        if let value = data["business_hours"] as? [String] {
            self.businessHours = value
        }
    
    }
    
    func currentBusinessHour() -> String? {
        let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        var weekDay = dateComponents.weekday!
        var hour = dateComponents.hour!
        if hour >= 21 {
            weekDay += 1
            hour = 0
        }
        let key = stringOfWeekDay(weekDay: weekDay) + stringOfHour(hour: hour)
        for business in self.businessHours {
            if business.contains(key) {
                return business
            }
        }
        return nil
    }
    
    private func stringOfWeekDay(weekDay: Int) -> String {
        
        switch weekDay % 7 {
        case 1:
            return "星期日"
        case 2:
            return "星期一"
        case 3:
            return "星期二"
        case 4:
            return "星期三"
        case 5:
            return "星期四"
        case 6:
            return "星期五"
        case 0:
            return "星期六"
        default:
            return ""
        }
    }
    
    private func stringOfHour(hour: Int) -> String {
        if hour >= 12 && hour < 18 {
            return "下午"
        }
        else if hour >= 18 && hour < 21 {
            return "晚上"
        }
        else {
            return "上午"
        }
    }
}
