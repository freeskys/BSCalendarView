//
//  BSCalendarView.swift
//  VehicleGroup
//
//  Created by 张亚东 on 16/4/26.
//  Copyright © 2016年 doyen. All rights reserved.
//

import UIKit
import DateTools

private enum CalendarScrollDirection {
    case Left
    case Right
}

private struct Constants {
    static let BottomInset: CGFloat = 10
    static let ButtonWidth: CGFloat = 90
    static let MonthCollectionReuseCellIdentifier = "BSCalendarCollectionCell"
}

public typealias DayItemClosure = (dayItem: BSCalendarDayItem) -> Void

public class BSCalendarView: UIView {
    
    //MARK:closure
    public var heightDidChangeClosure: ((height: CGFloat) -> Void)?
    
    //range 0.01 ~ 0.99
    public var scrollXPercentageClosure: ((percentage: CGFloat) -> Void)?
    public var displayingMonthDidChangeClosure: ((month: Int) -> Void)?
    
    public var dayDidSelectedClosure: DayItemClosure?
    
    //MARK:Vars
    public var themeColor = UIColor.redColor() {
        didSet {
            monthLabel.textColor = themeColor
        }
    }
    
    public var separatorHidden = false {
        didSet {
            separator.hidden = separatorHidden
        }
    }
    
    //location range (1, 12), length range(0, 11)
    public var monthRange = NSRange(location: 1, length: NSDate().month() - 1) {
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
    
    public var monthHeight: CGFloat = 40 {
        didSet {
            if monthHeight == 0 {
                bs_previousMonthButton.removeFromSuperview()
                bs_nextMonthButton.removeFromSuperview()
            }
        }
    }
    
    //important!: only change the text, can't disturb the order
    public var weekdayTitles = ["日", "一", "二", "三", "四", "五", "六"] {
        didSet {
            weekdayLabels.forEach { (label: UILabel) in
                let i = weekdayLabels.indexOf(label)!
                label.text = weekdayTitles[i]
            }
        }
    }
    
    public var weekdayFont = UIFont.boldSystemFontOfSize(14) {
        didSet {
            weekdayLabels.forEach { (label: UILabel) in
                label.font = weekdayFont
            }
        }
    }
    
    public var weekdayTextColor = UIColor.lightGrayColor() {
        didSet {
            weekdayLabels.forEach { (label: UILabel) in
                label.textColor = weekdayTextColor
            }
        }
    }
    
    public var weekdayHeight: CGFloat = 30 {
        didSet {
            weekdayLabels.forEach { (label: UILabel) in
                label.bs_height = weekdayHeight
            }
        }
    }
    
    public var dayFont = UIFont.boldSystemFontOfSize(14)
    
    public var dayTextColor = UIColor.blackColor()
    
    public var selectedDayTextColor = UIColor.whiteColor()
    
    public var weekendDayTextColor = UIColor.lightGrayColor()
    
    public var futureDayTextColor = UIColor.lightGrayColor()
    
    public var roundDayTextColor = UIColor.clearColor()
    
    public var dayHeight: CGFloat = 40
    
    //height change animation duration
    public var animationDuration: NSTimeInterval = 0.25
    
    public var displayingMonthCalendarHeight: CGFloat {
        get {
            return caculateMonthCollectionItemHeight(displayingMonthItem)
        }
    }
    
    //MARK:items
    public private(set) var willDisplayMonthItem: BSCalendarMonthItem!
    //this item would be different with 'displayingMonthItem' only when scroll half of size
    public private(set) var didDisplayMonthItem: BSCalendarMonthItem!
    public private(set) var displayingMonthItem: BSCalendarMonthItem! {
        didSet {
            if displayingMonthItem != oldValue {
                displayingMonthDidChangeClosure?(month: displayingMonthItem.month)
            }
        }
    }
    
    //private
    private var headerHeight: CGFloat {
        return self.monthHeight + self.weekdayHeight
    }
    
    private var direction: CalendarScrollDirection = .Left
    
    private var shouldSetupFrame = true
    
    private var lastSelectedDayItem: BSCalendarDayItem?
    
    private lazy var itemManager = BSCalendarItemManager()
    
    //MARK:UI
    private lazy var monthLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "\(NSDate().month())" + "月"
        label.textColor = UIColor.redColor()
        label.font = UIFont.boldSystemFontOfSize(16)
        label.textAlignment = .Center
        
        return label
    }()
    
