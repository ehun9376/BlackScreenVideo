//
//  VersionCheckCenter.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/12/6.
//

import Foundation

class VersionCheckCenter {
    
    static let shared = VersionCheckCenter()
    
    var isOnline: Bool = false
    
    func enablePurchaseInAppIfNeeded(complete: (()->())? = nil) {
        guard let bundleID = Bundle.main.bundleIdentifier,
              let dict = Bundle.main.infoDictionary else { return }
        
        let appVersion = dict["CFBundleShortVersionString"] as? String ?? ""
        
        if appVersion.isEmpty {
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleID)")!
        
        session.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else {
                return
            }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let json = json as? [String: Any] {
                if let count = json["resultCount"] as? Int {
                    if count != 0 {
                        self.isOnline = true
                    }
                }
                if let results = json["results"] as? [Any] {
                    if results.count != 0 {
                        self.isOnline = true
                    }
                }
            }
            complete?()
        }.resume()
    }
    
}


