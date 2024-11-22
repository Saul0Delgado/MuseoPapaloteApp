//
//  ViewLoading.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 21/11/24.
//

import SwiftUI

struct ViewLoading: View {
    @State var randomPhrase = ""
    @State private var rotation: Double = 0
    @State private var sunScale: CGFloat = 1.0
    
    var body: some View {
        //Loading
        ZStack{
            Color.accent
                .ignoresSafeArea()
            VStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2.0, anchor: .center)
                    .offset(y:-70)
                Text(randomPhrase)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: 300, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                    .offset(y:-70)
                Spacer()
            }
            .offset(y:0)
            
            Image("logo_blanco_centered")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 500)  // Ajusta el tamaño de la imagen según sea necesario
                        .rotationEffect(.degrees(rotation))
                        .onAppear {
                            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                                rotation = 360
                            }
                        }
                        .offset(x:150,y:400)
            
            Image(systemName: "atom")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350)
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(rotation))
                        .onAppear {
                            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                                rotation = 360
                            }
                        }
                        .offset(x:-150,y:-400)
        }
        .onAppear{
            randomPhrase = loadingPhrases.randomElement() ?? ""
        }
    }
    
    let loadingPhrases: [String] = [
        "La paciencia es el arte de esperar con una sonrisa.",
        "Cada segundo es una nueva oportunidad.",
        "Lo mejor está por venir.",
        "La magia ocurre cuando menos lo esperas.",
        "El éxito es el resultado de la perseverancia.",
        "Donde hay esfuerzo, hay progreso.",
        "Cualquier cosa que valga la pena lleva tiempo.",
        "El camino hacia la grandeza comienza con un solo paso.",
        "Lo único que nunca se detiene es el tiempo.",
        "Grandes cosas nunca se hacen en la zona de confort.",
        "Un pequeño avance hoy, un gran salto mañana.",
        "Los sueños no tienen fecha de vencimiento.",
        "Todo lo que necesitas está en camino.",
        "La clave es mantenerse en movimiento.",
        "No hay atajos para los lugares que valen la pena.",
        "Cada espera nos acerca a algo mejor.",
        "La perseverancia convierte lo imposible en posible.",
        "La paciencia es la fortaleza que nos permite ver los frutos del trabajo.",
        "Cada segundo cuenta cuando estás creando algo extraordinario.",
        "La calma es el primer paso hacia la grandeza."
    ]
}

#Preview {
    ViewLoading()
}
