//
//  CameraViewController.swift
//  take_video
//
//  Created by Mahisa Panatagama on 08/03/24.
//

import Foundation
import UIKit
import SwiftyCam
import SnapKit
import AVFoundation

class CameraViewController: SwiftyCamViewController {
  private lazy var actionButton: UIButton = {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Record", for: .normal)
    button.setTitleColor(UIColor.black, for: .normal)
    
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    button.layer.borderWidth = 1
    button.layer.cornerRadius = 8
    button.layer.borderColor = UIColor.black.cgColor
    button.backgroundColor = UIColor.white
    return button
  }()
  
  private lazy var flashButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "ic_flash_off"), for: .normal)
    return button
  }()
  
  private lazy var progressIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView()
    view.isHidden = true
    return view
  }()
  
  fileprivate var timerN : Timer?
  var timeDef: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
}

extension CameraViewController {
  private func startCountDownTimer() {
    timerN?.invalidate()
    timeDef = 0
    timerN = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: #selector(self.updateCountDownTimer(_:)), userInfo: nil, repeats: true)
  }
  
  private func stopCountDownTimer() {
    timeDef = 0
    timerN?.invalidate()
  }
  
  @objc
  private func updateCountDownTimer(_ timer: Timer) {
    timeDef = timeDef+1
    print("-- second: \(timeDef)")
  }
  
  private func setup() {
    setupUI()
    setupAction()
    setupVideoResolution()
    setupVideoOrientationDevice()
    
    initCamera()
  }
  
  private func initCamera() {
    cameraDelegate = self
    flashMode = .off
    
  }
  
  private func setupUI() {
    view.addSubview(actionButton)
    actionButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(32)
      make.centerX.equalToSuperview()
    }
    
    view.addSubview(flashButton)
    flashButton.snp.makeConstraints { make in
      make.centerY.equalTo(actionButton)
      make.right.equalToSuperview().inset(24)
    }
    
    view.addSubview(progressIndicator)
    progressIndicator.snp.makeConstraints { make in
      make.centerX.centerY.equalToSuperview()
      make.size.equalTo(42)
    }
    
  }
  
  private func setupAction() {
    actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    flashButton.addTarget(self, action: #selector(didTapFlashButton), for: .touchUpInside)
  }
  
  private func setActionButtonState(isRecording: Bool = false) {
    actionButton.setTitle(isRecording ? "Stop" : "Record", for: .normal)
  }
  
  private func setupVideoResolution() {
    /// Set the video resolution, but limited
    videoQuality = .resolution640x480
  }
  
  private func setupVideoMaxDuration(seconds: TimeInterval) {
    /// Handle the view maximum duration, in second
    if seconds != 0 && seconds > 0 {
      timerN = Timer.scheduledTimer(timeInterval: seconds, target: self, selector:  #selector(didFinishVideoDuration), userInfo: nil, repeats: false)
    }
  }
  
  private func setupVideoOrientationDevice() {
    /// Handle  the orientation of the capture photos to allow support for landscape images by device orientation
    /// Make sure device orientation is ON
    shouldUseDeviceOrientation = true
  }
  
  @objc func didFinishVideoDuration() {
    stopVideoRecording()
  }
  
  @objc func didTapFlashButton() {
    switch flashMode {
    case .auto:
      flashMode = .on
      flashButton.setImage(UIImage(named: "ic_flash_on"), for: UIControl.State())
    case .on:
      flashMode = .off
      flashButton.setImage(UIImage(named: "ic_flash_off"), for: UIControl.State())
    case .off:
      flashMode = .auto
      flashButton.setImage(UIImage(named: "ic_flash_auto"), for: UIControl.State())
    }
  }
  
  @objc func didTapActionButton() {
    if isVideoRecording == false {
      startVideoRecording()
      return
    }
    stopVideoRecording()
  }
  
  private func navigateToPreviewVideo(with url: URL) {
    let vc = PreviewVideoViewController(videoURL: url)
    present(vc, animated: true)
  }
}

extension CameraViewController: SwiftyCamViewControllerDelegate {
  
  func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCam.SwiftyCamViewController) {
    
  }
  
  func swiftyCamSessionDidStopRunning(_ swiftyCam: SwiftyCam.SwiftyCamViewController) {
    
  }
  
  func swiftyCam(_ swiftyCam: SwiftyCam.SwiftyCamViewController, didTake photo: UIImage) {
    
  }
  
  func swiftyCam(_ swiftyCam: SwiftyCam.SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCam.SwiftyCamViewController.CameraSelection) {
    print("VID: start recording")
    startCountDownTimer()
    setActionButtonState(isRecording: true)
  }
  
  func swiftyCam(_ swiftyCam: SwiftyCam.SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCam.SwiftyCamViewController.CameraSelection) {
    print("VID: finish recording")
    stopCountDownTimer()
    setActionButtonState(isRecording: false)
    progressIndicator.isHidden.toggle()
  }
  
  func swiftyCam(_ swiftyCam: SwiftyCam.SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
    print("VID: finish processing, push to preview with url = \(url)")
    videoProcessing(url: url)
  }
  
  func swiftyCam(_ swiftyCam: SwiftyCam.SwiftyCamViewController, didFailToRecordVideo error: Error) {
    
  }
  
  func swiftyCam(_ swiftyCam: SwiftyCam.SwiftyCamViewController, didSwitchCameras camera: SwiftyCam.SwiftyCamViewController.CameraSelection) {
    
  }
  
  func swiftyCam(_ swiftyCam: SwiftyCam.SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
    
  }
  
  func swiftyCam(_ swiftyCam: SwiftyCam.SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
    
  }
  
  func swiftyCamDidFailToConfigure(_ swiftyCam: SwiftyCam.SwiftyCamViewController) {
    
  }
  
  func swiftyCamNotAuthorized(_ swiftyCam: SwiftyCam.SwiftyCamViewController) {
    
  }
}


extension CameraViewController {
  func videoProcessing(url: URL) {
    guard let data = try? Data(contentsOf: url) else {
      return
    }
    print("VID: File size before compression: \(Double(data.count / 1048576)) mb")
    let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
    compressVideo(inputURL: url,
                  outputURL: compressedURL) { exportSession in
      guard let session = exportSession else {
        return
      }
      
      switch session.status {
      case .completed:
        guard let compressedData = try? Data(contentsOf: compressedURL) else {
          return
        }
        print("VID: File size after compression: \(Double(compressedData.count / 1048576)) mb")
        DispatchQueue.main.async {
          self.progressIndicator.isHidden.toggle()
          self.navigateToPreviewVideo(with: compressedURL)
        }
      default:
        break
      }
    }
  }
  
  func compressVideo(inputURL: URL,
                     outputURL: URL,
                     handler:@escaping (_ exportSession: AVAssetExportSession?) -> Void) {
    let urlAsset = AVURLAsset(url: inputURL, options: nil)
    guard let exportSession = AVAssetExportSession(asset: urlAsset,
                                                   presetName: AVAssetExportPreset640x480) else {
      handler(nil)
      return
    }
    
    exportSession.outputURL = outputURL
    exportSession.outputFileType = .mp4
    exportSession.exportAsynchronously {
      handler(exportSession)
    }
  }
}
