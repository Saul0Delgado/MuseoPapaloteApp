//
//  ViewAlmanaque.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 12/11/24.
//

import SwiftUI

struct ViewAlmanaque: View {
    let secciones : ListaSecciones = ListaSecciones()
    @Environment(\.dismiss) var dismiss
    @ObservedObject var colorNavBar = NavBarColor.shared
    let topBarType : TopBarType
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                ScrollView {
                    Text("Zonas")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading, 25)
                        .padding(.top, 40.0)
                        .padding(.bottom, 0)
                        .frame(maxWidth: .infinity,alignment: .leading)
                    ForEach(secciones.secciones, id: \.nombre) { item in
                        NavigationLink(destination: ViewSeccion(seccion: item)) {
                            ViewAlmanaqueSeccion(color: item.color, title: item.nombre, img: item.image, cantidad: item.exhibiciones.count+5)
                        }
                    }
                }
            }
            //Top Bar
            .safeAreaInset(edge: .top) {
                PapaloteTopBar(color:Color(Color.accent), type: topBarType)
            }
            //Set navbar color
            .onAppear{
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
        }
    }
}

#Preview {
    ViewAlmanaque(topBarType: .general)
}