    private lazy var bs_previousMonthButton: UIButton = {
        let pButton: UIButton = UIButton()
        pButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        pButton.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        pButton.setImage(UIImage(named: "bs_icon_arrow_left"), forState: .Normal)
        pButton.addTarget(self, action: #selector(BSCalendarView.respondsTobs_previousMonthButton(_:)), forControlEvents: .TouchUpInside)
        return pButton
    }()
    
    private lazy var bs_nextMonthButton: UIButton = {
        let nButton: UIButton = UIButton()
        nButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        nButton.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        
        nButton.setImage(UIImage(named: "bs_icon_arrow_right"), forState: .Normal)
        nButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        nButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: Constants.ButtonWidth - 50 - 5)
        
        nButton.addTarget(self, action: #selector(BSCalendarView.respondsTobs_nextMonthButton(_:)), forControlEvents: .TouchUpInside)
        return nButton
    }()
    
    private lazy var weekdayLabels: [UILabel] = {
        var labels: [UILabel] = []
        for i in 0..<self.weekdayTitles.count {
            let weekdayLabel: UILabel = UILabel()
            weekdayLabel.text = self.weekdayTitles[i]
            weekdayLabel.textAlignment = .Center
            weekdayLabel.font = self.weekdayFont
            weekdayLabel.textColor = self.weekdayTextColor
            labels.append(weekdayLabel)
        }
        return labels
    }()
    
    private lazy var separator: CAShapeLayer = {
        
        let separator: CAShapeLayer = CAShapeLayer()
        separator.strokeColor = UIColor.lightGrayColor().CGColor
        separator.opacity = 0.5
        
        return separator
    }()
    
    private lazy var monthCollectionView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .Horizontal
        
        let c : UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        c.registerClass(BSCalendarMonthCollectionCell.self, forCellWithReuseIdentifier: Constants.MonthCollectionReuseCellIdentifier)
        c.dataSource = self
        c.delegate = self
        c.backgroundColor = UIColor.clearColor()
        c.pagingEnabled = true
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
    
    public override func layoutSubviews() {
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
    
    private func setupFrame() {
        monthLabel.frame = CGRect(origin: CGPointZero, size: CGSize(width: bs_width, height: monthHeight))
        bs_previousMonthButton.frame = CGRect(origin: CGPointZero, size: CGSize(width: Constants.ButtonWidth, height: monthHeight))
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
        heightDidChangeClosure?(height: bs_height)
        
        monthCollectionView.reloadData()
    }
    
    private func scrollToDisplayingMonth() {
        
        let index = CGFloat(itemManager.monthItems.indexOf(displayingMonthItem)!)
        monthCollectionView.setContentOffset(CGPoint(x: monthCollectionView.bs_width * index, y: 0), animated: false)
    }
    
    private func setup() {

        backgroundColor = UIColor.whiteColor()
        setupSubviews()
        setupDisplayMonthItem()
    }
    
    private func setupSubviews() {
        addSubview(monthLabel)
        addSubview(bs_previousMonthButton)
        addSubview(bs_nextMonthButton)
        weekdayLabels.forEach { (label: UILabel) in
            addSubview(label)
        }
        layer.addSublayer(separator)
        addSubview(monthCollectionView)
    }
    
    private func setupDisplayMonthItem() {
        
        let maxMonth = itemManager.monthItems.count - 1
        let month = NSDate().month() - 1
        let index = min(month, maxMonth)
        displayingMonthItem = itemManager.monthItems[index]
        didDisplayMonthItem = displayingMonthItem
    }
}

extension BSCalendarView {
    
    private func update() {
        updateDisplayMonthItem()
        updateViewHeight()
        didDisplayMonthItem = displayingMonthItem
    }
    
    private func updateDisplayMonthItem() {
        
        let offsetX = monthCollectionView.contentOffset.x
        let width = monthCollectionView.bs_width
        let floatIndex = Float(offsetX/width)
        
        displayingMonthItem = itemManager.monthItems[Int(round(floatIndex))]
        updateMonthText()
    }
    
    private func updateMonthText() {
        let displayingMonth = displayingMonthItem.month
        monthLabel.text = "\(displayingMonth)月"
        
        bs_previousMonthButton.hidden = displayingMonth == 1
        bs_nextMonthButton.hidden = displayingMonth == 12
        
        bs_previousMonthButton.setTitle("\(displayingMonth - 1)月", forState: .Normal)
        bs_nextMonthButton.setTitle("\(displayingMonth + 1)月", forState: .Normal)
        
        let isFutureMonth = displayingMonth >= itemManager.monthItems.count
        bs_nextMonthButton.enabled = !isFutureMonth
        if isFutureMonth == true {
            bs_nextMonthButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        } else {
            bs_nextMonthButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        }
    }
    
    private func updateViewHeight() {
        
        let height = caculateMonthCollectionItemHeight(displayingMonthItem)
        
        let animations = {
            self.bs_height = height
        }
        let completion: ((Bool) -> Void) = { [unowned self] _ in
            self.heightDidChangeClosure?(height: height)
            
        }
        UIView.animateWithDuration(animationDuration, animations: animations, completion: completion)
    }
    
    
    private func changeHeightContinuous() {
        let scrollView: UIScrollView = monthCollectionView
        
        guard scrollView.contentOffset.x < scrollView.contentSize.width else {
            return
        }
        
        guard scrollView.contentOffset.x > 0 else {
            return
        }
        
        let fraction = scrollView.contentOffset.x / scrollView.bs_width
        var percentage: CGFloat = 0
        if direction == .Right {
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
        
        heightDidChangeClosure?(height: bs_height)
        scrollXPercentageClosure?(percentage: percentage)
    }
}

extension BSCalendarView {
    
    func respondsTobs_previousMonthButton(button: UIButton) {
        shouldSetupFrame = false
        
        let displayingMonth = displayingMonthItem.month
        let bs_previousMonth = displayingMonth - 1
        let targetIndex = CGFloat(bs_previousMonth - monthRange.location)
        monthCollectionView.setContentOffset(CGPointMake(monthCollectionView.bs_width * targetIndex, 0), animated: true)
    }
    
    func respondsTobs_nextMonthButton(button: UIButton) {
        shouldSetupFrame = false
        
        let displayingMonth = displayingMonthItem.month
        let bs_nextMonth = displayingMonth + 1
        let targetIndex = CGFloat(bs_nextMonth - monthRange.location)
        monthCollectionView.setContentOffset(CGPointMake(monthCollectionView.bs_width * targetIndex, 0), animated: true)
    }
}

//MARK:Help
extension BSCalendarView {
    
    private func caculateMonthCollectionItemHeight(item: BSCalendarMonthItem) -> CGFloat {
        return CGFloat(ceil(Double(item.dayItems.count)/7)) * dayHeight +
            headerHeight +
            Constants.BottomInset
    }
    
    private func configureSeparatorPath() -> CGPath {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0,
            y: self.headerHeight))
        path.addLineToPoint(CGPoint(x: self.bs_width,
            y: self.headerHeight))
        
        return path.CGPath;
    }
}

extension BSCalendarView: UICollectionViewDataSource {
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemManager.monthItems.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.MonthCollectionReuseCellIdentifier, forIndexPath: indexPath) as! BSCalendarMonthCollectionCell
        
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
            self.dayDidSelectedClosure?(dayItem: dayItem)

            if self.lastSelectedDayItem != dayItem {
                self.lastSelectedDayItem?.isSelectedDay = false
            }
            self.lastSelectedDayItem = dayItem
        }
        
        return cell
    }
}

extension BSCalendarView: UICollectionViewDelegate {

    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        willDisplayMonthItem = itemManager.monthItems[indexPath.row]
        
        let displayingIndexPath = NSIndexPath(forRow: itemManager.monthItems.indexOf(displayingMonthItem)!, inSection: 0)

        let sub = indexPath.row - displayingIndexPath.row
        //if to right
        if sub > 0 {
            direction = .Right
            //to left
        } else {
            direction = .Left
        }
    }
}

extension BSCalendarView: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        update()
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        update()
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        updateDisplayMonthItem()
        changeHeightContinuous()
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        shouldSetupFrame = false
    }
}

extension BSCalendarView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.bs_size
    }
}





