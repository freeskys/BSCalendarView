//
//  BSCalendarDayCollectionReusableView.swift
//  VehicleGroup
//
//  Created by 张亚东 on 16/4/27.
//  Copyright © 2016年 doyen. All rights reserved.
//

import UIKit

enum BSCalendarDayCollectionHeaderLineStyle {
    case FullWidth
    case RelativeMargin
}

class BSCalendarDayCollectionReusableHeaderView: UICollectionReusableView {
    
    var style: BSCalendarDayCollectionHeaderLineStyle = .RelativeMargin {
        didSet {
            layoutIfNeeded()
        }
    }
    
    private lazy var lineLayer: CAShapeLayer = {
        let lineLayer = CAShapeLayer()
        lineLayer.strokeColor = UIColor.lightGrayColor().CGColor
        lineLayer.opacity = 0.5
        return lineLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(lineLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        
        if style == .FullWidth {
            path.moveToPoint(CGPoint(x: 0, y: self.bounds.size.height/2))
            path.addLineToPoint(CGPoint(x: self.bounds.size.width, y: self.bounds.size.height/2))
        } else {
            path.moveToPoint(CGPoint(x: 5, y: self.bounds.size.height/2))
            path.addLineToPoint(CGPoint(x: self.bounds.size.width - 10, y: self.bounds.size.height/2))
        }

        lineLayer.path = path.CGPath;
    }
}
