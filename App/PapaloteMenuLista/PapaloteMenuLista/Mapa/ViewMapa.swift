//
//  ViewMapa.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 12/11/24.
//

import SwiftUI

struct ViewMapa: View{
    let topBarType : TopBarType
    
    var body: some View {
        Text("Mapa")
    }
}

/*
import SwiftUI
import InteractiveMap

struct ViewMapa: View {
    @State private var selectedPath = PathData()
    @State private var pisoActual = "Piso1"
    @State private var mapID = UUID()
    
    @State private var showDetailView = false
    @State private var selectedZona: Zona?
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var colorNavBar = NavBarColor.shared
    let secciones : [SeccionStatic] = ListaSeccionesBORRAMENOSIRVO().secciones
    
    let topBarType : TopBarType
    
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
    
    var body: some View {
        ZStack{
            Color.white
                .ignoresSafeArea()
            NavigationView {
                VStack {
                    
                    Picker("Selecciona un piso", selection: $pisoActual) {
                        Text("Piso 1").tag("Piso1")
                        Text("Piso 2").tag("Piso2")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: pisoActual) {
                        // Actualizamos el mapa y limpiamos la selección sin parámetros
                        mapID = UUID()
                        selectedPath = PathData()
                    }
                    
                    // Mapa interactivo para el piso seleccionado
                    InteractiveMap(svgName: pisoActual) { pathData in
                        if pathData.id != "Fondo" {
                            InteractiveShape(pathData)
                                .fill(getColor(for: pathData.id))
                                .onTapGesture {
                                    
                                    if let zona = secciones.first(where: { $0.id == pathData.id }) {
                                        selectedZona = zona
                                        showDetailView = true
                                        
                                        //navigateToDetailView(for: pathData)
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
    
    // Obtener el color de la zona según el ID desde la "base de datos"
    func getColor(for id: String) -> Color {
        guard let zona = zonas.first(where: { $0.id == id }) else {
            return .gray // Color por defecto si no se encuentra la zona
        }
        return Color(hexValue: zona.color)
    }
}

struct ZonaMapa: Identifiable, Hashable {
    let id: String
    let nombre: String
    let color: String
    let numeroDeExhibiciones: Int
}

#Preview {
    ViewMapa(topBarType : .general)
}

*/
