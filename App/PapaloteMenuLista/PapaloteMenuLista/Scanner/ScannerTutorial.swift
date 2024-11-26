//
//  ScannerTutorial.swift
//  PapaloteMenuLista
//
//  Created by alumno on 14/11/24.
//

import SwiftUI

struct ScannerTutorial : View {
    @Binding var isShowing : Bool
    @State private var scale : CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack {
                Image("Icono_Tutorial")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.accent)
                    .frame(width:300)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                            scale = 1.1
                        }
                    }
                Spacer()
                    .frame(height:50)
                Text("¡Explora el museo para encontrar todos los íconos! \n \nEscanealos con la cámara para ir llenando tu álbum y revivir los mejores momentos del museo.")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .frame(width:300)
                    .foregroundStyle(.white)
                    .padding(.bottom,30)
                Button(action:{
                    UserDefaults.standard.set(true, forKey: "hasSeenScannerTutorial")
                    isShowing.toggle()
                }){
                    HStack{
                        Text("Comenzar")
                            .foregroundStyle(.white)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                            .frame(width:60)
                        Image(systemName: "chevron.forward")
                            .resizable()
                            .scaledToFit()
                            .frame(height:25)
                            .foregroundStyle(.white)
                    }
                    .frame(width: 220, height:80)
                    .padding(.horizontal,40)
                    .background{
                        Color.accent
                            .cornerRadius(20)
                    }
                }
            }
            .frame(height:500)
            .offset(y:50)
            
        }
    }
}

#Preview {
    ScannerTutorial(isShowing: .constant(true))
}
