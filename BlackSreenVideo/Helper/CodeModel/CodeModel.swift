//
//  CodeModel.swift
//  BlackSreenVideo
//
//  Created by yihuang on 2022/11/23.
//

import Foundation

class CodeModel: Equatable, JsonModel {
    required init(json: JBJson) {
        self.text = json["title"].stringValue
        self.id = json["id"].stringValue
        self.number = json["number"].intValue
    }
    
    public static func == (lhs: CodeModel, rhs: CodeModel) -> Bool {
        return lhs.text == rhs.text
        && lhs.text == rhs.text
    }
    
    var text: String?
    
    var number: Int = 0
    
    var id: String = ""
    
    init(text: String? = nil, number: Int = 0, id: String = "") {
        self.text = text
        self.number = number
        self.id = id
    }
    
    //鏡頭位置
    static let infrontCamera: CodeModel = .init(text: "前置鏡頭", number: 0)
    static let backCamera: CodeModel = .init(text: "後置鏡頭", number: 1)
    static let cameraLocation: [CodeModel] = [
        .infrontCamera,
        .backCamera
    ]
    
    //影片方向
    static let auto: CodeModel = .init(text: "自動", number: 0)
    static let horizontal: CodeModel = .init(text: "橫向", number: 1)
    static let vertically: CodeModel = .init(text: "直向", number: 2)
    static let videoDirection: [CodeModel] = [
        .auto,
        .horizontal,
        .vertically
    ]
    
//    //影片解析度
//    static let v352x288: CodeModel = .init(text: "352x288", number: 0)
//    static let v640x480: CodeModel = .init(text: "640x480", number: 1)
//    static let v1280x720: CodeModel = .init(text: "1280x720", number: 2)
//    static let v1920x1080: CodeModel = .init(text: "1920x1080", number: 3)
//    static let v3840x2160: CodeModel = .init(text: "3840x2160", number: 4)

    
    static let vHigh: CodeModel = .init(text: "高", number: 0)
    static let vMiddle: CodeModel = .init(text: "中", number: 1)
    static let vLow: CodeModel = .init(text: "低", number: 2)
    static let resolutions: [CodeModel] = [
        .vHigh,
        .vMiddle,
        .vLow
    ]


    
}
