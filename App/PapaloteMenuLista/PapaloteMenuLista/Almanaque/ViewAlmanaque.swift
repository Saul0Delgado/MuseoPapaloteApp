//
//  ViewAlmanaque.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 12/11/24.
//

import SwiftUI

struct ViewAlmanaque: View {
    @State var secciones : [Seccion] = MuseoInfo.shared.secciones
    @State var isLoading = true
    @State var hasAppeared = false
    @Environment(\.dismiss) var dismiss
    @ObservedObject var colorNavBar = NavBarColor.shared
    let topBarType : TopBarType
    
    
    var body: some View {
        VStack{
            if isLoading {
                //Loading
                VStack {
                    Spacer()
                    Text("Cargando")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.accent)
                        .padding(.bottom, 30)
                        .offset(y:-70)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .accent))
                        .scaleEffect(2.0, anchor: .center)
                        .offset(y:-70)
                    Spacer()
                }
            }
            else{
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
                            ForEach(secciones, id: \.id) { item in
                                NavigationLink(destination: ViewSeccion(seccion: item)) {
                                    ViewAlmanaqueSeccion(seccion: item)
                                }
                            }
                            Rectangle()
                                .fill(.clear)
                                .frame(height:120)
                        }
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
            if !hasAppeared{
                hasAppeared = true
                
                if secciones.count == 0{
                    // Secciones no ha cargado, fetch
                    print("Cargando Fetch por primera vez")
                    Task {
                        await MuseoInfo.shared.fetch(isLoading: $isLoading)
                        secciones = MuseoInfo.shared.secciones
                    }
                    
                }else{
                    print("Ya hay datos, no fetch")
                    isLoading = false
                }
                
            }
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

#Preview {
    ViewAlmanaque(topBarType: .general)
}
