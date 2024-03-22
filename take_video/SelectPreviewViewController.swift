//
//  SelectPreviewViewController.swift
//  take_video
//
//  Created by Mahisa Panatagama on 19/03/24.
//

import UIKit
import SwiftyCam
import SnapKit
import AVFoundation

class SelectPreviewViewController: UIViewController {
  lazy var btnPreviewRaw: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("Preview Raw Video", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitleColor(UIColor.link, for: .normal)
    
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    button.layer.cornerRadius = 8
    return button
  }()
  lazy var btnPreviewCompress: UIButton = {
    var button = UIButton(type: .custom)
    button.setTitle("Preview Compressed Video", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitleColor(UIColor.link, for: .normal)
    
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    button.layer.cornerRadius = 8
    
    let topActions = [
      UIAction(title: "PresetLowQuality", handler: { [weak self] (_) in
        guard let self,
              let rawVidUrl else { return }
        videoProcessing(url: rawVidUrl, compression: AVAssetExportPresetLowQuality)
      }),
      UIAction(title: "PresetMediumQuality", handler: { [weak self] (_) in
        guard let self,
              let rawVidUrl else { return }
        videoProcessing(url: rawVidUrl, compression: AVAssetExportPresetMediumQuality)
      }),
      UIAction(title: "Preset640x480", handler: { [weak self] (_) in
        guard let self,
              let rawVidUrl else { return }
        videoProcessing(url: rawVidUrl, compression: AVAssetExportPreset640x480)
      }),
      UIAction(title: "Preset960x540", handler: { [weak self] (_) in
        guard let self,
              let rawVidUrl else { return }
        videoProcessing(url: rawVidUrl, compression: AVAssetExportPreset960x540)
      }),
      UIAction(title: "Preset1280x720", handler: { [weak self] (_) in
        guard let self,
              let rawVidUrl else { return }
        videoProcessing(url: rawVidUrl, compression: AVAssetExportPreset1280x720)
      }),
      
    ]
    let divider = UIMenu(title: "", options: .displayInline, children: topActions)
    let items = [divider]
    let menu = UIMenu(title: "Compression type", children: items)
    button.showsMenuAsPrimaryAction = true
    button.menu = menu
    
    return button
  }()
  private lazy var stvContainer: UIStackView = {
    let view = UIStackView()
    view.axis = .vertical
    view.spacing = 32
    view.alignment = .center
    view.addArrangedSubview(btnPreviewRaw)
    view.addArrangedSubview(btnPreviewCompress)
    return view
  }()
  private lazy var progressIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView()
    view.isHidden = true
    view.backgroundColor = .white
    return view
  }()
  
  var infoData: [String: String] = [:]
  //  var compressVidUrl: URL?
  var rawVidUrl: URL?
  var compressTimer: Timer?
  var compressTime = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
}

extension SelectPreviewViewController {
  private func setup() {
    setupUI()
    setupAction()
  }
  
  private func setupUI() {
    view.backgroundColor = .white
    view.addSubview(stvContainer)
    stvContainer.snp.makeConstraints { make in
      make.centerX.centerY.equalToSuperview()
    }
    
    view.addSubview(progressIndicator)
    progressIndicator.snp.makeConstraints { make in
      make.centerX.centerY.equalToSuperview()
      make.size.equalTo(50)
    }
  }
  
  private func setupAction() {
    btnPreviewRaw.addTarget(self, action: #selector(didTapPreviewRaw), for: .touchUpInside)
    btnPreviewCompress.addTarget(self, action: #selector(didTapPreviewCompress), for: .touchUpInside)
  }
  
  
  @objc func didTapPreviewRaw() {
    guard let rawVidUrl else { return }
    self.navigateToPreviewVideo(with: rawVidUrl)
  }
  
  @objc func didTapPreviewCompress() {
    //    guard let compressVidUrl else { return }
    //    self.navigateToPreviewVideo(with: compressVidUrl)
  }
  
  private func navigateToPreviewVideo(with url: URL) {
    let vc = PreviewVideoViewController(videoURL: url)
    navigationController?.pushViewController(vc, animated: true)
  }
  
  private func navigateToPreviewVideoCompress(with url: URL, actualVidUrl: URL) {
    let vc = PreviewVideoViewController(videoURL: url)
    vc.compressProcessingTime = compressTime
    vc.actualVideoURL = rawVidUrl
    navigationController?.pushViewController(vc, animated: true)
  }
}

extension SelectPreviewViewController {
  func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
  
  func videoProcessing(url: URL, compression: String) {
    self.progressIndicator.isHidden.toggle()
    guard let data = try? Data(contentsOf: url) else {
      return
    }
    print("VID: File size before compression: \(Double(data.count / 1048576)) mb")
    
    let beforefilename = getDocumentsDirectory().appendingPathComponent("BEFORE_\(url.lastPathComponent)")
    print("--- \(beforefilename)")
    
    let fileManager = FileManager()
    do {
      let path = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("\(Date().timeIntervalSince1970)_before_\(url.lastPathComponent)")
      try data.write(to: path)
      print("--- SUCCESS \(path)")
    } catch {
      print("--- ERROR \(error)")
    }
    
    compressTimer?.invalidate()
    compressTime = 0
    compressTimer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: #selector(self.startTimer(_:)), userInfo: nil, repeats: true)
    let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
    compressVideo(inputURL: url,
                  outputURL: compressedURL,
                  compression: compression) { exportSession in
      guard let session = exportSession else {
        return
      }
      
      switch session.status {
      case .completed:
        guard let compressedData = try? Data(contentsOf: compressedURL) else {
          return
        }
        print("VID: File size after compression: \(Double(compressedData.count / 1048576)) mb")
        self.compressTimer?.invalidate()
        let afterfilename = self.getDocumentsDirectory().appendingPathComponent("AFTER_\(compressedURL.lastPathComponent)")
        try? data.write(to: afterfilename)
        //        self.rawVidUrl = url
        //        self.compressVidUrl = compressedURL
        DispatchQueue.main.async {
          self.progressIndicator.isHidden.toggle()
          self.navigateToPreviewVideoCompress(with: compressedURL, actualVidUrl: url)
        }
      default:
        break
      }
    }
  }
  
  func compressVideo(inputURL: URL,
                     outputURL: URL,
                     compression: String,
                     handler:@escaping (_ exportSession: AVAssetExportSession?) -> Void) {
    let urlAsset = AVURLAsset(url: inputURL, options: nil)
    guard let exportSession = AVAssetExportSession(asset: urlAsset,
                                                   presetName: compression) else {
      handler(nil)
      return
    }
    
    exportSession.outputURL = outputURL
    exportSession.outputFileType = .mp4
    exportSession.exportAsynchronously {
      handler(exportSession)
    }
  }
  
  @objc private func startTimer(_ timer: Timer) {
    print("---- start compressTime")
    compressTime += 1
  }
}
