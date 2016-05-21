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
    
    var themeColor: UIColor! {
        didSet {
            todayLineLayer.strokeColor = themeColor.CGColor
            selectedDayView.backgroundColor = themeColor
        }
    }
    
    var dayFont: UIFont! {
        didSet {
            dayLabel.font = dayFont
        }
    }
    
    var dayTextColor: UIColor!
    var selectedDayTextColor: UIColor!
    var weekendDayTextColor: UIColor!
    var futureDayTextColor: UIColor!
    var roundDayTextColor: UIColor!
    
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
                    if dayItem.isRoundDay {
                        dayLabel.textColor = roundDayTextColor
                    }
                    if dayItem.isFutureDay {
                        dayLabel.textColor = futureDayTextColor
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
        line.path = path.CGPath
        line.hidden = true
        line.lineWidth = 2

        return line
    }()
    
    private lazy var selectedDayView: UIView = {
        let se: UIView = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: self.bs_height - Constants.SelectedDayViewHeightInset, height: self.bs_height - Constants.SelectedDayViewHeightInset)))
        se.center = CGPoint(x: self.bs_width/2, y: self.bs_height/2)
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
