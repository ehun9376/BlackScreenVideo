//
//  RecordingTime.swift
//  BlackSreenVideo
//
//  Created by yihuang on 2023/6/25.
//

import Foundation

protocol RecordingTimeDelegate {
    func timeDidChange(time: Int)
}

class RecordingTimeCenter: NSObject {
    static let shard = RecordingTimeCenter()
    
    var delegate: RecordingTimeDelegate?
    
    func getTime() -> Int {
        let time = UserInfoCenter.shared.loadValue(.recordTimes) as? Int ?? 0
        return time
    }
    
    func appenTime(_ newTime: Int) {
        if var time = UserInfoCenter.shared.loadValue(.recordTimes) as? Int {
            time += newTime
            UserInfoCenter.shared.storeValue(.recordTimes, data: time)
            delegate?.timeDidChange(time: time)
        } else {
            UserInfoCenter.shared.storeValue(.recordTimes, data: newTime)
        }
    }
    
    func useOneTime() {
        if var time = UserInfoCenter.shared.loadValue(.recordTimes) as? Int {
            time -= 1
            UserInfoCenter.shared.storeValue(.recordTimes, data: time)
            delegate?.timeDidChange(time: time)
        } else {
            UserInfoCenter.shared.storeValue(.recordTimes, data: 0)
        }
    }
    
    
}
