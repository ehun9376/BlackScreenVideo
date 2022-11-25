//
//  CodeModel.swift
//  BlackSreenVideo
//
//  Created by yihuang on 2022/11/23.
//

import Foundation

class CodeModel: Equatable {
    public static func == (lhs: CodeModel, rhs: CodeModel) -> Bool {
        return lhs.text == rhs.text
        && lhs.text == rhs.text
    }
    
    var text: String?
    
    var number: Int?
    
    init(text: String? = nil, number: Int? = nil) {
        self.text = text
        self.number = number
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
    
    static let v352x288: CodeModel = .init(text: "352x288", number: 0)
    static let v640x480: CodeModel = .init(text: "640x480", number: 1)
    static let v1280x720: CodeModel = .init(text: "1280x720", number: 2)
    static let v1920x1080: CodeModel = .init(text: "1920x1080", number: 3)
    static let resolutions: [CodeModel] = [
        .v352x288,
        .v640x480,
        .v1280x720,
        .v1920x1080
    ]

    
}
