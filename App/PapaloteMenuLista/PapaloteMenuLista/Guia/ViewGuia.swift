//
//  ListaMapa.swift
//  PapaloteMenuLista
//
//  Created by alumno on 15/10/24.
//

import SwiftUI

struct ViewGuia: View {
    @Environment(\.dismiss) var dismiss
	//let secciones : ListaSeccionesBORRAMENOSIRVO = ListaSeccionesBORRAMENOSIRVO()
    @State var isLoading : Bool = false
    @State var secciones : [Seccion] = MuseoInfo.shared.secciones
    let leftPadding : CGFloat = 25
    @State private var hasAppeared = false
    @ObservedObject var colorNavBar = NavBarColor.shared
	
	//let verdePapalote : UIColor = UIColor(red: 198/256, green: 212/256, blue: 68/256, alpha: 1)
    let verdePapalote = Color.accent
	
	var body: some View {
        if isLoading {
            //Loading
            ZStack {
                VStack{
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
            //Top Bar
            .safeAreaInset(edge: .top) {
                PapaloteTopBar(color:Color(verdePapalote), type: .textConBack, text: "Guía")
            }
        } else {
            NavigationStack {
                VStack {
                    ScrollView {
                        Text("Secciones")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.leading, leftPadding)
                            .padding(.top, 40.0)
                            .padding(.bottom, 0)
                            .frame(maxWidth: .infinity,alignment: .leading)
                        ForEach(secciones , id: \.id) { item in
                            NavigationLink(destination: ViewSeccion(seccion: item)) {
                                ViewZonaMenuItem(color: Color(item.color), title: item.nombre, img: Image(item.image_url ?? "image_placeholder"))
                            }
                        }
                        
                        Rectangle()
                            .frame(height:120)
                            .foregroundStyle(.clear)
                    }
                }
                //Top Bar
                .safeAreaInset(edge: .top) {
                    PapaloteTopBar(color:Color(verdePapalote), type: .textConBack, text: "Guía")
                }
                .gesture(DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if value.translation.width > 0 {
                            dismiss()
                        }
                    }
                )
                .navigationBarHidden(true)
            }
            .environment(\.colorScheme, .light)
            .onAppear{
                colorNavBar.color = .accent
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
                    }
                    
                }
            }
        }
	}
    
    
}


#Preview {
    ZStack {
        ViewGuia()

        VStack{
            Spacer()
            NavBar(selectedTab: .constant(4), color: Color.green, reload: .constant(false))
        }
    }
}
