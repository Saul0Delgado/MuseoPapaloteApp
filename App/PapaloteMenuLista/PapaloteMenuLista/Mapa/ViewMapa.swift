//
//  ViewMapa.swift
//  PapaloteMenuLista

import SwiftUI

struct ViewMapa: View {
    @State private var pisoActual = "Piso1"
    @State private var mapID = UUID()
    
    @State private var showDetailView = false
    @State private var selectedZona: Seccion?
    @Environment(\.dismiss) var dismiss
    @ObservedObject var colorNavBar = NavBarColor.shared
    @ObservedObject var museoInfo = MuseoInfo.shared
    
    @State var navigateToExhibicion = false
    @State var exhibicionToNavigate = Exhibicion(id: 1, nombre: "Error!", desc: "Error!", especial: false, featured: false, objetivos: [], preguntas: [], datosCuriosos: [], interaccion: [])
    
    
    let topBarType : TopBarType
    
    var body: some View {
        NavigationStack {
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
                    }
                    MapaSceneView(
                        svgName: pisoActual,
                        zonas: zonasInfo,
                        colorPorDefecto: { UIColor(getColor(for: $0)) },
                        onSelectZona: { id in
                            if let zona = museoInfo.secciones.first(where: { $0.nombre == id }) {
                                selectedZona = zona
                                showDetailView = true
                            }
                        }
                    )
                    .id(mapID)
                    
                    .padding()
                }
                .sheet(isPresented: $showDetailView) {
                    if let zona = selectedZona {
                        ViewZonaDetail(navigateToExhibicion: $navigateToExhibicion,exhibiciontoNavigate: $exhibicionToNavigate,zona: zona)
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
        .navigationDestination(isPresented: $navigateToExhibicion) {
            ViewExhibicion(exhibicion: exhibicionToNavigate, color: Color(selectedZona?.color ?? "color_soy"))
        }
    }
    
    
    // Color y modelos 3D de cada zona, indexados por nombre de seccion
    var zonasInfo: [String: MapaZonaInfo] {
        Dictionary(museoInfo.secciones.map { zona in
            (zona.nombre, MapaZonaInfo(color: UIColor(named: zona.color) ?? .gray,
                                       modelos: zona.exhibiciones.compactMap { $0.model_file }))
        }, uniquingKeysWith: { first, _ in first })
    }

    // Obtener el color de la zona según el ID desde la "base de datos"
    func getColor(for id: String) -> Color {
        if let zona = museoInfo.secciones.first(where: { $0.nombre == id })  {
            return Color(zona.color)
        }
        if id == "Arramberi" {
            return Color("color_Arramberi")
        }
        
        if id == "Criaturas Magnificas2" {
            return Color("color_criaturas")
        }
        return .gray
    }
}

#Preview {
    ViewMapa(topBarType : .general)
}

