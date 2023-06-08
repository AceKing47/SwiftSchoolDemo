//
//  ImageClassificationView.swift
//  FlowerClassifierSwiftUI
//
//  Created by Gerrit Zeissl on 08.06.23.
//

import AVFoundation
import Vision // If an error occurs here: https://www.hackingwithswift.com/forums/ios/cannot-load-underlying-module-for-avfoundation-xcode-error/22213 (uncheck Settings -> General -> "Show live issues")

class CameraViewModel: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()
    @Published var classifications: [ObjectDetectionResult] = []
    
    func setupCamera() {
        guard let camera = AVCaptureDevice.default(for: .video) else {
            fatalError("No video camera available")
        }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            captureSession.addInput(cameraInput)
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
            captureSession.addOutput(videoOutput)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func startCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
}

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let request = VNCoreMLRequest(model: try! VNCoreMLModel(for: FlowerClassifier_2(configuration: MLModelConfiguration()).model)) { request, error in
            
            guard let observations = request.results as? [VNClassificationObservation] else {
                return
            }
            
            let results = observations.map { observation -> ObjectDetectionResult in
                let name = observation.identifier
                let confidence = observation.confidence
                return ObjectDetectionResult(name: name, confidence: confidence)
            }
            
            DispatchQueue.main.async {
                self.classifications = results
            }
        }
        
        try! VNImageRequestHandler(cvPixelBuffer: imageBuffer, options: [:]).perform([request])
    }
}

struct ObjectDetectionResult {
    let name: String
    let confidence: VNConfidence
}
