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
    
    var allFileURL: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.regisCellID(cellIDs: [
            "PreviewCell"
        ])
                
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getAllfileURL()
        self.setupRow()
    }
    
    func setupRow() {
        
        var rowModels: [CellRowModel] = []
        //最新的放到最上面
        for url in self.allFileURL.reversed() {
            let rowModel = PreviewCellRowModel(image: self.generateThumbnail(path: url),
                                               fileName: getFileName(url: url),
                                               fileURL: url,
                                               cellDidSelect: { [weak self] _ in
                self?.showPlayViewController(url: url)
//                self?.removeFile(url: url, complete: {
//                    self?.getAllfileURL()
//                    self?.setupRow()
//                })
            })
            rowModels.append(rowModel)
        }
        self.adapter?.updateTableViewData(rowModels: rowModels)

    }
    
    func showPlayViewController(url:URL) {
        let vc = PlayViewController()
        vc.url = url
        self.present(vc, animated: true)
    }
    
    func getAllfileURL() {
        
        do {
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            if let path = documentURL {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
                self.allFileURL = directoryContents
            }
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
    
    func getFileName(url:URL) -> String {
        return String(url.absoluteString.split(separator: "/").last ?? "")
    }
    
    func removeFile(url:URL?, complete: (()->())?) {
        if FileManager.default.fileExists(atPath: url?.path ?? "") {
            do {
                if let fileURL = url {
                    try FileManager.default.removeItem(at: fileURL)
                    complete?()
                }
            } catch {
                print("remove failed")
            }
        }
    }
    
}
