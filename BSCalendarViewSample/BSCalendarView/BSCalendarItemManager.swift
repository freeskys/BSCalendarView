//
//  BSCalendarItemManager.swift
//  VehicleGroup
//
//  Created by 张亚东 on 16/5/20.
//  Copyright © 2016年 doyen. All rights reserved.
//

import UIKit
import DateToolsSwift

class BSCalendarItemManager: NSObject {
    
    var monthRange: NSRange = NSRange(location: 1, length: Date().month - 1) {
        didSet {
            monthItems = configureMonthItems()
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
    
    func configureDayItems(month:Int) -> [BSCalendarDayItem] {

        var dayItems: [BSCalendarDayItem] = []
        
        dayItems.append(contentsOf: configurePreviousMonthDayItems(month: month))
        dayItems.append(contentsOf: configureMonthDayItems(month: month))
        dayItems.append(contentsOf: configureNextMonthDayItems(month: month))

        if month > Date().month {
            dayItems.forEach({ (dayItem: BSCalendarDayItem) in
                dayItem.isFutureDay = true
            })
        }
        
        return dayItems
    }
    
    func configurePreviousMonthDayItems(month:Int) -> [BSCalendarDayItem] {
        
        let date = Date()
        let monthFirstDayDate = Date(year: date.year, month: month, day: 1)

        var dayItems: [BSCalendarDayItem] = []
        
        let firstDayWeekDay = monthFirstDayDate.weekday
        for day in 1..<firstDayWeekDay {
            
            let dayItem = BSCalendarDayItem()
            
//            let dayDate = monthFirstDayDate.dateBySubtractingDays(firstDayWeekDay - day)
            let minusDay = firstDayWeekDay - day
            let dayDate = monthFirstDayDate.subtract(TimeChunk(seconds: 0, minutes: 0, hours: 0, days: minusDay, weeks: 0, months: 0, years: 0))
            
            dayItem.day = dayDate.day
            dayItem.month = dayDate.month
            dayItems.append(dayItem)
            
            dayItem.isRoundDay = true
            
        }
        return dayItems
    }
    
    func configureMonthDayItems(month:Int) -> [BSCalendarDayItem] {
        
        let date = Date()
        let monthFirstDayDate = Date(year: date.year, month: month, day: 1)
        let days = monthFirstDayDate.daysInMonth
        
        var dayItems: [BSCalendarDayItem] = []
        
        for day in 1...days {
            
            let dayItem = BSCalendarDayItem()

            dayItem.day = day
            dayItem.month = month
            dayItems.append(dayItem)
            
            if month == date.month {
                if day == date.day {
                    
                    dayItem.isToday = true
                    
                } else if day > date.day {
                    
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
    
    func configureNextMonthDayItems(month:Int) -> [BSCalendarDayItem] {
        
        let date = Date()
        let monthFirstDayDate = Date(year: date.year, month: month, day: 1)
        let monthLastDayDate = Date(year: date.year, month: monthFirstDayDate.bs_nextMonth(), day: 1).subtract(TimeChunk(seconds: 0, minutes: 0, hours: 0, days: 1, weeks: 0, months: 0, years: 0))
//        let monthLastDayDate = Date(year: date.year, month: monthFirstDayDate.bs_nextMonth(), day: 1).dateBySubtractingDays(1)
        
        var dayItems: [BSCalendarDayItem] = []
        
        let monthLastDayWeekDay = monthLastDayDate.weekday - 1
        let nextMonth = monthLastDayDate.bs_nextMonth()
        for day in 0..<(6 - monthLastDayWeekDay) {
            let dayItem = BSCalendarDayItem()
            
            dayItem.day = day + 1
            dayItem.month = nextMonth
            dayItems.append(dayItem)
            
            dayItem.isRoundDay = true
            
            if nextMonth > date.month {
                dayItem.isFutureDay = true
            }
        }
        return dayItems
    }
}
