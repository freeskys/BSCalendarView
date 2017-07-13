//
//  BSCalendarView.swift
//  VehicleGroup
//
//  Created by 张亚东 on 16/4/26.
//  Copyright © 2016年 doyen. All rights reserved.
//

import UIKit
import DateToolsSwift

private enum CalendarScrollDirection {
    case left
    case right
}

private struct Constants {
    static let BottomInset: CGFloat = 10
    static let ButtonWidth: CGFloat = 90
    static let MonthCollectionReuseCellIdentifier = "BSCalendarCollectionCell"
}

public typealias DayItemClosure = (_ dayItem: BSCalendarDayItem) -> Void

open class BSCalendarView: UIView {
    
    //MARK:closure
    open var heightDidChangeClosure: ((_ height: CGFloat) -> Void)?
    
    //range 0.01 ~ 0.99
    open var scrollXPercentageClosure: ((_ percentage: CGFloat) -> Void)?
    open var displayingMonthDidChangeClosure: ((_ month: Int) -> Void)?
    
    open var dayDidSelectedClosure: DayItemClosure?
    
    //MARK:Vars
    open var themeColor = UIColor.red {
        didSet {
            monthLabel.textColor = themeColor
        }
    }
    
    open var separatorHidden = false {
        didSet {
            separator.isHidden = separatorHidden
        }
    }
    
    //location range (1, 12), length range(0, 11)
    open var monthRange = NSRange(location: 1, length: Date().month - 1) {
        didSet {
            
            guard monthRange.location >= 1 && monthRange.location <= 12 else {
                monthRange = oldValue
                return
            }
            
            guard monthRange.length >= 0 && monthRange.length <= 11 else {
                monthRange = oldValue
                return
            }
            
            itemManager.monthRange = monthRange
            
            setupDisplayMonthItem()
        }
    }
    
    open var monthHeight: CGFloat = 40 {
        didSet {
            if monthHeight == 0 {
                bs_previousMonthButton.removeFromSuperview()
                bs_nextMonthButton.removeFromSuperview()
            }
        }
    }
    
    //important!: only change the text, can't disturb the order
    open var weekdayTitles = ["日", "一", "二", "三", "四", "五", "六"] {
        didSet {
            weekdayLabels.forEach { (label: UILabel) in
                let i = weekdayLabels.index(of: label)!
                label.text = weekdayTitles[i]
            }
        }
    }
    
    open var weekdayFont = UIFont.boldSystemFont(ofSize: 14) {
        didSet {
            weekdayLabels.forEach { (label: UILabel) in
                label.font = weekdayFont
            }
        }
    }
    
    open var weekdayTextColor = UIColor.lightGray {
        didSet {
            weekdayLabels.forEach { (label: UILabel) in
                label.textColor = weekdayTextColor
            }
        }
    }
    
    open var weekdayHeight: CGFloat = 30 {
        didSet {
            weekdayLabels.forEach { (label: UILabel) in
                label.bs_height = weekdayHeight
            }
        }
    }
    
    open var dayFont = UIFont.boldSystemFont(ofSize: 14)
    
    open var dayTextColor = UIColor.black
    
    open var selectedDayTextColor = UIColor.white
    
    open var weekendDayTextColor = UIColor.lightGray
    
    open var futureDayTextColor = UIColor.lightGray
    
    open var roundDayTextColor = UIColor.clear
    
    open var dayHeight: CGFloat = 40
    
    //height change animation duration
    open var animationDuration: TimeInterval = 0.25
    
    open var displayingMonthCalendarHeight: CGFloat {
        get {
            return caculateMonthCollectionItemHeight(displayingMonthItem)
        }
    }
    
    //MARK:items
    open fileprivate(set) var willDisplayMonthItem: BSCalendarMonthItem!
    //this item would be different with 'displayingMonthItem' only when scroll half of size
    open fileprivate(set) var didDisplayMonthItem: BSCalendarMonthItem!
    open fileprivate(set) var displayingMonthItem: BSCalendarMonthItem! {
        didSet {
            if displayingMonthItem != oldValue {
                displayingMonthDidChangeClosure?(displayingMonthItem.month)
            }
        }
    }
    
    //private
    fileprivate var headerHeight: CGFloat {
        return self.monthHeight + self.weekdayHeight
    }
    
    fileprivate var direction: CalendarScrollDirection = .left
    
    fileprivate var shouldSetupFrame = true
    
    fileprivate var lastSelectedDayItem: BSCalendarDayItem?
    
    fileprivate lazy var itemManager = BSCalendarItemManager()
    
