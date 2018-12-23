//
//  ViewController.swift
//  good-boi
//
//  Created by Nicholas Kaffine on 12/23/18.
//  Copyright © 2018 Nicholas Kaffine. All rights reserved.
//

import UIKit

class GoodBoiViewController: UIViewController {
    private var avHandler: AVHandlerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avHandler = AVHandler()
        avHandler?.setupPreviewLayer(on: view)
        avHandler?.delegate = self
    }
    
    @IBAction func mainViewTapped(_ sender: UITapGestureRecognizer)
    {
        avHandler?.initiatePhotoCapture()
    }
}

extension GoodBoiViewController: AVHandlerDelegate
{
    func captureSucceeded(with photo: CGImage) {
        print("received an image")
    }
    
    func failed(with error: CameraViewError) {
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alertController, animated: true, completion: nil)
    }
}

