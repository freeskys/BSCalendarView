//
//  BSCalendarItemManager.swift
//  VehicleGroup
//
//  Created by 张亚东 on 16/5/20.
//  Copyright © 2016年 doyen. All rights reserved.
//

import UIKit
import DateTools

class BSCalendarItemManager: NSObject {
    
    var monthRange: NSRange = NSRange(location: 1, length: NSDate().month() - 1) {
        didSet {
            
            guard monthRange.location >= 1 && monthRange.location <= 12 else {
                return
            }
            
            guard monthRange.length >= 0 && monthRange.length <= 11 else {
                return
            }
            
            monthItems = self.configureMonthItems()
        }
    }
    
    lazy var monthItems: [BSCalendarMonthItem] = {
        return self.configureMonthItems()
    }()
    
}

extension BSCalendarItemManager {
    
    func configureMonthItems() -> [BSCalendarMonthItem] {
        let startMonth = monthRange.location
        let endMonth = monthRange.length + monthRange.location
        
        var items: [BSCalendarMonthItem] = []
        for i in startMonth...endMonth {
            let monthItem = BSCalendarMonthItem()
            monthItem.month = i
            monthItem.dayItems = self.configureDayItems(month: i)
            items.append(monthItem)
        }
        return items
    }
    
    func configureDayItems(month month:Int) -> [BSCalendarDayItem] {

        var dayItems: [BSCalendarDayItem] = []
        
        dayItems.appendContentsOf(configurePreviousMonthDayItems(month: month))
        dayItems.appendContentsOf(configureMonthDayItems(month: month))
        dayItems.appendContentsOf(configureNextMonthDayItems(month: month))

        return dayItems
    }
    
    func configurePreviousMonthDayItems(month month:Int) -> [BSCalendarDayItem] {
        
        let date = NSDate()
        let monthFirstDayDate = NSDate(year: date.year(), month: month, day: 1)

        var dayItems: [BSCalendarDayItem] = []
        
        let firstDayWeekDay = monthFirstDayDate.weekday()
        for day in 1..<firstDayWeekDay {
            
            let dayItem = BSCalendarDayItem()
            
            let dayDate = monthFirstDayDate.dateBySubtractingDays(firstDayWeekDay - day)
            
            dayItem.isRoundDay = true
            dayItem.day = dayDate.day()
            dayItem.month = dayDate.month()
            dayItems.append(dayItem)
        }
        return dayItems
    }
    
    func configureMonthDayItems(month month:Int) -> [BSCalendarDayItem] {
        
        let date = NSDate()
        let monthFirstDayDate = NSDate(year: date.year(), month: month, day: 1)
        let days = monthFirstDayDate.daysInMonth()
        
        var dayItems: [BSCalendarDayItem] = []
        
        for day in 1...days {
            
            let dayItem = BSCalendarDayItem()

            dayItem.day = day
            dayItem.month = month
            dayItems.append(dayItem)
            
            if month == date.month() {
                if day == date.day() {
                    
                    dayItem.isToday = true
                    
                } else if day > date.day() {
                    
                    dayItem.isFutureDay = true
                    
                } else {
                    
                    dayItem.isToday = false
                    dayItem.isFutureDay = false
                    dayItem.isSelectedDay = false
                }
            }
        }
        return dayItems
    }
    
    func configureNextMonthDayItems(month month:Int) -> [BSCalendarDayItem] {
        
        let date = NSDate()
        let monthFirstDayDate = NSDate(year: date.year(), month: month, day: 1)
        let monthLastDayDate = NSDate(year: date.year(), month: monthFirstDayDate.nextMonth(), day: 1).dateBySubtractingDays(1)
        
        var dayItems: [BSCalendarDayItem] = []
        
        let monthLastDayWeekDay = monthLastDayDate.weekday() - 1
        let nextMonth = monthLastDayDate.nextMonth()
        for day in 0..<(6 - monthLastDayWeekDay) {
            let dayItem = BSCalendarDayItem()
            
            dayItem.isRoundDay = true
            dayItem.day = day + 1
            dayItem.month = nextMonth
            dayItems.append(dayItem)
        }
        return dayItems
    }
}
