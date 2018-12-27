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

enum DogClassification: String
{
    case dog = "dog"
    case notDog = "not_dog"
}

enum DogClassificationError
{
    case modelError, observationError, classificationParsingError, classificationError
}

protocol DogClassifierProtocol: class
{
    var delegate: DogClassifierDelegate? { get set }
    func classify(_ photo: CGImage)
}

protocol DogClassifierDelegate: class
{
    func didClassify(with type: DogClassification)
    
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
    
    func classify(_ photo: CGImage) {
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
        let requestHandler = VNImageRequestHandler(cgImage: photo, options: [:])
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
