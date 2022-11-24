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
    
    
    @IBOutlet weak var previewView: PreviewView!
    
    @IBOutlet weak var recodingButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    private var movieFileOutput: AVCaptureMovieFileOutput?
    
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    private let session = AVCaptureSession()
    
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
    
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    private var setupResult: SessionSetupResult = .success
    
    private let photoOutput = AVCapturePhotoOutput()
    
    
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
            self.checkRecording(turnOn: isRecoding)
            self.setupTimer(isRecording: isRecoding)
            self.startRecoding()
        }
    }
    
    var hideSrceen: Bool = false {
        didSet {
            self.fakeHideScreen()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addClear()
        self.addfakeTapGesture()
        self.defaultSetupRecordButton()
        self.defaultSetupTimeLabel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareInput()
        self.prepareOutput()
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session if setup succeeded.
                //                self.addObservers()
                self.session.startRunning()
                //                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async {
                    let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                            style: .`default`,
                                                            handler: { _ in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                                  options: [:],
                                                  completionHandler: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func prepareInput() {
        
        //檢查權限
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupResult = .success
            
        case .notDetermined:
            //沒有權限的時候
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            setupResult = .notAuthorized
        }
        
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        
        session.sessionPreset = .hd1920x1080
        
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
                DispatchQueue.main.async {
                    let videoDirection: AVCaptureVideoOrientation = (UserInfoCenter.shared.loadValue(.videoDirection) as? Int ?? 0) == 0 ? .landscapeLeft : .portrait
                    self.previewView.videoPreviewLayer.connection?.videoOrientation = videoDirection
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
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            } else {
                print("Could not add audio device input to the session")
            }
        } catch {
            print("Could not create audio device input: \(error)")
        }
        
        session.commitConfiguration()
    }
    
    func prepareOutput() {
        previewView.session = session
        sessionQueue.async {
            let movieFileOutput = AVCaptureMovieFileOutput()
            
            if self.session.canAddOutput(movieFileOutput) {
                self.session.beginConfiguration()
                self.session.addOutput(movieFileOutput)
                self.session.sessionPreset = .high
                
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
    
    //MARK: - 開始錄影
    func checkRecording(turnOn: Bool) {
        if turnOn {
            self.showSingleAlert(title: "提示",
                                 message: "點擊",
                                 confirmTitle: "確認",
                                 confirmAction: nil)
        } else {
            
        }
        
    }
    
    func startRecoding() {
        previewView.videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        guard let movieFileOutput = self.movieFileOutput else {
            return
        }
        guard let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation else {return}
        
        sessionQueue.async {
            if !movieFileOutput.isRecording {
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
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            } else {
                movieFileOutput.stopRecording()
            }
        }
    }
    
    
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
        
        if isRecording {
            self.recodingTime = 0
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ [weak self] _ in
                self?.timerAction()
            }
        } else {
            var totalTime = UserInfoCenter.shared.loadValue(.totalRecordTime) as? Int ?? 0
            totalTime += recodingTime
            UserInfoCenter.shared.storeValue(.totalRecordTime, data: totalTime)
            self.timer?.invalidate()
            self.recodingTime = 0
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
        
        let totalTime = UserInfoCenter.shared.loadValue(.totalRecordTime) as? Int ?? 0
        //TODO: - 或是有購買
        if totalTime < 60 {
            if !self.isRecoding {
                self.systemVibration()
            }
            self.isRecoding.toggle()
        } else {
            self.showToast(message: "需要購買")
        }
        
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
    
    func addClear() {
        self.view.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(claearAction(_:)))
        tapGes.numberOfTouchesRequired = 2
        tapGes.numberOfTapsRequired = 5
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
        func cleanup() {
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }
            
            if let currentBackgroundRecordingID = backgroundRecordingID {
                backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
                
                if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                }
            }
        }
        
        var success = true
        
        if error != nil {
            print("Movie file finishing error: \(String(describing: error))")
            success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
        }
        
        if success {
            // Check the authorization status.
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    // Save the movie file to the photo library and cleanup.
                    PHPhotoLibrary.shared().performChanges({
                        let options = PHAssetResourceCreationOptions()
                        options.shouldMoveFile = true
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                        
                    }, completionHandler: { success, error in
                        if !success {
                            print("AVCam couldn't save the movie to your photo library: \(String(describing: error))")
                        }
                        cleanup()
                    }
                    )
                } else {
                    cleanup()
                }
            }
        } else {
            cleanup()
        }
        
    }
}