    //MARK:UI
    fileprivate lazy var monthLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "\(Date().month)" + "月"
        label.textColor = UIColor.red
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        
        return label
    }()
    
    fileprivate lazy var bs_previousMonthButton: UIButton = {
        let pButton: UIButton = UIButton()
        pButton.setTitleColor(UIColor.black, for: UIControlState())
        pButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        pButton.setImage(UIImage(named: "bs_icon_arrow_left"), for: UIControlState())
        pButton.addTarget(self, action: #selector(BSCalendarView.respondsTobs_previousMonthButton(_:)), for: .touchUpInside)
        return pButton
    }()
    
    fileprivate lazy var bs_nextMonthButton: UIButton = {
        let nButton: UIButton = UIButton()
        nButton.setTitleColor(UIColor.black, for: UIControlState())
        nButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        nButton.setImage(UIImage(named: "bs_icon_arrow_right"), for: UIControlState())
        nButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        nButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: Constants.ButtonWidth - 50 - 5)
        
        nButton.addTarget(self, action: #selector(BSCalendarView.respondsTobs_nextMonthButton(_:)), for: .touchUpInside)
        return nButton
    }()
    
    fileprivate lazy var weekdayLabels: [UILabel] = {
        var labels: [UILabel] = []
        for i in 0..<self.weekdayTitles.count {
            let weekdayLabel: UILabel = UILabel()
            weekdayLabel.text = self.weekdayTitles[i]
            weekdayLabel.textAlignment = .center
            weekdayLabel.font = self.weekdayFont
            weekdayLabel.textColor = self.weekdayTextColor
            labels.append(weekdayLabel)
        }
        return labels
    }()
    
    fileprivate lazy var separator: CAShapeLayer = {
        
        let separator: CAShapeLayer = CAShapeLayer()
        separator.strokeColor = UIColor.lightGray.cgColor
        separator.opacity = 0.5
        
        return separator
    }()
    
    fileprivate lazy var monthCollectionView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        let c : UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        c.register(BSCalendarMonthCollectionCell.self, forCellWithReuseIdentifier: Constants.MonthCollectionReuseCellIdentifier)
        c.dataSource = self
        c.delegate = self
        c.backgroundColor = UIColor.clear
        c.isPagingEnabled = true
        c.showsHorizontalScrollIndicator = false
        return c
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard shouldSetupFrame == true else {
            return
        }
        
        setupFrame()
        scrollToDisplayingMonth()
    }
}

//MARK:Private
extension BSCalendarView {
    
    fileprivate func setupFrame() {
        monthLabel.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: bs_width, height: monthHeight))
        bs_previousMonthButton.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: Constants.ButtonWidth, height: monthHeight))
        bs_nextMonthButton.frame = CGRect(origin: CGPoint(x: bs_width - Constants.ButtonWidth, y: 0), size: bs_previousMonthButton.bs_size)
        
        let weekdayLabelWidth = bs_width/7
        for i in 0..<weekdayTitles.count {
            let weekdayLabel = weekdayLabels[i]
            weekdayLabel.frame = CGRect(x: weekdayLabelWidth * CGFloat(i), y: monthHeight, width: weekdayLabelWidth, height: weekdayHeight)
        }
        separator.path = configureSeparatorPath()
        
        //the calendar max rows is 6
        monthCollectionView.frame = CGRect(x: 0, y: headerHeight , width: bs_width, height: 6 * dayHeight)
        bs_height = caculateMonthCollectionItemHeight(displayingMonthItem)
        heightDidChangeClosure?(bs_height)
        
        monthCollectionView.reloadData()
    }
    
    fileprivate func scrollToDisplayingMonth() {
        
        let index = CGFloat(itemManager.monthItems.index(of: displayingMonthItem)!)
        monthCollectionView.setContentOffset(CGPoint(x: monthCollectionView.bs_width * index, y: 0), animated: false)
    }
    
    fileprivate func setup() {

        backgroundColor = UIColor.white
        setupSubviews()
        setupDisplayMonthItem()
    }
    
    fileprivate func setupSubviews() {
        addSubview(monthLabel)
        addSubview(bs_previousMonthButton)
        addSubview(bs_nextMonthButton)
        weekdayLabels.forEach { (label: UILabel) in
            addSubview(label)
        }
        layer.addSublayer(separator)
        addSubview(monthCollectionView)
    }
    
    fileprivate func setupDisplayMonthItem() {
        
        let maxMonth = itemManager.monthItems.count - 1
        let month = Date().month - 1
        let index = min(month, maxMonth)
        displayingMonthItem = itemManager.monthItems[index]
        didDisplayMonthItem = displayingMonthItem
    }
}

extension BSCalendarView {
    
    fileprivate func update() {
        updateDisplayMonthItem()
        updateViewHeight()
        didDisplayMonthItem = displayingMonthItem
    }
    
    fileprivate func updateDisplayMonthItem() {
        
        let offsetX = monthCollectionView.contentOffset.x
        let width = monthCollectionView.bs_width
        let floatIndex = Float(offsetX/width)
        
        displayingMonthItem = itemManager.monthItems[Int(round(floatIndex))]
        updateMonthText()
    }
    
