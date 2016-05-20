//
//  BSCalendarDayCollectionItem.swift
//  VehicleGroup
//
//  Created by 张亚东 on 16/4/26.
//  Copyright © 2016年 doyen. All rights reserved.
//

import UIKit

public class BSCalendarDayItem: NSObject {

    public var month: Int!
    public var day: Int!
    
    public var isToday: Bool = false
    public var isWeekendDay: Bool = false
    public var isFutureDay: Bool = false
    public var isSelectedDay: Bool = false
    public var isRoundDay: Bool = false
    
}
