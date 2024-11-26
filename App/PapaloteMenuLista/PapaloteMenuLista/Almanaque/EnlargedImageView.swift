//
//  EnlargedImageView.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 25/11/24.
//


import SwiftUI

struct EnlargedImageOverlay: View {
    var image: UIImage
    @Binding var isShowing: Bool // Controls whether the modal is visible

    var body: some View {
        ZStack {
            // Semi-transparent background

            // Centered image container
            VStack {
                Spacer() // Add spacing above the image
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8, maxHeight: UIScreen.main.bounds.height * 0.5)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .onTapGesture {
                        withAnimation{
                            isShowing = false // Dismiss when tapping outside
                        }
                    }
                Spacer() // Add spacing below the image
            }
        }
        .animation(.easeInOut, value: isShowing) // Smooth show/hide animation
        .transition(.opacity) // Fade in/out effect
        .zIndex(1) // Ensure it's on top of other content
    }
}


#Preview {
    EnlargedImageOverlay(image: UIImage(named: "Icono_Viento") ?? UIImage(), isShowing: .constant(false))
}
