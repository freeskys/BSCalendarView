//
//  BSViewController.swift
//  BSCalendarViewSample
//
//  Created by 张亚东 on 16/5/21.
//  Copyright © 2016年 张亚东. All rights reserved.
//

import UIKit

class BSViewController: UIViewController {

    @IBOutlet weak var calendarView: BSCalendarView! {
        didSet {

            calendarView.backgroundColor = UIColor.lightGrayColor()
            calendarView.themeColor = UIColor.greenColor()
            calendarView.monthRange = NSMakeRange(1, 11)
            calendarView.separatorHidden = true
            calendarView.monthHeight = 50
            calendarView.weekdayTitles = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
            calendarView.weekdayFont = UIFont.boldSystemFontOfSize(16)
            calendarView.weekdayTextColor = UIColor.brownColor()
            calendarView.weekdayHeight = 40
            calendarView.dayFont = UIFont.boldSystemFontOfSize(16)
            calendarView.dayTextColor = UIColor.redColor()
            calendarView.selectedDayTextColor = UIColor.whiteColor()
            calendarView.weekendDayTextColor = UIColor.greenColor()
            calendarView.futureDayTextColor = UIColor.blueColor()
            calendarView.roundDayTextColor = UIColor.cyanColor()
            calendarView.dayHeight = 50
            
            calendarView.heightDidChangeClosure = { height in
                print("height = \(height)")
            }
            
            calendarView.scrollXPercentageClosure = { percentage in
                print("percentage = \(percentage)")
            }
            
            calendarView.displayingMonthDidChangeClosure = { month in
                print("month = \(month)")
            }
        }
    }
    
}
