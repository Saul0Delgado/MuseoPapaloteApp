//
//  ScannerBody.swift
//  PapaloteMenuLista
//
//  Created by alumno on 14/11/24.
//

import UIKit
import AVFoundation
import Vision

class CameraViewControllerTM: UIViewController, AVCapturePhotoCaptureDelegate {

    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var albumViewModel: IconAlbumViewModel? // Optional to prevent crashes
    var onIconDetected: ((String, UIImage) -> Void)?
    
    

    // Buttons to capture photo
    let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Capturar", for: .normal)
        button.backgroundColor = .accent
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.transform = CGAffineTransform(scaleX: 1.20, y: 1.20) // Increase size by 1.5x

        return button
    }()
    
    // Results view to show matches
    let resultsLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black.withAlphaComponent(0.7)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // CoreML model
    let model = try? PapaloteVision2(configuration: MLModelConfiguration())

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCamera()
    }

    func setupUI() {
        // Add and configure capture button
        view.addSubview(captureButton)
        captureButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        captureButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)

        // Add and configure results label
        view.addSubview(resultsLabel)
        resultsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        resultsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        resultsLabel.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -20).isActive = true
        resultsLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoDeviceInput) else {
            showAlert(message: "Failed to setup camera")
            return
        }

        captureSession.addInput(videoDeviceInput)

        photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else {
            showAlert(message: "Failed to setup photo output")
            return
        }
        captureSession.addOutput(photoOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    @objc func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)

        // Visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.captureButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.captureButton.transform = .identity
            }
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            showAlert(message: "Error capturing photo: \(error.localizedDescription)")
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let capturedImage = UIImage(data: imageData) else {
            showAlert(message: "Error converting photo")
            return
        }

        classifyCapturedImage(capturedImage)
    }

    func classifyCapturedImage(_ image: UIImage) {
        guard let model = model else {
            showAlert(message: "CoreML model not loaded")
            return
        }

        guard let ciImage = CIImage(image: image) else {
            showAlert(message: "Failed to convert UIImage to CIImage")
            return
        }

        // Create CoreML request
        let request = VNCoreMLRequest(model: try! VNCoreMLModel(for: model.model)) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                self.showAlert(message: "No results from classification")
                return
            }

            // Get the top classification result
            if let topResult = results.first {
                DispatchQueue.main.async {
                    self.resultsLabel.text = "Detected: \(topResult.identifier) (\(Int(topResult.confidence * 100))%)"
                    if topResult.identifier == "Negative" || topResult.confidence < 0.95 {
                        self.onIconDetected?("No se encontró ningún ícono. Asegura de que el ícono esté claro y completo en la foto e intenta de nuevo.", image)
                    } else {
                        self.albumViewModel!.updateIcon(with: topResult.identifier, image: UIImage(named: "image_placeholder")!)
                        self.onIconDetected?(topResult.identifier, image)
                    }
                }
            }
        }

        // Perform the request
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                self.showAlert(message: "Failed to perform CoreML request: \(error.localizedDescription)")
            }
        }
    }

    func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

#Preview {
    CameraViewControllerTM()
}
