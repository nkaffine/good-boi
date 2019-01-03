//
//  ViewController.swift
//  good-boi
//
//  Created by Nicholas Kaffine on 12/23/18.
//  Copyright © 2018 Nicholas Kaffine. All rights reserved.
//

import UIKit
import Vision

class GoodBoiViewController: UIViewController {
    private var errorQueue: [ClassificationError]?
    private var manager: ClassificationManager?
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet var tailWagger: TailWagger!
    @IBOutlet var privacyPolicyButton: UIButton!
    @IBOutlet var goodBoiDetectedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorQueue = []
        cameraView.frame = view.bounds
        manager = ClassificationManager(view: cameraView, delegate: self)
        manager?.delegate = self
        privacyPolicyButton.backgroundColor = .privacyPolicyRed
        privacyPolicyButton.setTitleColor(.white, for: .normal)
        privacyPolicyButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        privacyPolicyButton.layer.cornerRadius = privacyPolicyButton.frame.height / 4
        view.layoutIfNeeded()
        self.goodBoiDetectedImageView.isHidden = true
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
        errorQueue = nil
        manager?.startSession()
        tailWagger.startWagging()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        manager?.endSession()
        tailWagger.stopWagging()
    }
    
    @IBAction func privacyPolicyButtonTapped(_ sender: UIButton)
    {
        guard let privacyPolicyURL = URL(string: "https://good-boi.kaffine.tech/privacy-policy") else
        {
            return
        }
        UIApplication.shared.open(privacyPolicyURL)
    }
}

extension GoodBoiViewController: ClassificationManagerDelegate
{
    func didClassify(with type: DogClassification) {
        switch type
        {
            case .dog:
                tailWagger.stopWagging()
                goodBoiDetectedImageView.isHidden = false
            case .notDog:
                tailWagger.startWagging()
                goodBoiDetectedImageView.isHidden = true
        }
    }
    
    func failed(with error: ClassificationError) {
        if errorQueue == nil
        {
            switch error
            {
                case .classification:
                    //For know just silently fail when the model fails and make it say it
                    //can't detect a dog. This shouldn't happen often and shouldn't
                    //really take the user out of the experience if it does.
                    didClassify(with: .notDog)
                case .camera(let cameraError):
                    switch cameraError
                    {
                        case .photoCaptureFailure:
                            manager?.startSession()
                        
                        case .captureDeviceFailure, .deviceInputFailure, .sessionFailure,
                             .previewLayerFailure, .deviceNotAccesible, .noDeviceAvailable:
                            //Need to be careful here because the outlets are not set yet
                            let errorViewController = ErrorViewController()
                            errorViewController.errorTitle = cameraError.title
                            errorViewController.detail = cameraError.message
                            errorViewController.action = cameraError.action
                            present(errorViewController, animated: true, completion: nil)
                    }
            }
        }
        else
        {
            errorQueue?.append(error)
        }
    }
}

private extension CameraViewError
{
    var message: String
    {
        switch self
        {
            case .captureDeviceFailure, .deviceInputFailure, .sessionFailure,
                 .previewLayerFailure, .photoCaptureFailure:
                return "Please try again!"
            case .deviceNotAccesible:
                return "Go to settings and enable camera access so we can help you find good bois 🐶"
            case .noDeviceAvailable:
                return "The camera is an important part of the experience of this app. Please use a device with a camera."
        }
    }
    
    var title: String
    {
        switch self
        {
            case .captureDeviceFailure, .deviceInputFailure, .sessionFailure, .previewLayerFailure,
                 .photoCaptureFailure:
                return "Something went wrong with the camera"
            case .deviceNotAccesible:
                return "We don't have access to your camera"
            case .noDeviceAvailable:
                return "It looks like this device doesn't have a camera"
        }
    }
    
    var action: ErrorButtonAction
    {
        switch self
        {
            case .captureDeviceFailure, .deviceInputFailure, .sessionFailure,
                 .previewLayerFailure, .photoCaptureFailure:
                return .dismiss
            case .deviceNotAccesible:
                return .settings
            case .noDeviceAvailable:
                return .none
        }
    }
}