    fileprivate func updateMonthText() {
        let displayingMonth = displayingMonthItem.month
        monthLabel.text = "\(displayingMonth)月"
        
        bs_previousMonthButton.isHidden = displayingMonth == 1
        bs_nextMonthButton.isHidden = displayingMonth == 12
        
        bs_previousMonthButton.setTitle("\(displayingMonth! - 1)月", for: UIControlState())
        bs_nextMonthButton.setTitle("\(displayingMonth! + 1)月", for: UIControlState())
        
        let isFutureMonth = displayingMonth! >= itemManager.monthItems.count
        bs_nextMonthButton.isEnabled = !isFutureMonth
        if isFutureMonth == true {
            bs_nextMonthButton.setTitleColor(UIColor.gray, for: UIControlState())
        } else {
            bs_nextMonthButton.setTitleColor(UIColor.black, for: UIControlState())
        }
    }
    
    fileprivate func updateViewHeight() {
        
        let height = caculateMonthCollectionItemHeight(displayingMonthItem)
        
        let animations = {
            self.bs_height = height
        }
        let completion: ((Bool) -> Void) = { [unowned self] _ in
            self.heightDidChangeClosure?(height)
            
        }
        UIView.animate(withDuration: animationDuration, animations: animations, completion: completion)
    }
    
    
    fileprivate func changeHeightContinuous() {
        let scrollView: UIScrollView = monthCollectionView
        
        guard scrollView.contentOffset.x < scrollView.contentSize.width else {
            return
        }
        
        guard scrollView.contentOffset.x > 0 else {
            return
        }
        
        let fraction = scrollView.contentOffset.x / scrollView.bs_width
        var percentage: CGFloat = 0
        if direction == .right {
            percentage = fraction - floor(fraction)
        } else {
            percentage = 1 - (fraction - floor(fraction))
        }
        
        guard percentage >= 0.01 && percentage <= 0.99 else {
            return
        }
        
        let willChangeHeight = caculateMonthCollectionItemHeight(willDisplayMonthItem)
        let didDisplayHeight = caculateMonthCollectionItemHeight(didDisplayMonthItem)
        let subHeight = willChangeHeight - didDisplayHeight
        
        bs_height = didDisplayHeight + subHeight * percentage
        
        heightDidChangeClosure?(bs_height)
        scrollXPercentageClosure?(percentage)
    }
}

extension BSCalendarView {
    
    func respondsTobs_previousMonthButton(_ button: UIButton) {
        shouldSetupFrame = false
        
        let displayingMonth = displayingMonthItem.month
        let bs_previousMonth = displayingMonth! - 1
        let targetIndex = CGFloat(bs_previousMonth - monthRange.location)
        monthCollectionView.setContentOffset(CGPoint(x: monthCollectionView.bs_width * targetIndex, y: 0), animated: true)
    }
    
    func respondsTobs_nextMonthButton(_ button: UIButton) {
        shouldSetupFrame = false
        
        let displayingMonth = displayingMonthItem.month
        let bs_nextMonth = displayingMonth! + 1
        let targetIndex = CGFloat(bs_nextMonth - monthRange.location)
        monthCollectionView.setContentOffset(CGPoint(x: monthCollectionView.bs_width * targetIndex, y: 0), animated: true)
    }
}

//MARK:Help
extension BSCalendarView {
    
    fileprivate func caculateMonthCollectionItemHeight(_ item: BSCalendarMonthItem) -> CGFloat {
        return CGFloat(ceil(Double(item.dayItems.count)/7)) * dayHeight +
            headerHeight +
            Constants.BottomInset
    }
    
    fileprivate func configureSeparatorPath() -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0,
            y: self.headerHeight))
        path.addLine(to: CGPoint(x: self.bs_width,
            y: self.headerHeight))
        
        return path.cgPath;
    }
}

extension BSCalendarView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemManager.monthItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.MonthCollectionReuseCellIdentifier, for: indexPath) as! BSCalendarMonthCollectionCell
        
        cell.themeColor = themeColor
        
        cell.separatorHidden = separatorHidden
        
        cell.dayFont = dayFont
        
        cell.dayTextColor = dayTextColor
        cell.selectedDayTextColor = selectedDayTextColor
        cell.weekendDayTextColor = weekendDayTextColor
        cell.futureDayTextColor = futureDayTextColor
        cell.roundDayTextColor = roundDayTextColor
        
        cell.dayHeight = dayHeight
        cell.monthItem = itemManager.monthItems[indexPath.row]
        
        cell.dayDidSelectedClosure = { [unowned self] dayItem in
            self.dayDidSelectedClosure?(dayItem)

            if self.lastSelectedDayItem != dayItem {
                self.lastSelectedDayItem?.isSelectedDay = false
            }
            self.lastSelectedDayItem = dayItem
        }
        
        return cell
    }
}

extension BSCalendarView: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        willDisplayMonthItem = itemManager.monthItems[indexPath.row]
        
        let displayingIndexPath = IndexPath(row: itemManager.monthItems.index(of: displayingMonthItem)!, section: 0)

        let sub = indexPath.row - displayingIndexPath.row
        //if to right
        if sub > 0 {
            direction = .right
            //to left
        } else {
            direction = .left
        }
    }
}

extension BSCalendarView: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        update()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        update()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        updateDisplayMonthItem()
        changeHeightContinuous()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        shouldSetupFrame = false
    }
}

extension BSCalendarView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bs_size
    }
}





