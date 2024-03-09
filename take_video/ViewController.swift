//
//  ViewController.swift
//  take_video
//
//  Created by Mahisa Panatagama on 08/03/24.
//

import UIKit

class ViewController: UIViewController {
    static func createModule() -> ViewController {
        let storyboardId = String(describing: ViewController.self)
        let storyboard = UIStoryboard(name: storyboardId, bundle: nil)
        guard let view = storyboard.instantiateViewController(withIdentifier: storyboardId) as? ViewController else {
            fatalError("Error loading Storyboard")
        }
        return view
    }
    
    @IBAction func takeVideoAction(_ sender: UIButton) {
        let vc = CameraViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectVideoAction(_ sender: UIButton) {
        
    }
}
