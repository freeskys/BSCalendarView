//
//  BSFallDownViewController.swift
//  BSCalendarViewSample
//
//  Created by 张亚东 on 16/6/4.
//  Copyright © 2016年 张亚东. All rights reserved.
//

import UIKit

class BSFallDownViewController: UIViewController {

    lazy var calendarContentView: UIView = {
        
        let view: UIView = UIView(frame: CGRect(x: 0, y: 64, width: self.view.bs_width, height: 0))
        view.clipsToBounds = true
        return view
    }()
    
    lazy var calendarView: BSCalendarView = {
        
        let calendarView: BSCalendarView = BSCalendarView(frame: CGRect(x: 10, y: 10, width: self.view.bs_width - 20, height: 0))
        calendarView.hidden = true
        calendarView.layer.cornerRadius = 5
        calendarView.layer.shadowOpacity = 0.5
        calendarView.layer.shadowOffset = CGSize(width: 0, height: 3)
 
        return calendarView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(calendarContentView)
        calendarContentView.addSubview(calendarView)
        
        calendarView.heightDidChangeClosure = { [unowned self] height in
            self.calendarContentView.bs_height = height + 20
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        calendarView.hidden = false
        struct Static {
            static var didShow = false
        }
        
        if Static.didShow == false {
            calendarContentView.bs_height = 0
            
            UIView.animateWithDuration(0.5) { [weak self] in
                
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.calendarContentView.bs_height = strongSelf.calendarView.displayingMonthCalendarHeight + 20
                
            }
            Static.didShow = true
        } else {
            UIView.animateWithDuration(0.5) { [weak self] in
                
                guard let strongSelf = self else {
                    return
                }
                strongSelf.calendarContentView.bs_height = 0
                
            }
            Static.didShow = false
        }
    }

}
