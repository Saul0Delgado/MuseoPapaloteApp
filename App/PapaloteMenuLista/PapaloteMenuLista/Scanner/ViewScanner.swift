//
//  ViewScanner.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 12/11/24.
//

import SwiftUI

struct ViewScanner: View {
    @Binding var selectedTab : Int
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var colorNavBar = NavBarColor.shared
    @State var firstLaunch: Bool = false
    @ObservedObject var albumViewModel = IconAlbumViewModel()
    @State private var showIconSheet = false
    @State private var detectedIconName: String = ""
    @State private var detectedIconImage: UIImage? = nil

    
    var body: some View {
        VStack {
            if firstLaunch {
                ZStack {
                    CameraViewControllerRepresentable(
                        albumViewModel: albumViewModel,
                        onIconDetected: handleIconDetection
                    )
                    .blur(radius: 10)
                    
                    ScannerTutorial(isShowing: $firstLaunch)
                        .transition(.opacity)
                }
            } else {
                CameraViewControllerRepresentable(
                    albumViewModel: albumViewModel,
                    onIconDetected: handleIconDetection
                )
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: firstLaunch)
        //Set navbar color
        .onAppear{
            firstLaunch = isFirstLaunch()
            colorNavBar.color = Color.accent
        }
        //Slide para ir atras
        .gesture(DragGesture(minimumDistance: 30)
            .onEnded { value in
                if value.translation.width > 0 {
                    dismiss()
                }
            }
        )
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showIconSheet) {
            if let iconImage = detectedIconImage {
                ViewIcono(
                    selectedTab: $selectedTab,
                    iconName: detectedIconName,
                    iconImage: iconImage,
                    isShowing: $showIconSheet
                )
                .presentationDetents([.medium]) // Customize to cover half the screen
                .presentationDragIndicator(.visible) // Optional: Add drag indicator
            }
        }
    }
    
    func handleIconDetection(iconName: String, iconImage: UIImage) {
        // Update the detected icon and show the sheet
        detectedIconName = iconName
        detectedIconImage = iconImage
        showIconSheet = true
    }
    
    func isFirstLaunch() -> Bool {
        let hasSeenTutorial = UserDefaults.standard.bool(forKey: "hasSeenScannerTutorial")
        return !hasSeenTutorial
    }
}

#Preview {
    ViewScanner(selectedTab: .constant(2))
}
