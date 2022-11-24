//
//  PlayViewController.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/11/24.
//

import Foundation
import UIKit
class PlayViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        let videoView = VideoView()
        self.view.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        videoView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 16/9).isActive = true
        videoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        videoView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        if let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
            videoView.play(with: url)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}


