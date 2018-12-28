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
    var delegate: ClassificationManagerDelegate? { get set }
    
    func startSession()
    func pauseSession()
    func endSession()
}

protocol ClassificationManagerDelegate
{
    func failed(with error: ClassificationError)
    func didClassify(with type: DogClassification)
}

enum ClassificationError
{
    case camera(error: CameraViewError), classification(error: DogClassificationError)
}

private enum ManagerStatus
{
    case notStarted, inProgress, paused, ended
}

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
