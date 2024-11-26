//
//  IconPlaceholderView.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 22/11/24.
//


import SwiftUI

struct IconPlaceholderView: View {
    var isUnlocked: Bool
    var unlockedImage: UIImage? // Image to display if unlocked
    var placeholderIcon: UIImage // Icon to display if locked
    let height = 150.0
    let width = UIScreen.main.bounds.width - 50
    
    @State private var showLargeImage = false // Controls the sheet
    
    var body: some View {
        ZStack {
            // Content
            if isUnlocked, let image = unlockedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(height: height)
                    .onTapGesture {
                        showLargeImage = true // Show the sheet on tap
                    }
            } else {
                Image(uiImage: placeholderIcon)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .opacity(0.7)
                    .frame(height: height)
                    .shadow(radius: 5, x: 7, y: 7)
                    .onTapGesture {
                        withAnimation{
                            showLargeImage = true // Show the sheet on tap
                        }
                    }
            }
            
        }
        .frame(width: 140, height: height)
        .padding(10)
        //.sheet(isPresented: $showLargeImage) {
        //    EnlargedImageView(image: isUnlocked ? unlockedImage ?? placeholderIcon : placeholderIcon)
        if showLargeImage {
            EnlargedImageOverlay(image: placeholderIcon, isShowing: $showLargeImage)
        }
    }
}

#Preview {
    IconPlaceholderView(isUnlocked: false, placeholderIcon: UIImage(imageLiteralResourceName: "img_Viento"))
}
