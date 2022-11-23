//
//  ViewController.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/11/18.
//

import UIKit

class CameraViewController: BaseViewController {
    
    @IBOutlet weak var recodingButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    
    //紀錄目前的亮度
    let currentScreenBrightness = UIScreen.main.brightness
    
    //紀錄目前錄影多久的timer
    var timer: Timer?
    
    //紀錄目前錄影多久
    var recodingTime: Int = 0 {
        didSet {
            setupLabelWithTime(time: recodingTime)
        }
    }
    
    //是否正在錄影
    var isRecoding: Bool = false {
        didSet {
            self.checkRecordButton(isRecording: isRecoding)
            self.setupTimer(isRecording: isRecoding)
        }
    }
    
    var hideSrceen: Bool = false {
        didSet {
            self.fakeHideScreen()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addfakeTapGesture()
        self.defaultSetupRecordButton()
        self.defaultSetupTimeLabel()
    }
    //MARK: - UserDefault

    
    //MARK: - Label
    func defaultSetupTimeLabel() {
        self.timeLabel.font = .systemFont(ofSize: 25)
        self.timeLabel.text = String(format: "%02d:%02d",0 ,0)
    }
    
    func setupLabelWithTime(time: Int) {
        self.timeLabel.text = String(format: "%02d:%02d", time/60 ,time%60)
    }
    
    
    //MARK: - Timer
    func setupTimer(isRecording: Bool) {
        self.recodingTime = 0
        if isRecording {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ [weak self] _ in
                self?.timerAction()
            }
        } else {
            self.timer?.invalidate()
        }
    }
    
    func timerAction() {
        self.recodingTime += 1
    }
    
    
    //MARK: - 錄影按鈕
    func defaultSetupRecordButton() {
        if #available(iOS 15.0, *) {
            self.recodingButton.configuration = nil
        }
        self.recodingButton.addTarget(self, action:#selector(recordButtonAction(_:)) , for: .touchUpInside)
        self.checkRecordButton(isRecording: self.isRecoding)
    }
    
    func checkRecordButton(isRecording: Bool) {

        UIView.animate(withDuration: 0.5) {
            self.recodingButton.setTitle(nil, for: .normal)
            self.recodingButton.setImage(UIImage(systemName: isRecording ? "" : ""), for: .normal)
            self.recodingButton.clipsToBounds = true
            self.recodingButton.layer.borderWidth = 5
            self.recodingButton.layer.borderColor = isRecording ? UIColor.red.cgColor : UIColor.yellow.cgColor
            self.recodingButton.layer.cornerRadius = self.recodingButton.frame.width / 2
        }

    }
    
    @objc func recordButtonAction(_ sender: UIButton) {
        self.isRecoding.toggle()
    }
    
    
    
    //MARK: - 螢幕手勢
    func addfakeTapGesture() {
        self.view.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(fakeTapGestureAction(_:)))
        tapGes.numberOfTouchesRequired = 3
        tapGes.numberOfTapsRequired = 3
        self.view.addGestureRecognizer(tapGes)
    }
    
    @objc func fakeTapGestureAction(_ sender: UITapGestureRecognizer) {
        self.hideSrceen.toggle()
    }
    
    func fakeHideScreen() {
        
        for view in self.view.subviews {
            if let fakeView = view as? FakeView {
                fakeView.removeFromSuperview()
            }
        }
        
        let fakeView = FakeView(frame: UIScreen.main.bounds)
        fakeView.dismissAction = {
            UIScreen.main.brightness = self.currentScreenBrightness
        }
        self.tabBarController?.view.addSubview(fakeView)
        UIScreen.main.brightness = 0.0
        
    }
    


    
}

