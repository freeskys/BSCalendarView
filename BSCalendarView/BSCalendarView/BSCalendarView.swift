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
    private static let BottomInset: CGFloat = 5
    private static let MonthCollectionReuseCellIdentifier = "BSCalendarCollectionCell"
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
    //location range (1, 12), length range(0, 11)
    public var monthRange: NSRange = NSRange(location: 1, length: NSDate().month() - 1) {
        didSet {
            itemManager.monthRange = monthRange
            monthCollectionView.reloadData()
        }
    }
    
    public var monthHeight: CGFloat = 40 {
        didSet {
            if monthHeight == 0 {
                previousMonthButton.removeFromSuperview()
                nextMonthButton.removeFromSuperview()
            }

            monthLabel.bs_height = monthHeight
            previousMonthButton.bs_height = monthHeight
            nextMonthButton.bs_height = monthHeight
            weekdayLabels.forEach { (label: UILabel) in
                label.bs_origin.y = monthHeight
            }
            separator.path = self.configureSeparatorPath()
            monthCollectionView.bs_origin.y = headerHeight
            bs_height = caculateMonthCollectionItemHeight(displayingMonthItem)
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
            separator.path = self.configureSeparatorPath()
            monthCollectionView.bs_origin.y = headerHeight
            bs_height = caculateMonthCollectionItemHeight(displayingMonthItem)
        }
    }
    
    public var dayTextColor = UIColor.blackColor() {
        didSet {
            monthCollectionView.reloadData()
        }
    }
    
    public var selectedDayTextColor = UIColor.whiteColor() {
        didSet {
            monthCollectionView.reloadData()
        }
    }
    
    public var weekendDayTextColor = UIColor.lightGrayColor() {
        didSet {
            monthCollectionView.reloadData()
        }
    }
    
    public var futureDayTextColor = UIColor.lightGrayColor() {
        didSet {
            monthCollectionView.reloadData()
        }
    }
    
    public var roundDayTextColor = UIColor.clearColor() {
        didSet {
            monthCollectionView.reloadData()
        }
    }
    
    public var dayHeight: CGFloat = 40 {
        didSet {
            monthCollectionView.reloadData()
            bs_height = caculateMonthCollectionItemHeight(displayingMonthItem)
        }
    }
    
    //height change animation duration
    public var animationDuration: NSTimeInterval = 0.25
    
    //MARK:items
    public var willDisplayMonthItem: BSCalendarMonthItem!
    //this item would be different with 'displayingMonthItem' only when scroll half of size
    public var didDisplayMonthItem: BSCalendarMonthItem!
    public var displayingMonthItem: BSCalendarMonthItem! {
        didSet {
            displayingMonthDidChangeClosure?(month: displayingMonthItem.month)
        }
    }
    
    //private
    private var headerHeight: CGFloat {
        return self.monthHeight + self.weekdayHeight
    }
    
    private var direction: CalendarScrollDirection = .Left
    
    private var didSelectedDayItem: BSCalendarDayItem!
    
    private lazy var itemManager = BSCalendarItemManager()
    
    private lazy var monthItems: [BSCalendarMonthItem] = self.itemManager.monthItems
    
    //MARK:UI
    private lazy var monthLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect(origin: CGPointZero, size: CGSize(width: self.bs_width, height: self.monthHeight)))
        label.text = "\(NSDate().month())" + "月"
        label.textColor = UIColor.redColor()
        label.font = UIFont.boldSystemFontOfSize(16)
        label.textAlignment = .Center
        
        return label
    }()
    
    private lazy var previousMonthButton: UIButton = {
        let pButton: UIButton = UIButton(frame: CGRect(origin: CGPointZero, size: CGSize(width: 80, height: self.monthHeight)))
        pButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        pButton.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        pButton.setImage(UIImage(named: "bs_icon_arrow_left"), forState: .Normal)
        pButton.addTarget(self, action: #selector(BSCalendarView.handlePreviousMonthButton(_:)), forControlEvents: .TouchUpInside)
        return pButton
    }()
    
    private lazy var nextMonthButton: UIButton = {
        let nButton: UIButton = UIButton(frame: CGRect(
            origin: CGPoint(x: self.bs_width - 80, y: 0),
            size: self.previousMonthButton.bs_size))
        nButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        nButton.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        
        nButton.setImage(UIImage(named: "bs_icon_arrow_right"), forState: .Normal)
        nButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        nButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
        nButton.addTarget(self, action: #selector(BSCalendarView.handleNextMonthButton(_:)), forControlEvents: .TouchUpInside)
        return nButton
    }()
    
    private lazy var weekdayLabels: [UILabel] = {
        var labels: [UILabel] = []
        let weekdayLabelWidth = self.bs_width/7
        for i in 0..<self.weekdayTitles.count {
            let weekdayLabel: UILabel = UILabel(frame:CGRect(x: weekdayLabelWidth * CGFloat(i),
                y: self.monthHeight,
                width: weekdayLabelWidth,
                height: self.weekdayHeight))
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
        separator.path = self.configureSeparatorPath()
        return separator
    }()
    
    private lazy var monthCollectionView: UICollectionView = {
        
        let screenBounds = UIScreen.mainScreen().bounds
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.estimatedItemSize = CGSize(width: self.bs_width, height: screenBounds.height)
        flowLayout.scrollDirection = .Horizontal
        flowLayout.itemSize = CGSize(width: self.bs_width, height: screenBounds.height)
        
        let c : UICollectionView = UICollectionView(frame: CGRect(x: 0,
            y: self.headerHeight ,
            width: self.bs_width,
            height: screenBounds.height)
            , collectionViewLayout: flowLayout)
        c.registerClass(BSCalendarMonthCollectionCell.self, forCellWithReuseIdentifier: Constants.MonthCollectionReuseCellIdentifier)
        c.dataSource = self
        c.delegate = self
        c.backgroundColor = UIColor.clearColor()
        c.pagingEnabled = true
        return c
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

//MARK:Private
extension BSCalendarView {
    
    func setup() {

        backgroundColor = UIColor.whiteColor()
        
        let maxMonth = monthItems.count - 1
        let month = NSDate().month() - 1
        let index = min(month, maxMonth)
        displayingMonthItem = monthItems[index]
        didDisplayMonthItem = displayingMonthItem
        
        updateMonthText()
        
        bs_height = caculateMonthCollectionItemHeight(displayingMonthItem)
        setupSubviews()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.scrollToCorrectMonth()
        }
    }
    
    func setupSubviews() {
        layoutIfNeeded()
        
        addSubview(monthLabel)
        addSubview(previousMonthButton)
        addSubview(nextMonthButton)
        weekdayLabels.forEach { (label: UILabel) in
            addSubview(label)
        }
        layer.addSublayer(separator)
        addSubview(monthCollectionView)
    }
    
    func scrollToCorrectMonth() {
        
        let index = CGFloat(monthItems.indexOf(displayingMonthItem)!)
        monthCollectionView.setContentOffset(CGPoint(x: monthCollectionView.bs_width * index, y: 0), animated: false)
    }
    
    func update() {
        
        updateDisplayMonth()
        updateMonthText()
        updateHeight()
        didDisplayMonthItem = displayingMonthItem
    }
    
    func updateDisplayMonth() {
        
        let offsetX = monthCollectionView.contentOffset.x
        let width = monthCollectionView.bs_width
        let floatIndex = Float(offsetX/width)
        
        displayingMonthItem = monthItems[Int(round(floatIndex))]
    }
    
    func updateMonthText() {
        let displayingMonth = displayingMonthItem.month
        monthLabel.text = "\(displayingMonth)月"
        
        previousMonthButton.hidden = displayingMonth == 1
        nextMonthButton.hidden = displayingMonth == 12
        
        previousMonthButton.setTitle("\(displayingMonth - 1)月", forState: .Normal)
        nextMonthButton.setTitle("\(displayingMonth + 1)月", forState: .Normal)
        
        let isFutureMonth = displayingMonth >= monthItems.count
        nextMonthButton.enabled = !isFutureMonth
        if isFutureMonth == true {
            nextMonthButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        } else {
            nextMonthButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        }
    }
    
    func updateHeight() {
        
        let height = caculateMonthCollectionItemHeight(displayingMonthItem)
        
        let animations = {
            self.bs_height = height
        }
        let completion: ((Bool) -> Void) = { [unowned self] _ in
            self.heightDidChangeClosure?(height: height)
            
        }
        UIView.animateWithDuration(animationDuration, animations: animations, completion: completion)
    }
    
    
    func changeHeightContinuous() {
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
    
    func handlePreviousMonthButton(button: UIButton) {
        let displayingMonth = displayingMonthItem.month
        let previousMonth = displayingMonth - 1
        let targetIndex = CGFloat(previousMonth - monthRange.location)
        monthCollectionView.setContentOffset(CGPointMake(monthCollectionView.bs_width * targetIndex, 0), animated: true)
    }
    
    func handleNextMonthButton(button: UIButton) {
        let displayingMonth = displayingMonthItem.month
        let nextMonth = displayingMonth + 1
        let targetIndex = CGFloat(nextMonth - monthRange.location)
        monthCollectionView.setContentOffset(CGPointMake(monthCollectionView.bs_width * targetIndex, 0), animated: true)
    }
}

//MARK:Help
extension BSCalendarView {
    
    func caculateMonthCollectionItemHeight(item: BSCalendarMonthItem) -> CGFloat {
        return CGFloat(ceil(Double(item.dayItems.count)/7)) * dayHeight +
            headerHeight +
            Constants.BottomInset
    }
    
    func configureSeparatorPath() -> CGPath {
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
        return monthItems.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.MonthCollectionReuseCellIdentifier, forIndexPath: indexPath) as! BSCalendarMonthCollectionCell
        
        cell.dayTextColor = dayTextColor
        cell.selectedDayTextColor = selectedDayTextColor
        cell.weekendDayTextColor = weekendDayTextColor
        cell.futureDayTextColor = futureDayTextColor
        cell.roundDayTextColor = roundDayTextColor
        
        cell.dayHeight = dayHeight
        cell.monthItem = monthItems[indexPath.row]
        
        cell.dayDidSelectedClosure = { [unowned self] dayItem in
            self.dayDidSelectedClosure?(dayItem: dayItem)

            if self.didSelectedDayItem != nil && self.didSelectedDayItem != dayItem {
                self.didSelectedDayItem.isSelectedDay = false
            }
            self.didSelectedDayItem = dayItem
        }
        
        return cell
    }
}

extension BSCalendarView: UICollectionViewDelegate {

    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        willDisplayMonthItem = monthItems[indexPath.row]
        
        let displayingIndexPath = NSIndexPath(forRow: monthItems.indexOf(displayingMonthItem)!, inSection: 0)

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
        
        updateDisplayMonth()
        updateMonthText()
        changeHeightContinuous()
    }
}





