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

            calendarView.backgroundColor = UIColor.lightGray
            calendarView.themeColor = UIColor.green
            calendarView.monthRange = NSMakeRange(1, 11)
            calendarView.separatorHidden = true
            calendarView.monthHeight = 50
            calendarView.weekdayTitles = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
            calendarView.weekdayFont = UIFont.boldSystemFont(ofSize: 16)
            calendarView.weekdayTextColor = UIColor.brown
            calendarView.weekdayHeight = 40
            calendarView.dayFont = UIFont.boldSystemFont(ofSize: 16)
            calendarView.dayTextColor = UIColor.red
            calendarView.selectedDayTextColor = UIColor.white
            calendarView.weekendDayTextColor = UIColor.green
            calendarView.futureDayTextColor = UIColor.blue
            calendarView.roundDayTextColor = UIColor.cyan
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
