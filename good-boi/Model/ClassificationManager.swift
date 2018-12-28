//
//  ClassificationManager.swift
//  good-boi
//
//  Created by Nicholas Kaffine on 12/27/18.
//  Copyright © 2018 Nicholas Kaffine. All rights reserved.
//

import Foundation
import UIKit

protocol ClassificationManagerProtocol
{
    /**
     The delegate for the classification managers
    */
    var delegate: ClassificationManagerDelegate? { get set }
    
    /**
     Starts or resumes the session of image capturing and image classification
     */
    func startSession()
    /**
     Pauses the session to stop image capturing and image classification
     */
    func pauseSession()
    /**
     Pauses the session and indicates that the session is not going to be started again
    */
    func endSession()
}

protocol ClassificationManagerDelegate
{
    /**
     Called whenever there is an error in the underlying CoreMLModel or the image capturing
     - Parameter error: The error that ocurred in the process of image classification
     */
    func failed(with error: ClassificationError)
    /**
     Called whenever the CoreMLModel succesfully classifies an image
     - Parameter type: The result of the classification
     */
    func didClassify(with type: DogClassification)
}

/**
 Errors that can occur during the process of image capturing and image classification
 */
enum ClassificationError
{
    /**
     An error that involves image capturing
     */
    case camera(error: CameraViewError)
    /**
     An error that involves image classification
    */
    case classification(error: DogClassificationError)
}

private enum ManagerStatus
{
    case notStarted, inProgress, paused, ended
}

/**
 Implentation of the ClassificationManagerProtocol
 
 In the current implementation of this there is no difference between end session and pause session.
 */
class ClassificationManager: ClassificationManagerProtocol
{
    private var avHandler: AVHandlerProtocol
    private var classifier: DogClassifierModel
    private var sessionStatus = ManagerStatus.notStarted

    var delegate: ClassificationManagerDelegate?
    
    init(view: UIView, delegate: ClassificationManagerDelegate?)
    {
        self.delegate = delegate
        avHandler = AVHandler()
        classifier = DogClassifierModel()
        classifier.delegate = self
        avHandler.delegate = self
        avHandler.setupPreviewLayer(on: view)
    }
    
    private func capture()
    {
        guard sessionStatus == .inProgress else
        {
            return
        }
        if avHandler.status == .idle
        {
            avHandler.initiatePhotoCapture()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.capture()
        }
    }
    
    func startSession()
    {
        sessionStatus = .inProgress
        capture()
    }
    
    func pauseSession()
    {
        sessionStatus = .paused
    }
    
    func endSession()
    {
        sessionStatus = .ended
    }
}

extension ClassificationManager: AVHandlerDelegate
{
    func captureSucceeded(with photo: CGImage) {
        classifier.classify(photo)
    }
    
    func failed(with error: CameraViewError) {
        sessionStatus = .ended
        delegate?.failed(with: .camera(error: error))
    }
}

extension ClassificationManager: DogClassifierDelegate
{
    func didClassify(with type: DogClassification) {
        delegate?.didClassify(with: type)
    }
    
    func failedToClassify(with error: DogClassificationError) {
        delegate?.failed(with: .classification(error: error))
    }
}
