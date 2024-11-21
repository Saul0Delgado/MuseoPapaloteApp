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
    func updateUIViewController(_ uiViewController: CameraViewControllerTM, context: Context) {
        //No update necessary
    }

    func makeUIViewController(context: Context) -> CameraViewControllerTM {
        return CameraViewControllerTM()
    }
}