//
//  BSCalendarMonthCollectionCell.swift
//  VehicleGroup
//
//  Created by 张亚东 on 16/4/26.
//  Copyright © 2016年 doyen. All rights reserved.
//

import UIKit

private struct Constants {
    static let DayCollectionReuseCellIdentifier = "BSCalendarDayCollectionCell"
    static let DayCollectionReuseableHeaderViewIdentifier = "BSCalendarDayCollectionReusableHeaderView"
}

class BSCalendarMonthCollectionCell: UICollectionViewCell {
    
    var dayDidSelectedClosure: DayItemClosure?
    
    var monthItem: BSCalendarMonthItem! {
        didSet {
            dayCollectionView.reloadData()
        }
    }
    
    var lastSelectedDayItem: BSCalendarDayItem?
    
    var dayHeight: CGFloat!
    
    
    //for day cell 
    var themeColor: UIColor!
    
    var separatorHidden: Bool!
    
    var dayFont: UIFont!
    
    var dayTextColor: UIColor!
    var selectedDayTextColor: UIColor!
    var weekendDayTextColor: UIColor!
    var futureDayTextColor: UIColor!
    var roundDayTextColor: UIColor!
    
    fileprivate lazy var dayCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.estimatedItemSize = CGSize(width: self.bs_width/7,
                                              height: 40)
        flowLayout.headerReferenceSize = CGSize(width: self.bs_width, height: 0.5)
        
        let c : UICollectionView = UICollectionView(frame: self.bounds,
                                                    collectionViewLayout: flowLayout)
        c.register(BSCalendarDayCollectionCell.self,
                        forCellWithReuseIdentifier: Constants.DayCollectionReuseCellIdentifier)
        c.register(BSCalendarDayCollectionReusableHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Constants.DayCollectionReuseableHeaderViewIdentifier)
        c.dataSource = self
        c.delegate = self
        c.backgroundColor = UIColor.clear
        return c
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(dayCollectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension BSCalendarMonthCollectionCell {
    
    func deselectLastCellIfNeeded() {
        
        guard lastSelectedDayItem != nil else {
            return
        }
        lastSelectedDayItem?.isSelectedDay = false
        
        guard let index = monthItem.dayItems.index(of: lastSelectedDayItem!) else {
            return
        }
        let indexPath = IndexPath(row: index%7, section: index/7)
        
        guard let cell = dayCollectionView.cellForItem(at: indexPath) as? BSCalendarDayCollectionCell else {
            return
        }
        
        cell.dayItem = lastSelectedDayItem
    }
}

extension BSCalendarMonthCollectionCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let section = Int(ceil(Double(monthItem.dayItems.count)/7))
        return section
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == Int(ceil(Double(monthItem.dayItems.count)/7)) - 1 &&
            monthItem.dayItems.count%7 != 0{
            return monthItem.dayItems.count%7
        }
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.DayCollectionReuseCellIdentifier, for: indexPath) as! BSCalendarDayCollectionCell
        let dayItem = monthItem.dayItems[indexPath.section * 7 + indexPath.row]
        
        if indexPath.row == 0 || indexPath.row == 6 {
            dayItem.isWeekendDay = true
        }

        cell.themeColor = themeColor
        
        cell.dayFont = dayFont
        
        cell.dayTextColor = dayTextColor
        cell.selectedDayTextColor = selectedDayTextColor
        cell.weekendDayTextColor = weekendDayTextColor
        cell.futureDayTextColor = futureDayTextColor
        cell.roundDayTextColor = roundDayTextColor
        
        cell.dayItem = dayItem
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var view: UICollectionReusableView!
        if kind == UICollectionElementKindSectionHeader {
            view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Constants.DayCollectionReuseableHeaderViewIdentifier, for: indexPath)
        }
        return view
    }
}

extension BSCalendarMonthCollectionCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: floor(bs_width/7),
                      height: dayHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize.zero
        } else {
            if separatorHidden == false {
                return CGSize(width: bs_width, height: 0.5)
            } else {
                return CGSize.zero
            }
        }
    }
}

extension BSCalendarMonthCollectionCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let dayItem = monthItem.dayItems[indexPath.section * 7 + indexPath.row]
        
        guard dayItem.isRoundDay == false else {
            return
        }
        
        guard dayItem.isFutureDay == false else {
            return
        }
        
        guard dayItem.isWeekendDay == false else {
            return
        }
        
        dayItem.isSelectedDay = true
        dayDidSelectedClosure?(dayItem)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? BSCalendarDayCollectionCell else {
            return
        }
        
        cell.dayItem = dayItem
        
        if lastSelectedDayItem != dayItem {
            deselectLastCellIfNeeded()
        }
        lastSelectedDayItem = dayItem
    }
}

