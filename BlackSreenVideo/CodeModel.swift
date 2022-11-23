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
    
}
