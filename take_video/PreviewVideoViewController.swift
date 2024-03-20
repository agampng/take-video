//
//  PreviewVideoViewController.swift
//  take_video
//
//  Created by Mahisa Panatagama on 08/03/24.
//

import AVFoundation
import AVKit
import UIKit
import SnapKit

class PreviewVideoViewController: UIViewController {
  private lazy var btnInfo: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "ic_information"), for: .normal)
    btn.backgroundColor = .white
    btn.layer.cornerRadius = 25
    btn.addTarget(self, action: #selector(didTapInfo), for: .touchUpInside)
    return btn
  }()
  
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  private var videoURL: URL
  var player: AVPlayer?
  var playerController : AVPlayerViewController?
  
  init(videoURL: URL) {
    self.videoURL = videoURL
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.gray
    player = AVPlayer(url: videoURL)
    playerController = AVPlayerViewController()
    
    guard player != nil && playerController != nil else {
      return
    }
    playerController!.showsPlaybackControls = false
    
    playerController!.player = player!
    self.addChild(playerController!)
    self.view.addSubview(playerController!.view)
    playerController!.view.frame = view.frame
    NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
    
    //        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
    //        cancelButton.setImage(UIImage(named: "ic_close"), for: UIControl.State())
    //        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    //        view.addSubview(cancelButton)
    
    do {
      if #available(iOS 10.0, *) {
        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
      } else {
      }
    } catch let error as NSError {
      print(error)
    }
    
    do {
      try AVAudioSession.sharedInstance().setActive(true)
    } catch let error as NSError {
      print(error)
    }
    
    setupUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    player?.play()
  }
  
  private func setupUI() {
    view.addSubview(btnInfo)
    btnInfo.snp.makeConstraints { make in
      make.right.equalTo(view.safeAreaInsets).inset(16)
      make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      make.size.equalTo(50)
    }
  }
  
  @objc func didTapInfo() {
    let vc = VideoInfoViewController()
    
    guard let data = try? Data(contentsOf: videoURL) else {
      return
    }
    
    vc.infoData = ["Video size:": "\(Double(data.count / 1048576)) MB",
                   "Duration:": "\(player?.currentItem?.duration.seconds.rounded() ?? 0) seconds",
                   "Presentation Size:": "\(player!.currentItem!.presentationSize.height) x \(player!.currentItem!.presentationSize.width)",]
    present(vc, animated: true)
  }
  
  @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
    if self.player != nil {
      self.player!.seek(to: CMTime.zero)
      self.player!.play()
    }
  }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
  return input.rawValue
}
