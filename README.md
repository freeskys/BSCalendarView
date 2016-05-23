# BSCalendarView

## Overview

if the view did not add constraints, you need to rotate the view manually when screen's orientation changed.

![BSCalendarView.gif](https://github.com/blurryssky/BSCalendarView/blob/master/ScreenShots/BSCalendarView.gif)

## Installation

> use_frameworks!

> pod 'BSCalendarView'

## Usage

###Important: the height will be caculate automaticaly, you can just set 0 to initliaze

*   `monthHeight`, `weekdayHeight`, `dayHeight`, these three properties determine the height
*   `displayingMonthCalendarHeight` return the current month height

```swift
let calendarView = BSCalendarView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 0))
```
###Use xib
```swift
@IBOutlet weak var calendarView: BSCalendarView!
```
    
###The properties
```swift
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

```
###The closures
```swift
calendarView.heightDidChangeClosure = { height in
    print("height = \(height)")
}
            
calendarView.scrollXPercentageClosure = { percentage in
    print("percentage = \(percentage)")
}
            
calendarView.displayingMonthDidChangeClosure = { month in
    print("month = \(month)")
}
```
