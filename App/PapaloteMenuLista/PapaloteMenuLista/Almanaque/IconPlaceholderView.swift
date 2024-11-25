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
    let height = 160.0
    let width = UIScreen.main.bounds.width - 50
    
    var body: some View {
        ZStack {
            // Frame
            RoundedRectangle(cornerRadius: 1)
                .stroke(isUnlocked ? Color.gray : Color.white, lineWidth: 0)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                )
                //.shadow(radius: 5)
                .frame(width: 140, height: 110)

            // Content
            if isUnlocked, let image = unlockedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(height: height*0.6)
            } else {
                Image(uiImage: placeholderIcon)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .opacity(0.5) // Dim the placeholder icon
                    .frame(height: height*0.6)
                    .shadow( radius: 5, x: 7, y: 7)
            }
        }
        .frame(width: 100, height: height*0.6) // Adjust size as needed
    }
}

#Preview {
    IconPlaceholderView(isUnlocked: false, placeholderIcon: UIImage(imageLiteralResourceName: "Icono_Viento"))
}

