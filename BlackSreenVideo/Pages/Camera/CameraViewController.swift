//
//  ViewController.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/11/18.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: BaseViewController {

    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var previewView: PreviewView!
    
    @IBOutlet weak var recodingButton: UIButton!
    
    @IBOutlet weak var settingButton: UIButton!
    
    @IBOutlet weak var bookButton: UIButton!
    var windowOrientation: UIInterfaceOrientation {
        return view.window?.windowScene?.interfaceOrientation ?? .unknown
    }
    
    private var movieFileOutput: AVCaptureMovieFileOutput?
    
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    private let session = AVCaptureSession()
    
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
    
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    private var setupResult: SessionSetupResult = .success
    
    private let photoOutput = AVCapturePhotoOutput()
    
    
    var audioDeviceInput: AVCaptureDeviceInput?
    
    var blackScreenView: FakeView?
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        .lightContent
//    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    ///是不是循環錄影
    var isRepete: Bool = false
    
    //紀錄目前的亮度
    let currentScreenBrightness = UIScreen.main.brightness
    
    //紀錄目前錄影多久的timer
    var timer: Timer?
    
    //紀錄目前錄影多久
    var recodingTime: Int = 0 {
        didSet {
            self.checkMaxTime(currentTime: recodingTime)
            self.setupLabelWithTime(time: recodingTime)
        }
    }
    
    //是否正在錄影
    var isRecoding: Bool = false {
        didSet {
            self.checkRecordButton(isRecording: isRecoding)
            self.checkRecordingAlert(turnOn: isRecoding)
            self.setupTimer(isRecording: isRecoding)
            self.checkShake(turnOn: isRecoding)
            self.startRecoding(turnOn: isRecoding)
        }
    }
    
    var hideSrceen: Bool = false {
        didSet {
            guard VersionCheckCenter.shared.isOnline else { return }
//            self.fakeHideScreen(hideSrceen: hideSrceen)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addClear()
        self.addfakeTapGesture()
        self.defaultSetupRecordButton()
        self.defaultSetupTimeLabel()
        self.defaultSetupFakeView()
        self.setupSettingButton()
        self.setupbookButton()
        self.view.backgroundColor = .black
        timeLabel.font = .systemFont(ofSize: 28)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkShowPreview()
        self.checkAuthorizationStatus()
        self.prepareInput()
        self.prepareOutput()
        self.showAuthorizationAlert()
        self.defaultSetupTimeLabel()
        let times = RecordingTimeCenter.shard.getTime()
        timeLabel.text = "剩餘\(times)次"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.beginConfiguration()
        if let audioDeviceInput = self.audioDeviceInput, session.inputs.contains(audioDeviceInput) {
            session.removeInput(audioDeviceInput)
        }
        
        if let videoDeviceInput = self.videoDeviceInput, session.inputs.contains(videoDeviceInput) {
            session.removeInput(videoDeviceInput)
        }
        
        session.commitConfiguration()
        
        self.isRecoding = false
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        
        super.viewWillTransition(to: size, with: coordinator)
        
        
        
        if let videoPreviewLayerConnection = previewView.videoPreviewLayer.connection {
            let deviceOrientation = UIDevice.current.orientation
            guard let newVideoOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue),
                  deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                return
            }
            
            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
        }
    }
    
    func setupbookButton() {
        self.bookButton.setTitle("", for: .normal)
        self.bookButton.addTarget(self, action: #selector(bookButtonButtonAction), for: .touchUpInside)
    }
    
    @objc func bookButtonButtonAction() {
        let vc = LibraryViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupSettingButton() {
//        self.settingButton.setTitle("設定", for: .normal)
        self.settingButton.addTarget(self, action: #selector(settingButtonAction), for: .touchUpInside)
    }
    
    @objc func settingButtonAction() {
        let vc = SettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func defaultSetupFakeView() {
        
        self.blackScreenView = FakeView(frame: .zero)
        self.blackScreenView?.translatesAutoresizingMaskIntoConstraints = false
        self.navigationController?.view.addSubview(self.blackScreenView ?? .init())
        
        if let navigationControllerView = self.navigationController?.view {
            self.blackScreenView?.topAnchor.constraint(equalTo: navigationControllerView.topAnchor).isActive = true
            self.blackScreenView?.bottomAnchor.constraint(equalTo: navigationControllerView.bottomAnchor).isActive = true
            self.blackScreenView?.leadingAnchor.constraint(equalTo: navigationControllerView.leadingAnchor).isActive = true
            self.blackScreenView?.trailingAnchor.constraint(equalTo: navigationControllerView.trailingAnchor).isActive = true
        }
        
        self.blackScreenView?.dismissAction = {
            UIScreen.main.brightness = self.currentScreenBrightness
            self.hideSrceen = false
        }
        self.blackScreenView?.isHidden = true
        
    }
    
    
    //MARK: - 權限相關
    func showAuthorizationAlert() {
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.session.startRunning()
                break
            case .notAuthorized:
                self.showAlert(title: "提示",
                               message: "你尚未開啟相機權限，\n快去設定開啟相機權限吧",
                               confirmTitle: "前往設定",
                               cancelTitle: "取消",
                               confirmAction: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url,
                                                  options: [:],
                                                  completionHandler: nil)
                    }
                    
                },
                               cancelAction: nil)
                
            case .configurationFailed:
                break
//                self.showSingleAlert(title: "偵測到錯誤",
//                                     message: "請重新安裝或諮詢客服",
//                                     confirmTitle: "確定",
//                                     confirmAction: nil)
            }
        }
        
    }
    
    func checkAuthorizationStatus() {
        //檢查權限
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupResult = .success
            
        case .notDetermined:
            //沒有權限的時候
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
                guard let self = self else { return }
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            setupResult = .notAuthorized
        }
        
    }
    //MARK: - 準備輸入輸出
    private func prepareInput() {
        
        if setupResult != .success {
            return
        }
        
        
        session.beginConfiguration()
        
        switch (UserInfoCenter.shared.loadValue(.resolutions) as? Int ?? 0) {
        case 0:
            session.sessionPreset = .high
        case 1:
            session.sessionPreset = .medium
        case 2:
            session.sessionPreset = .low
        default :
            session.sessionPreset = .high
        }
        
        do {
            if let audio = AVCaptureDevice.default(for: .audio) {
                self.audioDeviceInput = try AVCaptureDeviceInput(device: audio)
            }
        } catch {
            
        }
        
        
        //建立輸入源
        //在此確定要用哪個鏡頭
        do {
            let caremaLocation: AVCaptureDevice.Position = (UserInfoCenter.shared.loadValue(.cameraLocation) as? Int ?? 0) == 0 ? .front : .back
            
            var defaultVideoDevice: AVCaptureDevice?
            
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: caremaLocation) {
                defaultVideoDevice = dualCameraDevice
            } else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: caremaLocation) {
                defaultVideoDevice = dualWideCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: caremaLocation) {
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: caremaLocation) {
                defaultVideoDevice = frontCameraDevice
            }
            
            //如果抓不到相機
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            //加入輸入源
            for input in self.session.inputs {
                session.removeInput(input)
            }
            
            
            if session.canAddInput(videoDeviceInput) {
                self.videoDeviceInput = videoDeviceInput
                self.session.addInput(videoDeviceInput)
                //                DispatchQueue.main.async {
                
                //                }
                DispatchQueue.main.async {
                    /*
                     Dispatch video streaming to the main queue because AVCaptureVideoPreviewLayer is the backing layer for PreviewView.
                     You can manipulate UIView only on the main thread.
                     Note: As an exception to the above rule, it's not necessary to serialize video orientation changes
                     on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                     
                     Use the window scene's orientation as the initial video orientation. Subsequent orientation changes are
                     handled by CameraViewController.viewWillTransition(to:with:).
                     */
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    
                    switch (UserInfoCenter.shared.loadValue(.videoDirection) as? Int ?? 0) {
                        
                    case 0:
                        
                        if self.windowOrientation != .unknown {
                            if let videoOrientation = AVCaptureVideoOrientation(rawValue: self.windowOrientation.rawValue) {
                                initialVideoOrientation = videoOrientation
                            }
                        }
                        
                    case 1:
                        initialVideoOrientation = .landscapeLeft
                        
                    case 2:
                        initialVideoOrientation = .portrait
                        
                    default:
                        break
                    }
                    
                    self.previewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            } else {
                print("Couldn't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Couldn't create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add an audio input device.
        //        do {
        //            let audioDevice = AVCaptureDevice.default(for: .audio)
        //            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
        //            session.removeInput(audioDeviceInput)
        //
        //            if session.canAddInput(audioDeviceInput) {
        //                session.addInput(audioDeviceInput)
        //            } else {
        //                print("Could not add audio device input to the session")
        //            }
        //        } catch {
        //            print("Could not create audio device input: \(error)")
        //        }
        
        session.commitConfiguration()
    }
    
    func prepareOutput() {
        if setupResult != .success {
            return
        }
        previewView.session = session
        sessionQueue.async {
            let movieFileOutput = AVCaptureMovieFileOutput()
            
            if self.session.canAddOutput(movieFileOutput) {
                self.session.beginConfiguration()
                self.session.addOutput(movieFileOutput)
                
                do {
                    try self.videoDeviceInput.device.lockForConfiguration()
                    self.videoDeviceInput.device.unlockForConfiguration()
                } catch {
                    print("Could not lock device for configuration: \(error)")
                }
                
                
                if let connection = movieFileOutput.connection(with: .video) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                }
                
                self.session.commitConfiguration()
                
                self.movieFileOutput = movieFileOutput
            }
        }
    }
    
    func startRecoding(turnOn: Bool) {
        
        guard let movieFileOutput = self.movieFileOutput else { return }
        guard let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation else { return }
        sessionQueue.async {
            if turnOn {
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                // Update the orientation on the movie file output video connection before recording.
                let movieFileOutputConnection = movieFileOutput.connection(with: .video)
                movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation
                
                let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
                
                if availableVideoCodecTypes.contains(.hevc) {
                    movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                }
                
                // Start recording video to a temporary file.
                let outputFileName = NSUUID().uuidString
                let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let url = documents.appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(to: url, recordingDelegate: self)
            } else {
                movieFileOutput.stopRecording()
            }
        }
    }
    
    
    //MARK: - 錄影相關
    func checkRecordingAlert(turnOn: Bool) {
        guard VersionCheckCenter.shared.isOnline else { return }
        if turnOn && !self.isRepete {
//            self.showSingleAlert(title: "已開啟錄影",
//                                 message: "三隻手指點擊三下可以開關黑幕",
//                                 confirmTitle: "確認",
//                                 confirmAction: { [weak self] in
//                self?.hideSrceen.toggle()
//            })
           
        }
    }
    
    func checkShake(turnOn: Bool) {
        guard VersionCheckCenter.shared.isOnline else { return }
        session.beginConfiguration()
        if let audioDeviceInput = self.audioDeviceInput, session.inputs.contains(audioDeviceInput) {
            session.removeInput(audioDeviceInput)
        }
        
        session.commitConfiguration()
        
        
        
        if turnOn {
            let shakeAtStart = UserInfoCenter.shared.loadValue(.shakeWhenStart) as? Bool ?? false
            if shakeAtStart {
                self.systemVibration(sender: self, complete: nil)
            }
        } else {
            let shakeAtEnd = UserInfoCenter.shared.loadValue(.shakeWhenEnd) as? Bool ?? false
            if shakeAtEnd {
                self.systemVibration(sender: self, complete: nil)
            }
        }
        
        session.beginConfiguration()
        
        if let audioDeviceInput = self.audioDeviceInput ,
           !session.inputs.contains(audioDeviceInput),
           session.canAddInput(audioDeviceInput){
            session.addInput(audioDeviceInput)
        }
        session.commitConfiguration()
        
    }
    
    
    
    
    
    
    //MARK: - Label
    func defaultSetupTimeLabel() {
        

    }
    
    func setupLabelWithTime(time: Int) {
    }
    
    //MARK: - 預覽畫面
    func checkShowPreview() {
        self.previewView.isHidden = !(UserInfoCenter.shared.loadValue(.showPreviewView) as? Bool ?? false)
    }
    
    
    //MARK: - Timer
    func setupTimer(isRecording: Bool) {
        
        if isRecording {
            self.recodingTime = 0
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ [weak self] _ in
                self?.timerAction()
            }
        } else {
            self.timer?.invalidate()
            self.recodingTime = 0
        }
        
    }
    
    func timerAction() {
        self.recodingTime += 1
    }
    
    func checkMaxTime(currentTime: Int) {
        let openMaxTime = UserInfoCenter.shared.loadValue(.lockVideoMaxTime) as? Bool ?? false
        if openMaxTime {
            let maxTime = UserInfoCenter.shared.loadValue(.videoMaxTime) as? Int ?? 0
            if currentTime >= maxTime {
                self.isRecoding.toggle()
                let isRepeat = UserInfoCenter.shared.loadValue(.cycleRecoding) as? Bool ?? false
                if isRepeat {
                    self.isRepete = true
                    self.isRecoding.toggle()
                }
            }
        }
    }
    
    
    //MARK: - 錄影按鈕
    func defaultSetupRecordButton() {
        if #available(iOS 15.0, *) {
            self.recodingButton.configuration = nil
        }
        self.recodingButton.setTitle("", for: .normal)
        self.recodingButton.addTarget(self, action:#selector(recordButtonAction(_:)) , for: .touchUpInside)
        self.checkRecordButton(isRecording: self.isRecoding)
    }
    
    func checkRecordButton(isRecording: Bool) {
        
        UIView.animate(withDuration: 0.5) {
            self.recodingButton.setTitle(nil, for: .normal)
            self.recodingButton.setImage(UIImage(systemName: isRecording ? "stop.circle" : "record.circle")?.withRenderingMode(.alwaysTemplate).resizeImage(targetSize: .init(width: 100, height: 100)), for: .normal)
            self.recodingButton.tintColor = UIColor.red
            self.recodingButton.clipsToBounds = true
            //            self.recodingButton.layer.borderWidth = 5
            self.recodingButton.layer.borderColor = isRecording ? UIColor.red.cgColor : UIColor.yellow.cgColor
            self.recodingButton.layer.cornerRadius = self.recodingButton.frame.width / 2
        }
        
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    @objc func recordButtonAction(_ sender: UIButton) {

        recordAction()
    }
    
    func recordAction() {
        self.isRepete = false
        
        if !self.isRecoding {
            guard RecordingTimeCenter.shard.getTime() > 0 else {
                self.showToast(message: "沒有額度囉，請至設定頁購買")
                return
            }
            
            RecordingTimeCenter.shard.useOneTime()
            let times = RecordingTimeCenter.shard.getTime()
            timeLabel.text = "剩餘\(times)次"
            self.isRecoding = true
            
        } else {
            self.isRecoding = false
        }
        
    }
    
    
    
    //MARK: - 螢幕手勢
    
    func addfakeTapGesture() {
        guard VersionCheckCenter.shared.isOnline else { return }

        self.previewView.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(fakeTapGestureAction(_:)))
        tapGes.numberOfTouchesRequired = 3
        tapGes.numberOfTapsRequired = 3
        
        self.previewView.addGestureRecognizer(tapGes)
    }
    
    @objc func fakeTapGestureAction(_ sender: UITapGestureRecognizer) {
        self.hideSrceen.toggle()
    }
    
    func fakeHideScreen(hideSrceen: Bool) {
        self.blackScreenView?.isHidden = !hideSrceen
        UIScreen.main.brightness = 0.0
    }
    
    func addClear() {
        self.view.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(claearAction(_:)))
        tapGes.numberOfTouchesRequired = 2
        tapGes.numberOfTapsRequired = 10
        self.view.addGestureRecognizer(tapGes)
    }
    
    @objc func claearAction(_ sender: UITapGestureRecognizer) {
        UserInfoCenter.shared.cleanAll()
        UserInfoCenter.shared.startCheck()
        self.showToast(message: "UserInfo已經恢復成預設")
    }
    
}

extension CameraViewController:  AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("fileOutput")
        let path = outputFileURL.path
        
        if FileManager.default.fileExists(atPath: path) {
            print("已儲存")
            print(path)
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // Save the movie file to the photo library and cleanup.
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = false
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                    
                    
                }, completionHandler: { success, error in
                    
                })
            } else {
            }
        }
        
        let notifiy = UserInfoCenter.shared.loadValue(.notifiyWhenComplete) as? Bool ?? false
        if notifiy {
            self.sendLocalNotication(title: "錄影完成")
        }
    }
}
