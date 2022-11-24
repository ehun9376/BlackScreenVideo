//
//  LibraryViewController.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/11/23.
//

import Foundation
import AVFoundation
import UIKit

class LibraryViewController: BaseTableViewController {
    
    
    @IBOutlet weak var testImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.regisCellID(cellIDs: [
        ])
        
        
        //        cleanup()//        print(path)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getAllfileURL()
    }
    func getAllfileURL() {
        
        do {
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let path = documentURL.absoluteURL
            let directoryContents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
            print(directoryContents)
            self.testImage.image = self.generateThumbnail(path: directoryContents[0])?.resizeImage(targetSize: .init(width: 50, height: 50))
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
}
