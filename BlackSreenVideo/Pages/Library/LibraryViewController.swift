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
                                               fileCreateTime: getfileModificationDate(url: url),
                                               videoTime: getVideoTime(url: url),
                                               fileURL: url,
                                               deletebuttonAction: { [weak self] in
                self?.removeFile(url: url,
                                complete: {
                    self?.getAllfileURL()
                    self?.setupRow()
                })
            },
                                               cellDidSelect: { [weak self] _ in
                self?.showPlayViewController(url: url)
            })
            rowModels.append(rowModel)
        }
        self.adapter?.updateTableViewData(rowModels: rowModels)

    }
    
    func showPlayViewController(url: URL) {
        let vc = PlayViewController()
        vc.url = url
        self.navigationController?.pushViewController(vc, animated: true)
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
            let cgImage = try imgGenerator.copyCGImage(at: .init(value: 1000, timescale: 1000), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    //MARK: - File
    func getFileName(url:URL) -> String {
        return String(url.absoluteString.split(separator: "/").last ?? "")
    }
    
    func getfileModificationDate(url: URL) -> String? {
        let dataFormatter = DateFormatter()
        dataFormatter.locale = Locale(identifier: "zh_Hant_TW")
        dataFormatter.dateFormat = "YYYY-MM-dd"

        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            let date = attr[FileAttributeKey.modificationDate] as? Date ?? Date()
            return dataFormatter.string(from: date)
        } catch {
            return nil
        }
        
    }
    
    func getVideoTime(url: URL?) -> String {
        if let url = url {
            let asset = AVAsset(url: url)
            let duration = Int(asset.duration.seconds)
            let minutes = duration/60
            let seconds = duration%60
            let videoDuration = String(format: "%02d:%02d", minutes,seconds)
            return videoDuration
        }
        return ""
    }
    
    func removeFile(url:URL?, complete: (()->())?) {
        
        self.showAlert(title: "警告",
                       message: "你確定要刪除嗎",
                       confirmTitle: "確定",
                       cancelTitle: "取消",
                       confirmAction: {
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
        },
                       cancelAction: nil)
        

    }
}
