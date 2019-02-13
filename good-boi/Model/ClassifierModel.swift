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

class ClassifierModel<ClassifiedType: RawRepresentable>: ClassifierProtocol where ClassifiedType.RawValue == String
{
    typealias ClassificationType = ClassifiedType
    private var model: VNCoreMLModel?
    weak var delegate: ClassifierDelegate?
    
    init(model: MLModel)
    {
        self.model = try? VNCoreMLModel(for: model)
    }
    
    func classify(_ imageBuffer: CVImageBuffer, completion: @escaping (ClassifiedType) -> ()) {
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
            guard let classification = ClassifiedType.init(rawValue: observation.identifier) else
            {
                self.delegate?.failedToClassify(with: .classificationParsingError)
                return
            }
            completion(classification)
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
