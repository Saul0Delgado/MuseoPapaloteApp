//
//  ViewExhibicionMenuItem.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 04/11/24.
//

import SwiftUI

struct ViewExhibicionMenuItem: View {
    let exhibicion : Exhibicion
    
    let leftPadding : CGFloat = 50
    let wholeScreen : CGFloat = UIScreen.main.bounds.width
    let elementHeight : CGFloat = 130
    
    var body: some View {
        ZStack {
            Image(exhibicion.image_name ?? "image_placeholder")
                .resizable()
                .scaledToFill()
                .frame(width: wholeScreen-leftPadding, height:elementHeight*1.5)
                .clipShape(
                    .rect(
                        topLeadingRadius: 30,
                        bottomLeadingRadius: 30,
                        bottomTrailingRadius: 30,
                        topTrailingRadius: 30
                    )
                )
                .clipped()
            
            Color.black
                .cornerRadius(30)
                .opacity(0.4)
            
            VStack {
                HStack {
                    Text(exhibicion.nombre)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding([.leading, .top], 20)
                    Spacer()
                }
                HStack {
                    Text(exhibicion.desc)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .frame(width:200)
                        .foregroundStyle(.white)
                        .padding(.leading, 20)
                        .padding(.top, 0)
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Image(systemName: "chevron.forward.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .foregroundStyle(.white)
                        .padding(.trailing,25)
                        .padding(.bottom, 25)
                }
            }
            
            if exhibicion.especial {
                VStack{
                    HStack{
                        Spacer()
                        Image("especial_tag")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                    Spacer()
                }
            }
            
        }
        .frame(width: wholeScreen-leftPadding, height:elementHeight*1.5)
    }
}

#Preview{
    ViewExhibicionMenuItem(exhibicion: Exhibicion(id: 1, nombre: "Hola", desc: "Si hola", especial: true, featured: false, objetivos: [""], preguntas: [""], datosCuriosos: [""], interaccion: [""]))
}
