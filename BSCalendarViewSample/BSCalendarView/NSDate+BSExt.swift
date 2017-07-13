//
//  NSDate+BSExt.swift
//  VehicleGroup
//
//  Created by 张亚东 on 16/5/3.
//  Copyright © 2016年 doyen. All rights reserved.
//

import Foundation

extension Date {
    
    func bs_previousMonth() -> Int {
        
        if month == 1 {
            return 12
        }
        return month - 1
    }
    
    func bs_nextMonth() -> Int {
        
        if month == 12 {
            return 1
        }
        return month + 1
    }
    
}
