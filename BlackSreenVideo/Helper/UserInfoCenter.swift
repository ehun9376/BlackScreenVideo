//
//  UserDefaultCenter.swift
//  BlackSreenVideo
//
//  Created by yihuang on 2022/11/23.
//

import Foundation



class UserInfoCenter: NSObject {
    
    static let shared = UserInfoCenter()
    
    enum UserInfoDataType: String{
        
        ///錄影總時間
        case totalRecordTime = "totalRecordTime"
        
        ///相機位置
        case cameraLocation = "cameraLocation"
        case videoDirection = "videoDirection"
        
        //MARK: - 循環錄影
        ///影片時間限制開關
        case lockVideoMaxTime = "lockVideoMaxTime"
        ///影片時間限制
        case videoMaxTime = "videoMaxTiem"
        ///循環錄影
        case cycleRecoding = "cycleRecoding"
        
        
        //MARK: - 密碼
        ///開啟App密碼開關
        case needPassword = "needPassword"
        ///開啟App密碼
        case password = "password"
        
        //MARK: - 一般設定
        ///錄影完成時顯示通知
        case notifiyWhenComplete = "notifiyWhenComplete"
        
        ///開始錄影時振動
        case shakeWhenStart = "shakeWhenStart"
        
        ///結束錄影時振動
        case shakeWhenEnd = "shakeWhenEnd"
        
        ///錄製時啟用勿擾模式
        case notNofitiyInRecoding = "notNofitiyInRecoding"
        
        ///顯示預覽
        case showPreviewView = "showPreviewView"
        
        ///DarkMode
        case darkMode = "darkMode"
        
        
    }
    
    func storeValue(_ type: UserInfoDataType, data: Any?) {
        UserDefaults.standard.set(data, forKey: type.rawValue)
    }
    
    func loadValue(_ type: UserInfoDataType) -> Any? {
        if let something = UserDefaults.standard.object(forKey: type.rawValue) {
            return something
        } else {
            return nil
        }
    }
    
    func startCheck() {
        
        //相機
        if self.loadValue(.cameraLocation) == nil {
            self.storeValue(.cameraLocation, data: CodeModel.backCamera.number)
        }
        //影片方向
        if self.loadValue(.videoDirection) == nil {
            self.storeValue(.videoDirection, data: CodeModel.vertically.number)
        }
        
        //是否需要密碼(預設不要)
        if self.loadValue(.needPassword) == nil {
            self.storeValue(.needPassword, data: false)
            UserDefaults.standard.removeObject(forKey: UserInfoDataType.password.rawValue)

        }
        
        ///錄影完成時顯示通知
        if self.loadValue(.notifiyWhenComplete) == nil {
            self.storeValue(.notifiyWhenComplete, data: false)
        }
        
        ///開始錄影時振動
        if self.loadValue(.shakeWhenStart) == nil {
            self.storeValue(.shakeWhenStart, data: false)
        }
        
        ///結束錄影時振動
        if self.loadValue(.shakeWhenEnd) == nil {
            self.storeValue(.shakeWhenEnd, data: false)
        }
        
        ///錄製時啟用勿擾模式
        if self.loadValue(.notNofitiyInRecoding) == nil {
            self.storeValue(.notNofitiyInRecoding, data: false)
        }
        ///影片時間限制開關
        if self.loadValue(.lockVideoMaxTime) == nil {
            self.storeValue(.lockVideoMaxTime, data: false)
        }
        
        ///循環錄影
        if self.loadValue(.cycleRecoding) == nil {
            self.storeValue(.cycleRecoding, data: false)
        }
        
        ///顯示預覽畫面
        if self.loadValue(.showPreviewView) == nil {
            self.storeValue(.showPreviewView, data: false)
        }
        
        ///DarkMode
        if self.loadValue(.darkMode) == nil {
            self.storeValue(.darkMode, data: false)
        }
        
    }
    
    func cleanAll() {
        let allType: [UserInfoDataType] = [
            .totalRecordTime,
            .cameraLocation,
            .lockVideoMaxTime,
            .videoMaxTime,
            .cycleRecoding,
            .needPassword,
            .password,
            .notifiyWhenComplete,
            .shakeWhenStart ,
            .shakeWhenEnd,
            .notNofitiyInRecoding,
            .darkMode
        ]
        
        for type in allType {
            UserDefaults.standard.removeObject(forKey: type.rawValue)
        }
    }
}
