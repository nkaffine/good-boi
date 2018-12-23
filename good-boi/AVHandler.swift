//
//  CameraViewController.swift
//  good-boi
//
//  Created by Nicholas Kaffine on 12/23/18.
//  Copyright © 2018 Nicholas Kaffine. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

enum CameraViewError: Error
{
    case captureDeviceFailure, deviceInputFailure,
    sessionFailure, previewLayerFailure, photoCaptureFailure
}

protocol AVHandlerDelegate: class
{
    func failed(with error: CameraViewError)
    func captureSucceeded(with photo: CGImage)
}

protocol AVHandlerProtocol
{
    func initiatePhotoCapture()
    func setupPreviewLayer(on view: UIView)
    
    var delegate: AVHandlerDelegate? { get set }
}

class AVHandler: NSObject, AVHandlerProtocol
{
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var output: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private var captureSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
    
    weak var delegate: AVHandlerDelegate?
    
    func setupPreviewLayer(on view: UIView) {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else
        {
            delegate?.failed(with: .captureDeviceFailure)
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else
        {
            delegate?.failed(with: .deviceInputFailure)
            return
        }
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(input)
        
        if let captureSession = captureSession
        {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            if let layer = videoPreviewLayer
            {
                view.layer.addSublayer(layer)
                captureSession.startRunning()
                captureSession.addOutput(output)
            }
            else
            {
                delegate?.failed(with: .previewLayerFailure)
            }
        }
        else
        {
            delegate?.failed(with: .sessionFailure)
        }
    }
    
    @IBAction func mainViewTapped(_ sender: UITapGestureRecognizer)
    {
        initiatePhotoCapture()
    }
}

extension AVHandler
{
    func initiatePhotoCapture() {
        let photoSettings = AVCapturePhotoSettings(from: captureSettings)
        output.capturePhoto(with: photoSettings, delegate: self)
        print("Initiated Capture")
    }
}

extension AVHandler: AVCapturePhotoCaptureDelegate
{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    {
        if let cgImage = photo.cgImageRepresentation()
        {
            delegate?.captureSucceeded(with: cgImage.takeUnretainedValue())
        }
        else
        {
            delegate?.failed(with: .photoCaptureFailure)
        }
    }
}
