//
//  BSCalendarDayCollectionReusableView.swift
//  VehicleGroup
//
//  Created by 张亚东 on 16/4/27.
//  Copyright © 2016年 doyen. All rights reserved.
//

import UIKit

enum BSCalendarDayCollectionHeaderLineStyle {
    case fullWidth
    case relativeMargin
}

class BSCalendarDayCollectionReusableHeaderView: UICollectionReusableView {
    
    var style: BSCalendarDayCollectionHeaderLineStyle = .relativeMargin {
        didSet {
            layoutIfNeeded()
        }
    }
    
    fileprivate lazy var lineLayer: CAShapeLayer = {
        let lineLayer = CAShapeLayer()
        lineLayer.strokeColor = UIColor.lightGray.cgColor
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
        
        if style == .fullWidth {
            path.move(to: CGPoint(x: 0, y: self.bounds.size.height/2))
            path.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height/2))
        } else {
            path.move(to: CGPoint(x: 5, y: self.bounds.size.height/2))
            path.addLine(to: CGPoint(x: self.bounds.size.width - 10, y: self.bounds.size.height/2))
        }

        lineLayer.path = path.cgPath;
    }
}
