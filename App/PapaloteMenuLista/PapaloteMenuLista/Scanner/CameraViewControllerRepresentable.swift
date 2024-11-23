//
//  CameraViewControllerRepresentable.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 21/11/24.
//


//
//  CameraViewControllerRepresentable.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 21/11/24.
//


//
//  CameraViewControllerRepresentable.swift
//  VisionTest
//
//  Created by Alumno on 11/11/24.
//
import Foundation
import SwiftUI
struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    var albumViewModel: IconAlbumViewModel // Pass the album ViewModel
    var onIconDetected: (String, UIImage) -> Void // Callback for detected icon

    func makeUIViewController(context: Context) -> CameraViewControllerTM {
        let controller = CameraViewControllerTM()
        controller.albumViewModel = albumViewModel // Pass ViewModel to controller
        controller.onIconDetected = onIconDetected // Pass callback to controller
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewControllerTM, context: Context) {
        // No update necessary
    }
}

