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

/**
 Errors that occur during the process of capturing an image
 */
enum CameraViewError: Error
{
    /**
     Occurs when the capture device fails to initialize
     */
    case captureDeviceFailure
    /**
     Occurs when the device input fails to initialize
     */
    case deviceInputFailure
    /**
     Occurs when the capture session fails to initialize
     */
    case sessionFailure
    /**
     Occurs when the preview layer fails to initialize
     */
    case previewLayerFailure
    /**
     Occurs when the capture session fails to initialize
     */
    case photoCaptureFailure
    /**
     Occurs when the device permissions have been denied
     */
    case deviceNotAccesible
    /**
     Occurs when the device has no rear camera
     */
    case noDeviceAvailable
}

/**
 The status of the current capture to prevent multiple requests being sent
 */
enum CaptureStatus
{
    /**
     There is an image capture in progress
     */
    case processing
    /**
     There is not an image capture in progress
    */
    case idle
}

/**
 Delegate for the AVHandler
 */
protocol AVHandlerDelegate: class
{
    /**
     Called when there was an error while setting up the preview or capturing the image
     
     - Parameter error: The error that ocurred either setting up the preview or capturing the image
     */
    func failed(with error: CameraViewError)
    /**
     Called when the capture is successful
     
     - Parameter photo: The image that was captured
     */
    func captureSucceeded(with photo: CGImage)
}

/**
 Protocol for AVHandler
 */
protocol AVHandlerProtocol
{
    /**
     Initiates a image capture that will be sent to the delegate
     */
    func initiatePhotoCapture()
    /**
     Adds a layer with a preview of the rear facing camera to the given view
     
     - Parameter view: The view that will have the preview of the rear facing camera on it
     */
    func setupPreviewLayer(on view: UIView)
    
    /**
     Delegate for the AVHandler
     */
    var delegate: AVHandlerDelegate? { get set }
    /**
     The current status of the image capture
    */
    var status: CaptureStatus { get }
    
    /**
     Whether or not the app has been given permission to use the camera.
     */
    static var isAuthorized: Bool { get }
}

class AVHandler: NSObject, AVHandlerProtocol
{
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var output: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private var captureSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
    
    weak var delegate: AVHandlerDelegate?
    private (set) var status: CaptureStatus = .idle
    static var isAuthorized: Bool
    {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    func setupPreviewLayer(on view: UIView) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
        {
            AVCaptureDevice.requestAccess(for: .video)
            { [weak self] allowed in
                if allowed
                {
                    self?.setupPreviewLayer(on: view)
                }
                else
                {
                    self?.failed(with: .deviceNotAccesible)
                }
            }
            return
        }
      
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else
        {
            failed(with: .deviceNotAccesible)
            return
        }
        
        guard !AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInTelephotoCamera, .builtInDualCamera, .builtInTrueDepthCamera, .builtInWideAngleCamera], mediaType: .video, position: .back).devices.isEmpty else
        {
            failed(with: .noDeviceAvailable)
            return
        }
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else
        {
            failed(with: .captureDeviceFailure)
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else
        {
            failed(with: .deviceInputFailure)
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
                failed(with: .previewLayerFailure)
            }
        }
        else
        {
            failed(with: .sessionFailure)
        }
    }
    
    private func failed(with error: CameraViewError)
    {
        delegate?.failed(with: error)
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
        
        status = .processing
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
            status = .idle
        }
        else
        {
            delegate?.failed(with: .photoCaptureFailure)
            status = .idle
        }
    }
}
