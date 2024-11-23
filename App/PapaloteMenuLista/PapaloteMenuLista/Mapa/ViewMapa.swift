//
//  ViewMapa.swift
//  PapaloteMenuLista

import SwiftUI
import InteractiveMap

struct ViewMapa: View {
    @State private var selectedPath = PathData()
    @State private var pisoActual = "Piso1"
    @State private var mapID = UUID()
    
    @State private var showDetailView = false
    @State private var selectedZona: Seccion?
    @Environment(\.dismiss) var dismiss
    @ObservedObject var colorNavBar = NavBarColor.shared
    @ObservedObject var museoInfo = MuseoInfo.shared
    
    let topBarType : TopBarType
    
    var body: some View {
        ZStack{
            Color.white
                .ignoresSafeArea()
                VStack {
                    Picker ("Selecciona un piso", selection: $pisoActual) {
                        Text("Piso 1").tag("Piso1")
                        Text("Piso 2").tag("Piso2")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: pisoActual) {
                        mapID = UUID()
                        selectedPath = PathData()
                    }
                    InteractiveMap(svgName: pisoActual) { pathData in
                        if pathData.id != "Fondo" {
                            InteractiveShape(pathData)
                                .fill(getColor(for: pathData.id))
                                .onTapGesture {
                                    
                                    if let zona = museoInfo.secciones.first(where: { $0.nombre == pathData.id }) {
                                        selectedZona = zona
                                        showDetailView = true
                                    }
                                }
                        }
                    }
                    .id(mapID)
                    .padding()
                }
                .sheet(isPresented: $showDetailView) {
                    if let zona = selectedZona {
                        ViewZonaDetail(zona: zona)
                            .presentationDetents([.fraction(0.75)])
                            .presentationCornerRadius(30)
                            .presentationDragIndicator(.visible)
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
            Task {
                await museoInfo.fetch(isLoading: .constant(false))
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
    
    
    // Obtener el color de la zona según el ID desde la "base de datos"
    func getColor(for id: String) -> Color {
        if let zona = museoInfo.secciones.first(where: { $0.nombre == id })  {
            return Color(zona.color)
        }
        return .gray
    }
}

#Preview {
    ViewMapa(topBarType : .general)
}


/*
let zonas: [ZonaMapa] = [
    // Piso 1
    ZonaMapa(id: "PequeñosBosque", nombre: "Pequeños Bosque", color: "#55cdd0", numeroDeExhibiciones: 5),
    ZonaMapa(id: "ExpoTemp", nombre: "Expo Temporal", color: "#cce9c6", numeroDeExhibiciones: 2),
    ZonaMapa(id: "PasilloDinos", nombre: "Pasillo Dinosaurios", color: "#777568", numeroDeExhibiciones: 4),
    ZonaMapa(id: "Comunico", nombre: "Comunico", color: "#286ebb", numeroDeExhibiciones: 3),
    ZonaMapa(id: "Pertenezco", nombre: "Pertenezco", color: "#8eca48", numeroDeExhibiciones: 1),
    
    // Piso 2
    ZonaMapa(id: "Comprendo", nombre: "Comprendo", color: "#7946a4", numeroDeExhibiciones: 3),
    ZonaMapa(id: "Dinosaurios", nombre: "Dinosaurios", color: "#ffda9b", numeroDeExhibiciones: 6),
    ZonaMapa(id: "Soy", nombre: "Soy", color: "#ff311b", numeroDeExhibiciones: 2),
    ZonaMapa(id: "PequeñosAgua", nombre: "Pequeños Agua", color: "#55cdd0", numeroDeExhibiciones: 5),
    ZonaMapa(id: "Expreso", nombre: "Expreso", color: "#ff7923", numeroDeExhibiciones: 4)
]
*/
