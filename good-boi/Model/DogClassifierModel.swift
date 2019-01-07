//
//  DogClassifier.swift
//  good-boi
//
//  Created by Nicholas Kaffine on 12/27/18.
//  Copyright © 2018 Nicholas Kaffine. All rights reserved.
//

import Foundation
import UIKit
import Vision

/**
 Enum to represent the results of the dog classifier
 */
enum DogClassification: String
{
    /**
     The case where the classifier determines the image was a dog
    */
    case dog = "dog"
    /**
     The case where the classifier determines the image was not a dog
     */
    case notDog = "not_dog"
}

/**
 Errors that can occur during the classification process
 */
enum DogClassificationError
{
    /**
     Occurs when the CoreML model request does not return the expected result
     */
    case modelError
    /**
     Occurs when there are no observations from the CoreML model request
    */
    case observationError
    /**
     Occurs when the results enum initializer fails.
     */
    case classificationParsingError
    /**
     Occurs when there is an error in the CoreML model request
     */
    case classificationError
}

/**
 The protocol for the image classifier
 */
protocol DogClassifierProtocol: class
{
    /**
     The delegate for the image classifier
     */
    var delegate: DogClassifierDelegate? { get set }
   
    /**
     Starts the classification process with the given image buffer that will call the delegate with the result
     of the classification.
     
     - Parameter imageBuffer: the image buffer for the classifier to classify.
    */
    func classify(_ imageBuffer: CVImageBuffer)
}

/**
 The protocol for the classifier delegate
 */
protocol DogClassifierDelegate: class
{
    /**
     Called when the classifier successfully classifies an image
     
     - Parameter type: The classification result of the image classifier
     */
    func didClassify(with type: DogClassification)
    
    /**
     Called when the classifier fails to classify the image
     
     - Parameter error: the error that occurred during the image classification
    */
    func failedToClassify(with error: DogClassificationError)
}

class DogClassifierModel: DogClassifierProtocol
{
    private var model: VNCoreMLModel?
    weak var delegate: DogClassifierDelegate?
    
    init()
    {
        model = try? VNCoreMLModel(for: DogClassifier().model)
    }
    
    func classify(_ imageBuffer: CVImageBuffer) {
        guard let model = model else
        {
            return
        }
        let request = VNCoreMLRequest(model: model)
        { finishedRequest, error in
            guard let results = finishedRequest.results as? [VNClassificationObservation] else
            {
                self.delegate?.failedToClassify(with: .modelError)
                return
            }
            guard let observation = results.first else
            {
                self.delegate?.failedToClassify(with: .observationError)
                return
            }
            guard let classification = DogClassification(rawValue: observation.identifier) else
            {
                self.delegate?.failedToClassify(with: .classificationParsingError)
                return
            }
            self.delegate?.didClassify(with: classification)
        }
        
        request.imageCropAndScaleOption = .centerCrop
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, options: [:])
        do
        {
            try requestHandler.perform([request])
        }
        catch
        {
            delegate?.failedToClassify(with: .classificationError)
        }
    }
}
