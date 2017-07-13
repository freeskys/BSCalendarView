//
//  BSCalendarDayCollectionItem.swift
//  VehicleGroup
//
//  Created by 张亚东 on 16/4/26.
//  Copyright © 2016年 doyen. All rights reserved.
//

import UIKit

open class BSCalendarDayItem: NSObject {

    open var month: Int!
    open var day: Int!
    
    open var isToday: Bool = false
    open var isWeekendDay: Bool = false
    open var isFutureDay: Bool = false
    open var isSelectedDay: Bool = false
    open var isRoundDay: Bool = false
    
}
