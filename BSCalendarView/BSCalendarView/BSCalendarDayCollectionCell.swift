//
//  BSCalendarDayCollectionCell.swift
//  VehicleGroup
//
//  Created by 张亚东 on 16/4/26.
//  Copyright © 2016年 doyen. All rights reserved.
//

import UIKit

private struct Constants {
    static let SelectedDayViewHeightInset: CGFloat = 14
}

class BSCalendarDayCollectionCell: UICollectionViewCell {
    
    var dayTextColor = UIColor.blackColor()
    var selectedDayTextColor = UIColor.whiteColor()
    var weekendDayTextColor = UIColor.lightGrayColor()
    var futureDayTextColor = UIColor.lightGrayColor()
    var roundDayTextColor = UIColor.clearColor()
    
    var dayItem: BSCalendarDayItem! {
        didSet {
            dayLabel.text = "\(dayItem.day)"
            dayLabel.textColor = dayTextColor
            
            if dayItem.isToday == true {
                todayLineLayer.hidden = false
            } else {
                todayLineLayer.hidden = true
                
                if dayItem.isSelectedDay == true {
                    dayLabel.textColor = selectedDayTextColor
                    todayLineLayer.hidden = true
                    selectedDayView.hidden = false
                } else {
                    selectedDayView.hidden = true
                    
                    if dayItem.isWeekendDay {
                        dayLabel.textColor = weekendDayTextColor
                    }
                    if dayItem.isFutureDay {
                        dayLabel.textColor = futureDayTextColor
                    }
                    if dayItem.isRoundDay {
                        dayLabel.textColor = roundDayTextColor
                    }
                }
                
            }
        }
    }
    
    private lazy var dayLabel: UILabel = {
        let day: UILabel = UILabel(frame: self.bounds)
        day.textAlignment = .Center
        day.font = UIFont.boldSystemFontOfSize(14)
        return day
    }()
    
    private lazy var todayLineLayer: CAShapeLayer = {
        let path: UIBezierPath = UIBezierPath()
        path.moveToPoint(CGPoint(x: 14, y: self.bs_height/2 + 10))
        path.addLineToPoint(CGPoint(x: self.bs_width - 14, y: self.bs_height/2 + 10))
        path.lineCapStyle = .Butt
        
        let line: CAShapeLayer = CAShapeLayer()
        line.strokeColor = UIColor.redColor().CGColor
        line.path = path.CGPath
        line.hidden = true
        line.lineWidth = 2

        return line
    }()
    
    private lazy var selectedDayView: UIView = {
        let se: UIView = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: self.bs_height - Constants.SelectedDayViewHeightInset, height: self.bs_height - Constants.SelectedDayViewHeightInset)))
        se.center = CGPoint(x: self.bs_width/2, y: self.bs_height/2)
        se.backgroundColor = UIColor.redColor()
        se.layer.cornerRadius = 6
        se.hidden = true
        return se
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(selectedDayView)
        addSubview(dayLabel)
        layer.addSublayer(todayLineLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
