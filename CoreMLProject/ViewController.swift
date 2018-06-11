//
//  ViewController.swift
//  CoreMLProject
//
//  Created by Gennaro Amura on 11/06/2018.
//  Copyright © 2018 Gennaro Amura. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let labelType = UILabel()
    let labelScore = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        labelType.frame = CGRect(x: self.view.frame.midX - 150, y: 580, width: 300, height: 50)
        labelType.text = "Starting Session"
        labelScore.frame = CGRect(x: self.view.frame.midX - 150, y: 620, width: 300, height: 50)
        labelScore.text = "0%"
        self.view.addSubview(labelType)
        self.view.addSubview(labelScore)
        setAVSession()
    }
    
    func setAVSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        session.addInput(input)
        session.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        self.view.layer.addSublayer(previewLayer)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueu"))
        session.addOutput(videoOutput)
        labelType.text = "Session start"
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("frame update")
        
        guard let pixelBuffer: CVPixelBuffer =  sampleBuffer.imageBuffer else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else { return }
            guard let firstResult = results.first else { return }
            
            DispatchQueue.main.async {
                self.labelType.text = "\(firstResult.identifier)"
                self.labelScore.text = "\(firstResult.confidence*100)%"
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])

    }


}

