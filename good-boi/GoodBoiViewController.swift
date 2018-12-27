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
    private var avHandler: AVHandlerProtocol?
    private var errorQueue: [CameraViewError]? = []
    private var classifier: DogClassifierModel = DogClassifierModel()
    
    @IBOutlet var modelLabel: UILabel!
    @IBOutlet var cameraView: UIView!
    @IBOutlet var tailWagger: TailWagger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.frame = view.bounds
        modelLabel.text = nil
        setupAVHandler()
        classifier.delegate = self
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
        avHandler?.setupPreviewLayer(on: cameraView)
    }
    
    @IBAction func mainViewTapped(_ sender: UITapGestureRecognizer)
    {
        tailWagger.startWagging()
//        modelLabel.text = nil
//        avHandler?.initiatePhotoCapture()
    }
}

extension GoodBoiViewController: DogClassifierDelegate
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
    
    func failedToClassify(with error: DogClassificationError) {
        let alertController = UIAlertController(title: nil, message: "\(error)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alertController, animated: true, completion: nil)
    }
}

extension GoodBoiViewController: AVHandlerDelegate
{
    func captureSucceeded(with photo: CGImage) {
        classifier.classify(photo)
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
