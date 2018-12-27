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
        manager = ClassificationManager(with: cameraView)
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

private extension ClassificationError
{
    var message: String
    {
        switch self
        {
        case .camera(let error):
            switch error
            {
                case .captureDeviceFailure:
                    return "capture device failed"
                case .deviceInputFailure:
                    return "device input failed"
                case .sessionFailure:
                    return "session failed"
                case .previewLayerFailure:
                    return "preview layer failed"
                case .photoCaptureFailure:
                    return "photo capture failed"
                case .deviceNotAccesible:
                    return "capture device not accessible"
                case .noDeviceAvailable:
                    return "no devices available"
            }
        case .classification(let error):
            switch error
            {
                case .modelError:
                    return "model error"
                case .observationError:
                    return "observation error"
                case .classificationParsingError:
                    return "failed to parse classification"
                case .classificationError:
                    return "classification failed"
            }
        }
    }
}
