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

protocol CameraViewDelegate: class
{
    func failed(with error: CameraViewError)
    func captureSucceeded(with photo: CGImage)
}

protocol CameraViewProtocol
{
    func initiateCapture()
}

class CameraViewController: UIViewController
{
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var output: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private var captureSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
    
    weak var delegate: CameraViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
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
        initiateCapture()
    }
}

extension CameraViewController: CameraViewProtocol
{
    func initiateCapture() {
        let photoSettings = AVCapturePhotoSettings(from: captureSettings)
        output.capturePhoto(with: photoSettings, delegate: self)
        print("Initiated Capture")
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate
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

extension CameraViewController: CameraViewDelegate
{
    func captureSucceeded(with photo: CGImage) {
        print("received an image")
    }
    
    func failed(with error: CameraViewError) {
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alertController, animated: true, completion: nil)
    }
}
