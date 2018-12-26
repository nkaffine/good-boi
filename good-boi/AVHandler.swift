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
    sessionFailure, previewLayerFailure, photoCaptureFailure,
    deviceNotAccesible, noDeviceAvailable
    
    var message: String
    {
        switch self
        {
            case .captureDeviceFailure:
                return "The capture device failed to initialized"
            case .deviceInputFailure:
                return "The device input failed to initialize"
            case .sessionFailure:
                return "The capture session failed"
            case .previewLayerFailure:
                return "The preview layer failed to initialize"
            case .photoCaptureFailure:
                return "The photo capture failed"
            case .deviceNotAccesible:
                return "Device input is unaccessable"
            case .noDeviceAvailable:
                return "There is no compatible camera on this device"
        }
    }
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
        if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
        {
            AVCaptureDevice.requestAccess(for: .video)
            { [weak self] allowed in
                if allowed
                {
                    self?.setupPreviewLayer(on: view)
                }
            }
            return
        }
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else
        {
            delegate?.failed(with: .deviceNotAccesible)
            return
        }
        
        guard !AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInTelephotoCamera, .builtInDualCamera, .builtInTrueDepthCamera, .builtInWideAngleCamera], mediaType: .video, position: .back).devices.isEmpty else
        {
            delegate?.failed(with: .deviceNotAccesible)
            return
        }
        
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
}

extension AVHandler
{
    func initiatePhotoCapture() {
        guard let _ = captureSession else
        {
            delegate?.failed(with: .photoCaptureFailure)
            return
        }
        
        let photoSettings = AVCapturePhotoSettings(from: captureSettings)
        output.capturePhoto(with: photoSettings, delegate: self)
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
