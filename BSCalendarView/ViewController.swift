//
//  ViewController.swift
//  BSCalendarView
//
//  Created by 张亚东 on 16/5/20.
//  Copyright © 2016年 blurryssky. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let calendar = BSCalendarView(frame: CGRect(origin: CGPointMake(0, 64), size: CGSize(width: view.bs_width, height: 0)))
        view.addSubview(calendar)
    }

}

