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

extension String {
    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        let versionDelimiter = "."
        
        var versionComponents = self.components(separatedBy: versionDelimiter)
        
        var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)
        
        let diff = versionComponents.count - otherVersionComponents.count
        
        if diff == 0 {
            
            return self.compare(otherVersion, options: .numeric)
        } else {
            
            let zeros = Array(repeating: "0", count: abs(diff))
            if diff > 0 {
                otherVersionComponents.append(contentsOf: zeros)
            } else {
                versionComponents.append(contentsOf: zeros)
            }
            
            return versionComponents.joined(separator: versionDelimiter)
                .compare(otherVersionComponents.joined(separator: versionDelimiter), options: .numeric)
        }
    }
}
