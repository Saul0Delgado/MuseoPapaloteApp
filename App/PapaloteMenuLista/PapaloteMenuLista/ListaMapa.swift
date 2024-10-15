//
//  ListaMapa.swift
//  PapaloteMenuLista
//
//  Created by alumno on 15/10/24.
//

import SwiftUI

struct ListaMapa: View {
    let secciones : ListaSecciones = ListaSecciones()
    
    let verdePapalote : UIColor = UIColor(red: 198/256, green: 212/256, blue: 68/256, alpha: 1)
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Text("Secciones")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading, 20)
                        .padding(.top, 40.0)
                        .padding(.bottom, 0)
                        .frame(maxWidth: .infinity,alignment: .leading)
                    ForEach(secciones.secciones, id: \.nombre) { item in
                        NavigationLink(destination: ViewSeccion(seccion: item)) {
                            ViewSeleccionListaMapa(color: item.color, title: item.nombre, img: item.image)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                            VStack {
                                HStack() {
                                    Spacer()
                                    Text("Mapa")
                                        .font(.largeTitle.weight(.bold))
                                        .foregroundStyle(.white)
                                    Spacer()
                                }
                            }
                            .frame(height: 70)
                            .background(Color(verdePapalote))
                        }
                        .navigationBarHidden(true)
        }
    }
}


#Preview {
    ListaMapa()
}
