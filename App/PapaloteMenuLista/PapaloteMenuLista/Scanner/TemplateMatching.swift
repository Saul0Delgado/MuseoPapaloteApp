import Foundation
import UIKit
import AVFoundation
import Vision

class CameraViewControllerTM: UIViewController, AVCapturePhotoCaptureDelegate {
    
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // Buttons to capture photo
    let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Capture", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
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
    
    // Reference images for template matching
    var greenIcon: UIImage?
    var redIcon: UIImage?
    var blueIcon: UIImage?
    var yellowIcon: UIImage?
    var purpleIcon: UIImage?
    var orangeIcon: UIImage?
    
    // Add enum for icon colors
    enum IconColor: String, CaseIterable {
        case red, green, blue, yellow, purple, orange
        
        var hsvRange: (min: CGFloat, max: CGFloat, minSaturation: CGFloat, minValue: CGFloat) {
            switch self {
            case .red:
                // Red can wrap around hue circle (both near 0° and near 360°)
                return (350/360, 10/360, 0.4, 0.3)
            case .green:
                // Wider range for green hues
                return (90/360, 150/360, 0.3, 0.3)
            case .blue:
                return (190/360, 250/360, 0.4, 0.3)
            case .yellow:
                return (45/360, 75/360, 0.4, 0.5)
            case .purple:
                return (260/360, 300/360, 0.3, 0.3)
            case .orange:
                return (15/360, 45/360, 0.4, 0.4)
            }
        }
    }
    
    // Dictionary to store reference icons
    var referenceIcons: [IconColor: UIImage] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCamera()
        loadReferenceIcons()
    }

    func loadReferenceIcons() {
        // Load reference images for each color
        for color in IconColor.allCases {
            if let icon = UIImage(named: "\(color.rawValue)Icon") {
                referenceIcons[color] = icon
            } else {
                showAlert(message: "Failed to load \(color.rawValue) icon template")
            }
        }
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
    
    func loadReferenceImages() {
        // Load the green and red icons from asset catalog
        if let green = UIImage(named: "greenIcon") {
            greenIcon = green
        } else {
            showAlert(message: "Failed to load green icon template")
        }
        
        if let red = UIImage(named: "redIcon") {
            redIcon = red
        } else {
            showAlert(message: "Failed to load red icon template")
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
        
        processCapturedImage(capturedImage)
    }
    
    let iconDetector = IconDetector()
    
    func processCapturedImage(_ image: UIImage) {
        let detectedIcons = iconDetector.detectIcons(in: image)
        
        // Display results or further process each detected icon
        for detectedIcon in detectedIcons {
            print("Detected \(detectedIcon.color.rawValue) icon at \(detectedIcon.rect)")
        }
    }
    
    func updateResultsLabel(with detections: [IconColor: Int]) {
        var resultText = "Found: "
        
        let descriptions = detections.map { (color, count) -> String? in
            guard count > 0 else { return nil }
            return "\(count) \(color.rawValue)"
        }.compactMap { $0 }  // Apply compactMap after map to filter out nil values
        
        resultText += descriptions.isEmpty ? "No matches" : descriptions.joined(separator: ", ")
        resultsLabel.text = resultText
    }
    
    func rgbToHsv(r: UInt8, g: UInt8, b: UInt8) -> (h: CGFloat, s: CGFloat, v: CGFloat) {
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        
        let maxValue = max(red, max(green, blue))
        let minValue = min(red, min(green, blue))
        let delta = maxValue - minValue
        
        var hue: CGFloat = 0
        
        if delta != 0 {
            if maxValue == red {
                hue = (green - blue) / delta + (green < blue ? 6 : 0)
            } else if maxValue == green {
                hue = (blue - red) / delta + 2
            } else {
                hue = (red - green) / delta + 4
            }
            hue /= 6
        }
        
        let saturation = maxValue == 0 ? 0 : delta / maxValue
        
        return (hue, saturation, maxValue)
    }
    
    func updateResultsLabel(greenMatches: Int, redMatches: Int) {
        var resultText = "Found: "
        if greenMatches > 0 { resultText += "\(greenMatches) green icons " }
        if redMatches > 0 { resultText += "\(redMatches) red icons" }
        if greenMatches == 0 && redMatches == 0 { resultText += "No matches" }
        
        resultsLabel.text = resultText
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
