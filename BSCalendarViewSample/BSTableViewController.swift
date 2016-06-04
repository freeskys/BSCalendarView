//
//  BSTableTableViewController.swift
//  BSCalendarViewSample
//
//  Created by 张亚东 on 16/5/21.
//  Copyright © 2016年 张亚东. All rights reserved.
//

import UIKit

class BSTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let calendarView = BSCalendarView(frame: CGRect(x: 0, y: 0, width: view.bs_width, height: 0))
        calendarView.backgroundColor = UIColor.clearColor()
        tableView.addSubview(calendarView)
        
        calendarView.heightDidChangeClosure = { [unowned self] height in
            calendarView.bs_origin.y = -height
            self.tableView.contentOffset = CGPointMake(0, -height - 64)
            self.tableView.contentInset = UIEdgeInsetsMake(height + 64, 0, 0, 0)
        }
        
    }

}
