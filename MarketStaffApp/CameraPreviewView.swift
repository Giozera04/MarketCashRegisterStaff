//
//  CameraPreviewView.swift
//  MarketStaffApp
//
//  Created by Giovane Junior on 6/22/25.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewControllerRepresentable {
    @Binding var didScan: Bool
    @Binding var scanningEnabled: Bool
    @Binding var isActive: Bool // NEW
    var onBarcodeScanned: (String) -> Void
    var scanRect: CGRect

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: CameraPreviewView
        var session: AVCaptureSession?

        init(parent: CameraPreviewView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard !parent.didScan, parent.scanningEnabled else { return }

            if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let code = object.stringValue {
                parent.didScan = true
                parent.onBarcodeScanned(code)
            }
        }

        func stopSession() {
            session?.stopRunning()
            session = nil
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        let session = AVCaptureSession()
        context.coordinator.session = session

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return vc }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
            output.metadataObjectTypes = [.ean13, .ean8, .upce, .code128]
            
            // No conversion here — scanRect is already normalized from SwiftUI
            output.rectOfInterest = scanRect
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = .resizeAspectFill
        vc.view.layer.addSublayer(previewLayer)

        let convertedRect = previewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)
        output.rectOfInterest = convertedRect

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if !isActive {
            context.coordinator.stopSession()
        }
    }
}
