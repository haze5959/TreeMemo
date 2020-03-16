//
//  OQImageViewController.swift
//  treeMemo
//
//  Created by OQ on 2019/12/29.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import UIKit
import Combine

class OQImageViewController: UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cropOrRotateBtn: UIButton!
    @IBOutlet weak var removeOrSaveBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    let cropPickerView = CropPickerView()
    
    var image: UIImage!
    var saveClosure: ((UIImage?) -> Void)?
    @Published var isCropMode = false
    var isEdited = false
    
    private var cancellableBag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
        self.setBindings()
    }
}

//MARK: initView, Bindings, setCropMode, setImageViewMode
extension OQImageViewController {
    func initView() {
        DispatchQueue.main.async {
            self.cropPickerView.frame = self.mainView.bounds
            self.cropPickerView.translatesAutoresizingMaskIntoConstraints = false
            
            self.mainView.addSubview(self.cropPickerView)
            
            self.cropPickerView.leftAnchor.constraint(equalTo: self.mainView.leftAnchor).isActive = true
            self.cropPickerView.topAnchor.constraint(equalTo: self.mainView.topAnchor).isActive = true
            self.cropPickerView.rightAnchor.constraint(equalTo: self.mainView.rightAnchor).isActive = true
            self.cropPickerView.bottomAnchor.constraint(equalTo: self.mainView.bottomAnchor).isActive = true
            
            self.cropPickerView.image = self.image.rotate(radians: 0)
        }
        
        self.setScrollHideGesture()
    }
    
    func setBindings() {
        self.cropOrRotateBtn.publisher(for: .touchUpInside)
            .sink { button in
                if self.isCropMode {    //이미지 회전시키기
                    self.cropPickerView.image = self.cropPickerView.image?.rotate(radians: .pi/2)
                } else {    //크롭모드 전환
                    self.isCropMode = true
                }
        }.store(in: &self.cancellableBag)
        
        self.closeBtn.publisher(for: .touchUpInside)
            .sink { button in
                if self.isCropMode {
                    self.cropPickerView.image = self.image
                    self.isCropMode = false
                } else {    //화면 닫기
                    if self.isEdited {
                        self.saveClosure?(self.image)
                    }
                    
                    self.dismiss(animated: true)
                }
        }.store(in: &self.cancellableBag)
        
        self.shareBtn.publisher(for: .touchUpInside)
            .sink { button in
                // set up activity view controller
                let imageToShare = [ self.image ]
                let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

                // present the view controller
                self.present(activityViewController, animated: true, completion: nil)
        }.store(in: &self.cancellableBag)
        
        self.removeOrSaveBtn.publisher(for: .touchUpInside)
            .sink { button in
                if self.isCropMode {    //이미지 저장
                    //저장 로직
                    self.cropPickerView.crop { (error, image) in
                        if let error = (error as NSError?) {
                            let alertController = UIAlertController(title: "Error", message: error.domain, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                            return
                        }
                        
                        self.image = image
                        self.cropPickerView.image = image
                        self.isEdited = true
                    }
                    self.isCropMode = false
                } else {    //이미지 삭제
                    let alertController = UIAlertController(title: "", message: "Are you sure you want to delete the image?", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        self.saveClosure?(nil)
                        self.dismiss(animated: true)
                    }))
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
        }.store(in: &self.cancellableBag)
        
        self.$isCropMode.sink { (isCropMode) in
            if isCropMode {
                self.setCropMode()
            } else {
                self.setImageViewMode()
            }
        }.store(in: &self.cancellableBag)
    }
    
    func setCropMode() {
        self.cropPickerView.isCrop = true
        self.removeOrSaveBtn.setTitle("Save", for: .normal)
        self.cropOrRotateBtn.setImage(UIImage(systemName: "rotate.right"), for: .normal)
    }
    
    func setImageViewMode() {
        self.cropPickerView.isCrop = false
        self.removeOrSaveBtn.setTitle("Remove", for: .normal)
        self.cropOrRotateBtn.setImage(UIImage(systemName: "crop"), for: .normal)
    }
}

// MARK: 숨김 제스쳐 설정 관련
extension OQImageViewController {
    func setScrollHideGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleSheetViewGesture))
        self.view.addGestureRecognizer(panGesture)
    }
    
    @IBAction func handleSheetViewGesture(recognizer: UIPanGestureRecognizer) {
        if !self.isCropMode {
            switch recognizer.state {
            case .began:
                break
            case .ended:
                DispatchQueue.main.async {
                    if self.view.frame.origin.y > 150 {  // 해당 값만큼 더 스크롤을 내렸다면
                        UIView.animate(withDuration: 0.2, animations: {
                            self.view.frame.origin.y = self.view.frame.height
                        }, completion: { _ in
                            if self.isEdited {
                                self.saveClosure?(self.image)
                            }
                            self.dismiss(animated: true)
                        })
                    } else {
                        UIView.animate(withDuration: 0.2, animations: { () -> Void in
                            self.view.frame.origin.y = 0
                        })
                    }
                }
            default:
                let translation = recognizer.translation(in: self.view)
                self.view.frame.origin.y += translation.y
                recognizer.setTranslation(CGPoint.zero, in: self.view)
            }
        }
    }
}
