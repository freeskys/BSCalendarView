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
            todayLineLayer.strokeColor = themeColor.cgColor
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
                todayLineLayer.isHidden = false
            } else {
                todayLineLayer.isHidden = true
                
                if dayItem.isSelectedDay == true {
                    dayLabel.textColor = selectedDayTextColor
                    todayLineLayer.isHidden = true
                    selectedDayView.isHidden = false
                } else {
                    selectedDayView.isHidden = true
                    
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
    
    fileprivate lazy var dayLabel: UILabel = {
        let day: UILabel = UILabel(frame: self.bounds)
        day.textAlignment = .center
        day.font = UIFont.boldSystemFont(ofSize: 14)
        return day
    }()
    
    fileprivate lazy var todayLineLayer: CAShapeLayer = {
        let path: UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: 14, y: self.bs_height/2 + 10))
        path.addLine(to: CGPoint(x: self.bs_width - 14, y: self.bs_height/2 + 10))
        path.lineCapStyle = .butt
        
        let line: CAShapeLayer = CAShapeLayer()
        line.path = path.cgPath
        line.isHidden = true
        line.lineWidth = 2

        return line
    }()
    
    fileprivate lazy var selectedDayView: UIView = {
        let se: UIView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.bs_height - Constants.SelectedDayViewHeightInset, height: self.bs_height - Constants.SelectedDayViewHeightInset)))
        se.center = CGPoint(x: self.bs_width/2, y: self.bs_height/2)
        se.layer.cornerRadius = 6
        se.isHidden = true
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
