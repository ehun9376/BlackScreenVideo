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
        
        ///相機位置
        case cameraLocation = "cameraLocation"
        
        ///影片時間限制開關
        case lockVideoMaxTime = "lockVideoMaxTime"
        ///影片時間限制
        case videoMaxTime = "videoMaxTiem"
        ///循環錄影
        case cycleRecoding = "cycleRecoding"
        
        ///開啟App密碼開關
        case needPassword = "needPassword"
        ///開啟App密碼
        case password = "password"
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
        
        //是否需要密碼(預設不要)
        if self.loadValue(.needPassword) == nil {
            self.storeValue(.needPassword, data: false)
        }

        ///影片時間限制開關
        if self.loadValue(.lockVideoMaxTime) == nil {
            self.storeValue(.lockVideoMaxTime, data: false)
        }

        ///循環錄影
        if self.loadValue(.cycleRecoding) == nil {
            self.storeValue(.cycleRecoding, data: false)
        }
        
    }
    
    func cleanAll() {
        let allType: [UserInfoDataType] = [
            .cameraLocation
        ]
        
        for type in allType {
            UserDefaults.standard.removeObject(forKey: type.rawValue)
        }
    }
}
