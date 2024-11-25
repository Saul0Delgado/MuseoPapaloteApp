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
                        Text("Planta Alta").tag("Piso1")
                        Text("Planta Baja").tag("Piso2")
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
        if id == "Arramberi" {
            return Color("color_Arramberi") // Color específico de Arramberi
        }
        
        if id == "Criaturas Magnificas2" {
            return Color("color_criaturas") // Color específico de Arramberi
        }
        return .gray
    }
}

#Preview {
    ViewMapa(topBarType : .general)
}

