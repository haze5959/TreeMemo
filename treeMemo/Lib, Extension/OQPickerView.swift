//
//  OQPickerView.swift
//  OQ
//
//  Created by Lee OQ on 2016. 3. 16..
//  Copyright © 2016년 Kwan. All rights reserved.
//

import UIKit

/**
 픽커뷰
 - OQ
 */
final class OQPickerView:
UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    private var dialogView: UIView!
    private var isDate: Bool = true
    private var defaultDate: Date?
    private var titleLabel: UILabel!
    private var doneButton: UIButton!
    private var cancelButton: UIButton!
    private var callback: PickerCallback?
    private var datePicker: UIDatePicker!
    private var defaultPicker: UIPickerView!
    private var datePickerMode: UIDatePicker.Mode?
    private var dateCallback: DatePickerCallback?
    private var selectIndex = [Int]()
    private let kDatePickerDialogDoneButtonTag: Int = 1
    private var selectString = [String]()
    private let kDatePickerDialogCornerRadius: CGFloat = 7
    private var dataString = [[String]]()
    private let kDatePickerButtonHeight: CGFloat = 50
    private let kDatePickerButtonSpacerHeight: CGFloat = 1
    
    public typealias DatePickerCallback = (_ date: Date) -> Void
    public typealias PickerCallback = (_ string: [String], _ index: [Int]) -> Void
    
    public init() {
        if let window = UIWindow.keyWindow {
            let screenWidth = window.frame.width
            let screenHeight = window.frame.height
            super.init(frame: CGRect(x: 0,
                                     y: 0,
                                     width: screenWidth,
                                     height: screenHeight))
        } else {
            let screenWidth = UIScreen.main.bounds.size.width
            let screenHeight = UIScreen.main.bounds.size.height
            super.init(frame: CGRect(x: 0,
                                     y: 0,
                                     width: screenWidth,
                                     height: screenHeight))
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.dialogView = self.createContainerView()
        self.dialogView!.layer.shouldRasterize = true
        self.dialogView!.layer.rasterizationScale = UIScreen.main.scale
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        self.dialogView!.layer.opacity = 0.5
        self.dialogView!.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
        self.selectIndex.removeAll()
        self.selectString.removeAll()
        self.dataString.removeAll()
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.addSubview(self.dialogView!)
    }
    
    /**
     데이트 피커
     - Parameter title: 타이틀
     - Parameter doneButtonTitle: 확인 버튼 문자 default: '확인'
     - Parameter cancelButtonTitle: 취소 버튼 문자 default: '취소'
     - Parameter defaultDate: 처음 선택될 날짜
     - Parameter datePickerMode: 타임피커 형식 ex) time, date, dateAndTime, countDownTimer
     - Parameter callback: 완료 후 콜백
     - Returns: Date
     */
    public func showDate(title: String,
                         doneButtonTitle: String = "확인",
                         cancelButtonTitle: String = "취소",
                         defaultDate: Date = Date(),
                         datePickerMode: UIDatePicker.Mode = .date,
                         callback: @escaping DatePickerCallback) {
        self.isDate = true
        self.datePickerMode = datePickerMode
        self.setupView()
        self.titleLabel.text = title
        self.doneButton.setTitle(doneButtonTitle, for: .normal)
        self.cancelButton.setTitle(cancelButtonTitle, for: .normal)
        self.dateCallback = callback
        self.defaultDate = defaultDate
        self.datePicker.datePickerMode = self.datePickerMode ?? .date
        self.datePicker.date = (self.defaultDate ?? Date()) as Date
        
        UIApplication.shared.windows.first!.addSubview(self)
        UIApplication.shared.windows.first!.endEditing(true)
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: { () -> Void in
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            self.dialogView!.layer.opacity = 1
            self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
            },
            completion: nil
        )
    }
    
    /**
     아이템 피커
     - Parameter title: 타이틀
     - Parameter doneButtonTitle: 확인 버튼 문자 default: '확인'
     - Parameter cancelButtonTitle: 취소 버튼 문자 default: '취소'
     - Parameter items: 각각의 아이템:[[String]]
     - Parameter selectIndex: 각각의 인덱스:[Int]
     - Parameter callback: 완료 후 콜백
     - Returns: string: 각각의 아이템:[String], 각각의 인덱스:[Int]
     */
    public func show(title: String,
                     doneButtonTitle: String = "확인",
                     cancelButtonTitle: String = "취소",
                     items: [[String]],
                     selectIndex: [Int],
                     callback: @escaping PickerCallback) {
        self.isDate = false
        self.setupView()
        self.titleLabel.text = title
        self.doneButton.setTitle(doneButtonTitle, for: .normal)
        self.cancelButton.setTitle(cancelButtonTitle, for: .normal)
        self.callback = callback
        if items.count == 0 {
            self.dataString = [["내용이 없습니다."]]
            self.selectIndex = [0]
            self.selectString = self.dataString[0]
            self.defaultPicker.reloadAllComponents()
        } else {
            self.dataString = items
            self.selectIndex = selectIndex
            for (index, select) in self.selectIndex.enumerated() {
                self.selectString.append(self.dataString[index][select])
                self.defaultPicker.reloadAllComponents()
                self.defaultPicker.selectRow(select, inComponent: index, animated: true)
            }
        }
        
        UIApplication.shared.windows.first!.addSubview(self)
        UIApplication.shared.windows.first!.endEditing(true)
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: { () -> Void in
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            self.dialogView!.layer.opacity = 1
            self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
            },
            completion: nil
        )
    }
    
    private func close() {
        let currentTransform = self.dialogView.layer.transform
        let startRotation = (self.value(forKeyPath: "layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + Double.pi * 270 / 180), 0, 0, 0)
        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1
        
        UIView.animate(withDuration: 0.2, delay: 0, animations: { () -> Void in
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
            self.dialogView.layer.opacity = 0
        }) { (_) -> Void in
            for view in self.subviews {
                view.removeFromSuperview()
            }
            self.removeFromSuperview()
        }
    }
    
    private func createContainerView() -> UIView {
        let titleHeight: CGFloat = 30
        let screenSize = self.countScreenSize()
        var dialogSize = CGSize(width: 300, height: 230 + kDatePickerButtonHeight + kDatePickerButtonSpacerHeight)
        self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        let dialogContainer = UIView()
        
        if self.isDate == true {
            self.datePicker = UIDatePicker(frame: CGRect(x: 0, y: 30, width: 0, height: 0))
            self.datePicker.autoresizingMask = UIView.AutoresizingMask.flexibleRightMargin
            
            if #available(iOS 14.0, *) {
                switch self.datePickerMode {
                case .time:
                    self.datePicker.preferredDatePickerStyle = .wheels
                    self.datePicker.frame.size.width = 300
                case .dateAndTime:
                    let margin: CGFloat = 20
                    self.datePicker.preferredDatePickerStyle = .inline
                    dialogSize.width = self.datePicker.frame.width + margin
                    dialogSize.height = self.datePicker.frame.height + kDatePickerButtonHeight + kDatePickerButtonSpacerHeight + titleHeight + margin
                    self.datePicker.frame.origin.y = titleHeight + margin / 2
                    self.datePicker.frame.origin.x = margin / 2
                default:
                    let margin: CGFloat = 20
                    self.datePicker.preferredDatePickerStyle = .inline
                    dialogSize.width = self.datePicker.frame.width + margin
                    dialogSize.height = self.datePicker.frame.height + kDatePickerButtonHeight + kDatePickerButtonSpacerHeight + titleHeight
                    self.datePicker.frame.origin.y = titleHeight
                    self.datePicker.frame.origin.x = margin / 2
                }
            } else {
                self.datePicker.frame.size.width = 300
            }
            
            dialogContainer.addSubview(self.datePicker)
        } else {
            self.defaultPicker = UIPickerView(frame: CGRect(x: 0, y: 30, width: 0, height: 0))
            self.defaultPicker.autoresizingMask = UIView.AutoresizingMask.flexibleRightMargin
            self.defaultPicker.frame.size.width = 300
            self.defaultPicker.delegate = self
            self.defaultPicker.dataSource = self
            dialogContainer.addSubview(self.defaultPicker)
            
        }
        
        dialogContainer.frame = CGRect(x: (screenSize.width - dialogSize.width) / 2,
                                       y: (screenSize.height - dialogSize.height) / 2,
                                       width: dialogSize.width,
                                       height: dialogSize.height)
        
        let gradient: CAGradientLayer = CAGradientLayer(layer: self.layer)
        gradient.frame = dialogContainer.bounds
        gradient.colors = [UIColor(red: 218/255,
                                   green: 218/255,
                                   blue: 218/255,
                                   alpha: 1).cgColor,
                           UIColor(red: 233/255,
                                   green: 233/255,
                                   blue: 233/255,
                                   alpha: 1).cgColor,
                           UIColor(red: 218/255,
                                   green: 218/255,
                                   blue: 218/255,
                                   alpha: 1).cgColor]
        
        let cornerRadius = kDatePickerDialogCornerRadius
        gradient.cornerRadius = cornerRadius
        dialogContainer.layer.insertSublayer(gradient, at: 0)
        
        dialogContainer.layer.cornerRadius = cornerRadius
        dialogContainer.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).cgColor
        dialogContainer.layer.borderWidth = 1
        dialogContainer.layer.shadowRadius = cornerRadius + 5
        dialogContainer.layer.shadowOpacity = 0.1
        dialogContainer.layer.shadowOffset = CGSize(width: 0 - (cornerRadius + 5) / 2,
                                                    height: 0 - (cornerRadius + 5) / 2)
        dialogContainer.layer.shadowColor = UIColor.black.cgColor
        dialogContainer.layer.shadowPath = UIBezierPath(roundedRect: dialogContainer.bounds,
                                                        cornerRadius: dialogContainer.layer.cornerRadius).cgPath
        
        let lineView = UIView(frame: CGRect(x: 0,
                                            y: dialogContainer.bounds.size.height
                                                - kDatePickerButtonHeight
                                                - kDatePickerButtonSpacerHeight,
                                            width: dialogContainer.bounds.size.width,
                                            height: kDatePickerButtonSpacerHeight))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        dialogContainer.addSubview(lineView)
        
        self.titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: dialogSize.width, height: titleHeight))
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        dialogContainer.addSubview(self.titleLabel)
        
        self.addButtonsToView(container: dialogContainer)
        
        return dialogContainer
    }
    
    private func addButtonsToView(container: UIView) {
        let buttonWidth = container.bounds.size.width / 2
        
        self.cancelButton = UIButton(type: UIButton.ButtonType.custom) as UIButton
        self.cancelButton.frame = CGRect(x: 0,
                                         y: container.bounds.size.height - kDatePickerButtonHeight,
                                         width: buttonWidth,
                                         height: kDatePickerButtonHeight)
        self.cancelButton.setTitleColor(UIColor(red: 0,
                                                green: 0.5,
                                                blue: 1,
                                                alpha: 1),
                                        for: UIControl.State.normal)
        self.cancelButton.setTitleColor(UIColor(red: 0.2,
                                                green: 0.2,
                                                blue: 0.2,
                                                alpha: 0.5),
                                        for: UIControl.State.highlighted)
        self.cancelButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        self.cancelButton.layer.cornerRadius = kDatePickerDialogCornerRadius
        self.cancelButton.addTarget(self,
                                    action: #selector(OQPickerView.buttonTapped(_:)),
                                    for: UIControl.Event.touchUpInside)
        container.addSubview(self.cancelButton)
        
        self.doneButton = UIButton(type: UIButton.ButtonType.custom) as UIButton
        self.doneButton.frame = CGRect(x: buttonWidth,
                                       y: container.bounds.size.height - kDatePickerButtonHeight,
                                       width: buttonWidth,
                                       height: kDatePickerButtonHeight)
        self.doneButton.tag = kDatePickerDialogDoneButtonTag
        self.doneButton.setTitleColor(UIColor(red: 0,
                                              green: 0.5,
                                              blue: 1,
                                              alpha: 1),
                                      for: UIControl.State.normal)
        self.doneButton.setTitleColor(UIColor(red: 0.2,
                                              green: 0.2,
                                              blue: 0.2,
                                              alpha: 0.5),
                                      for: UIControl.State.highlighted)
        self.doneButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        self.doneButton.layer.cornerRadius = kDatePickerDialogCornerRadius
        self.doneButton.addTarget(self,
                                  action: #selector(OQPickerView.buttonTapped(_:)),
                                  for: UIControl.Event.touchUpInside)
        container.addSubview(self.doneButton)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        if sender.tag == kDatePickerDialogDoneButtonTag {
            if self.isDate {
                self.dateCallback?(self.datePicker.date)
            } else {
                self.callback?(self.selectString, self.selectIndex)
            }
        }
        self.close()
    }
    
    private func countScreenSize() -> CGSize {
        if let window = UIWindow.keyWindow {
            let screenWidth = window.frame.width
            let screenHeight = window.frame.height
            return CGSize(width: screenWidth, height: screenHeight)
        } else {
            let screenWidth = UIScreen.main.bounds.size.width
            let screenHeight = UIScreen.main.bounds.size.height
            return CGSize(width: screenWidth, height: screenHeight)
        }
    }
    
    // MARK: - UIPickerViewDataSource
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.dataString.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataString[component].count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dataString[component][row]
    }
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectIndex[component] = row
        self.selectString[component] = self.dataString[component][row]
        
    }
}
