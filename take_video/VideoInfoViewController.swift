//
//  VideoInfoViewController.swift
//  take_video
//
//  Created by Mahisa Panatagama on 19/03/24.
//

import Foundation
import UIKit
import SwiftyCam
import SnapKit
import AVFoundation

class VideoInfoViewController: UIViewController {
  private lazy var stvInfo: UIStackView = {
    let view = UIStackView()
    view.axis = .vertical
    view.spacing = 4
    view.alignment = .center
    view.distribution = .fill
    return view
  }()
  
  var infoData: [String: String] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func updateViewConstraints() {
    self.view.frame.size.height = UIScreen.main.bounds.height - 150
    self.view.frame.origin.y =  150
    self.view.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
    super.updateViewConstraints()
  }
}

extension VideoInfoViewController {
  private func setup() {
    setupUI()
    
  }
  
  private func setupUI() {
    view.backgroundColor = .white
    view.addSubview(stvInfo)
    stvInfo.snp.makeConstraints { make in
      make.centerX.centerY.equalToSuperview()
    }
    
    infoData.forEach { (key: String, value: String) in
      let lblCounter: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = .black
        return lbl
      }()
      lblCounter.text = "\(key) \(value)"
      stvInfo.addArrangedSubview(lblCounter)
    }
  }
}

extension UIView {
  func roundCorners(corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    layer.mask = mask
  }
}
