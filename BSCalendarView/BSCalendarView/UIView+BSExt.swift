//
//  UIView+BSExt.swift
//  VehicleGroup
//
//  Created by 张亚东 on 16/4/25.
//  Copyright © 2016年 doyen. All rights reserved.
//

import UIKit

extension UIView {
    func image() -> UIImage{
        UIGraphicsBeginImageContext(bounds.size);
        drawViewHierarchyInRect(bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIView {
    var bs_x: CGFloat {
        set {
            frame = CGRect(origin: CGPoint(x: newValue, y: frame.origin.y), size: frame.size)
        }
        get {
            return frame.origin.x
        }
    }
    
    var bs_y: CGFloat {
        set {
            frame = CGRect(origin: CGPoint(x: frame.origin.x, y: newValue), size: frame.size)
        }
        get {
            return frame.origin.y
        }
    }
    
    var bs_width: CGFloat {
        set {
            frame = CGRect(origin: frame.origin, size: CGSize(width: newValue, height: frame.size.height))
        }
        get {
            return frame.size.width
        }
    }
    
    var bs_height: CGFloat {
        set {
            frame = CGRect(origin: frame.origin, size: CGSize(width: frame.size.width, height: newValue))
        }
        get {
            return frame.size.height
        }
    }
    
    var bs_origin: CGPoint {
        set {
            frame = CGRect(origin: newValue, size: frame.size)
        }
        get {
            return frame.origin
        }
    }
    
    var bs_size: CGSize {
        set {
            frame = CGRect(origin: frame.origin, size: newValue)
        }
        get {
            return frame.size
        }
    }
    
}