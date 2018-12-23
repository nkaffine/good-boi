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
    private var errorQueue: [CameraViewError]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVHandler()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Dealing with the fact that errors thrown in the view did load won't be presented
        //because the view hasn't appeared yet
        if let queue = errorQueue, !queue.isEmpty, let error = queue.first
        {
            errorQueue = nil
            failed(with: error)
        }
    }
    
    func setupAVHandler()
    {
        avHandler = AVHandler()
        avHandler?.delegate = self
        avHandler?.setupPreviewLayer(on: view)
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
        if errorQueue == nil
        {
            let alertController = UIAlertController(title: nil, message: error.message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alertController, animated: true, completion: nil)
        }
        else
        {
            errorQueue?.append(error)
        }
    }
}

