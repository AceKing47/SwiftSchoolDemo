//
//  ContentView.swift
//  FlowerClassifierSwiftUI
//
//  Created by Gerrit Zeissl on 04.06.23.
//

import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraViewModel.captureSession)
            BoundingBoxView(classifications: cameraViewModel.classifications)
        }
        .onAppear {
            cameraViewModel.setupCamera()
            cameraViewModel.startCaptureSession()
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let cameraView = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(previewLayer)
        return cameraView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

struct BoundingBoxView: View {
    let classifications: [ObjectDetectionResult]
    
    var body: some View {
        
        let classification = classifications.first(where: {$0.confidence > 0.9}) ?? ObjectDetectionResult(name: "Unknown", confidence: 0)
        
        VStack {
            Spacer()
            Text(String(format: "%@: %.02f%%", classification.name, classification.confidence * 100))
                .foregroundColor(.white)
                .background(Color.black)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
