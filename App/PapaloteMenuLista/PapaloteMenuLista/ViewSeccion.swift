//
//  ViewSeccion.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 09/10/24.
//

import SwiftUI

struct ViewSeccion: View {
    let seccion : Seccion
    
    var body: some View {
        VStack{
            ZStack {
                seccion.image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                Color.black
                    .opacity(0.3)
                    .frame(height:200)
                Text(seccion.nombre)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .font(.largeTitle)
            }
            Text(seccion.desc)
        }
    }
}

#Preview {
    ViewSeccion(seccion: ListaSecciones().secciones[0])
}
