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
    private var errorQueue: [ClassificationError]? = []
    private var manager: ClassificationManager?
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet var tailWagger: TailWagger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.frame = view.bounds
        manager = ClassificationManager(view: cameraView, delegate: self)
        manager?.delegate = self
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
        manager?.startSession()
        tailWagger.startWagging()
    }
}

extension GoodBoiViewController: ClassificationManagerDelegate
{
    func didClassify(with type: DogClassification) {
        switch type
        {
            case .dog:
                tailWagger.stopWagging()
            case .notDog:
                tailWagger.startWagging()
        }
    }
    
    func failed(with error: ClassificationError) {
        if errorQueue == nil
        {
            //Need to be careful here because the outlets are not set yet
            let errorViewController = ErrorViewController()
            errorViewController.errorTitle = error.title
            errorViewController.detail = error.message
            errorViewController.action = error.action
            present(errorViewController, animated: true, completion: nil)
        }
        else
        {
            errorQueue?.append(error)
        }
    }
}

private extension ClassificationError
{
    var message: String
    {
        switch self
        {
        case .camera(let error):
            switch error
            {
                case .captureDeviceFailure, .deviceInputFailure, .sessionFailure,
                     .previewLayerFailure, .photoCaptureFailure:
                    return "Please try again!"
                case .deviceNotAccesible:
                    return "Go to settings and enable camera access so we can help you find good bois 🐶"
                case .noDeviceAvailable:
                    return "The camera is an important part of the experience of this app. Please use a device with a camera."
            }
        case .classification:
            return "Something went wrong while determine if there was a good boi on the screen. Please try again."
        }
    }
    
    var title: String
    {
        switch self
        {
            case .camera(let error):
                switch error
                {
                case .captureDeviceFailure, .deviceInputFailure, .sessionFailure, .previewLayerFailure,
                     .photoCaptureFailure:
                    return "Something went wrong with the camera"
                case .deviceNotAccesible:
                    return "We don't have access to your camera"
                case .noDeviceAvailable:
                    return "It looks like this device doesn't have a camera"
                }
            case .classification:
                return "We may have experienced a cuteness overload there 🐶"
        }
    }
    
    var action: ErrorButtonAction
    {
        switch self
        {
            case .camera(let error):
                switch error
                {
                    case .captureDeviceFailure, .deviceInputFailure, .sessionFailure,
                         .previewLayerFailure, .photoCaptureFailure, .noDeviceAvailable:
                        return .dismiss
                    case .deviceNotAccesible:
                        return .settings
                }
            case .classification:
                return .dismiss
        }
    }
}
