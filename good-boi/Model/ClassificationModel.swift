//
//  ClassificationModel.swift
//  good-boi
//
//  Created by Nicholas Kaffine on 1/6/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation
import AVFoundation

/**
 Errors that can occur during the classification process
 */
enum ClassifierError
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
 The protocol for the classifier delegate
 */
protocol ClassifierDelegate
{
    associatedtype ClassificationType: RawRepresentable where ClassificationType.RawValue == String

    /**
     Called when the classifier successfully classifies an image

     - Parameter type: The classification result of the image classifier
     */
    func didClassify(with type: ClassificationType)

    /**
     Called when the classifier fails to classify the image

     - Parameter error: the error that occurred during the image classification
     */
    func failedToClassify(with error: ClassifierError)
}

/**
 The protocol for the image classifier
 */
protocol ClassifierProtocol: class
{
    associatedtype ClassificationType
    associatedtype Delegate: ClassifierDelegate where Delegate.ClassificationType == ClassificationType

    /**
     The delegate for the image classifier
     */
    var delegate: Delegate? { get set }

    /**
     Starts the classification process with the given image buffer that will call the delegate with the result
     of the classification.

     - Parameter imageBuffer: the image buffer for the classifier to classify.
     */
    func classify(_ imageBuffer: CVImageBuffer)
}

class Classifier<ClassificationType: RawRepresentable, Delegate: ClassifierDelegate> where ClassificationType.RawValue == String, ClassifierDelegate.ClassificationType == ClassificationType
{
    
}
