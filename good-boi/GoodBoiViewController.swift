//
//  ViewController.swift
//  good-boi
//
//  Created by Nicholas Kaffine on 12/23/18.
//  Copyright © 2018 Nicholas Kaffine. All rights reserved.
//

import UIKit
import Vision

enum DogClassification
{
    case dog, notDog
}

class GoodBoiViewController: UIViewController {
    private var avHandler: AVHandlerProtocol?
    private var errorQueue: [CameraViewError]? = []
    private var model: VNCoreMLModel?
    
    @IBOutlet var modelLabel: UILabel!
    @IBOutlet var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.frame = view.bounds
        modelLabel.text = nil
        model = try? VNCoreMLModel(for: DogClassifier().model)
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
        avHandler?.setupPreviewLayer(on: cameraView)
    }
    
    func recognized(_ classificiation: DogClassification)
    {
        switch classificiation
        {
            case .dog:
                self.modelLabel.text = "Dog"
            case .notDog:
                self.modelLabel.text = "Not Dog"
        }
    }
    
    @IBAction func mainViewTapped(_ sender: UITapGestureRecognizer)
    {
        modelLabel.text = nil
        avHandler?.initiatePhotoCapture()
    }
}

extension GoodBoiViewController: AVHandlerDelegate
{
    func captureSucceeded(with photo: CGImage) {
        guard let model = model else
        {
            return
        }
        let request = VNCoreMLRequest(model: model)
        { finishedRequest, error in
            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
            guard let observation = results.first else { return }
            
            observation.identifier == "dog" ? self.recognized(.dog) : self.recognized(.notDog)
        }
        
        request.imageCropAndScaleOption = .centerCrop
        let requestHandler = VNImageRequestHandler(cgImage: photo, options: [:])
        do
        {
            try requestHandler.perform([request])
        }
        catch
        {
            print("it failed")
        }
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

