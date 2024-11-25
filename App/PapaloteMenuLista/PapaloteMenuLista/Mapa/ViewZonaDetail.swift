import SwiftUI

struct ViewZonaDetail: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var navigateToExhibicion : Bool
    @Binding var exhibiciontoNavigate : Exhibicion
    
    let zona: Seccion  // Zona seleccionada desde el mapa
    let leftPadding: CGFloat = 25
    let wholeScreen: CGFloat = UIScreen.main.bounds.width
    @State private var selectedIndex = 0
    @State private var showingCallout = true
    
    @ObservedObject var colorNavBar = NavBarColor.shared
    
    var body: some View {
        ZStack {
            ZStack {
                Color(zona.color)
                    .ignoresSafeArea()
                VStack {
                    Text(zona.nombre)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.top,30)
                        .padding(.bottom,10)
                    Spacer()
                    
                    Text("\(selectedIndex+1) / \(zona.exhibiciones.count)")
                        .foregroundStyle(Color(zona.color))
                        .fontWeight(.bold)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 40)
                        .background{
                            Color.white
                        }
                        .cornerRadius(5)
                    
                    //Navegación entre exhibiciones
                    HStack(spacing: 8) {
                        // Flecha izquierda
                        Button(action: {
                            withAnimation {
                                selectedIndex = max(selectedIndex - 1, 0)
                            }
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .opacity(selectedIndex > 0 ? 1.0 : 0.3)
                        }
                        // Contenido principal (modelo, imagen o placeholder)
                        contentForExhibicion(zona.exhibiciones[selectedIndex])
                            .frame(width: 250, height: 150)
                            .cornerRadius(12)
                        
                        // Flecha derecha
                        Button(action: {
                            withAnimation {
                                selectedIndex = min(selectedIndex + 1, zona.exhibiciones.count - 1)
                            }
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .opacity(selectedIndex < zona.exhibiciones.count - 1 ? 1.0 : 0.3)
                        }
                    }
                    
                    Text("Navega la zona con los botones")
                        .font(.callout)
                        .foregroundColor(.white)
                        .opacity(showingCallout ? 1 : 0.5) // Cambiar la visibilidad
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever(autoreverses: true),
                            value: showingCallout
                        )
                        .onAppear {
                            showingCallout.toggle()
                        }
                    
                    Spacer()
                    
                    //Informacion de la exhibicion
                    if let exhibicion = zona.exhibiciones[safe: selectedIndex] {
                        HStack {
                            Text(exhibicion.nombre)
                                .frame(height:40)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            if exhibicion.especial {
                                HStack(spacing:0) {
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height:12)
                                        .padding(.trailing,5)
                                        .offset(y:-0.5)
                                    Text("TEMPORAL")
                                }
                                .font(.footnote)
                                .foregroundStyle(Color(zona.color))
                                .fontWeight(.bold)
                                .frame(height:20)
                                .padding(.horizontal,8)
                                .background{
                                    Color.white
                                        .cornerRadius(5)
                                }
                                .offset(y:2)
                            }
                            Spacer()
                        }
                        .padding(.top, 25)
                        .padding(.leading, leftPadding)
                        
                        HStack {
                            Text(exhibicion.desc)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.leading, leftPadding)
                        .padding(.bottom, 16)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .scaledToFit()
                                .frame(height:30)
                            Spacer()
                                .frame(width:20)
                            Text("Ver en la Guia")
                                .fontWeight(.bold)
                                .font(.title2)
                            
                        }
                        .foregroundStyle(Color(zona.color))
                        .padding(.vertical, 30)
                        .frame(width:wholeScreen-leftPadding*2)
                        .background{
                            Color.white
                        }
                        .cornerRadius(20)
                        .onTapGesture {
                            print("Viajando a alguna exhibicion")
                            exhibiciontoNavigate = exhibicion
                            navigateToExhibicion = true
                            dismiss()
                        }

                        
                    }
                    
                    Color.clear
                        .frame(height:10)
                }
                
                
            }
        }
        .onDisappear{
            if navigateToExhibicion != true {
                colorNavBar.color = .accent
            }
        }
    }
    @ViewBuilder
    private func contentForExhibicion(_ exhibicion: Exhibicion) -> some View {
        if let modelName = exhibicion.model_file {
            SceneModelView(modelName: modelName, color: Color(hexValue: zona.color))
        } else if let imageName = exhibicion.image_name, let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 250, height: 150)
                .background(Color.white)
                .cornerRadius(15)
                .border(.white, width: 5)
                .cornerRadius(5)
              
        } else {
            Image("image_placeholder")
                .resizable()
                .scaledToFill()
                .frame(width: 250, height: 150)
                .background(Color.white)
                .cornerRadius(15)
                .border(.white, width: 5)
                .cornerRadius(5)
      
        }
    }
}

// Extensión para obtener elementos seguros de un array
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
    


#Preview {
    let mockExhibiciones = [
        Exhibicion(
            id: 1,
            nombre: "Exhibición 1",
            desc: "Descripción de la exhibición 1.",
            especial: false,
            featured: true,
            objetivos: [],
            preguntas: [],
            datosCuriosos: [],
            interaccion: [],
            image_name: nil,
            model_file: "monkey"
        ),
        Exhibicion(
            id: 2,
            nombre: "Exhibición 2",
            desc: "Descripción de la exhibición 2.",
            especial: true,
            featured: false,
            objetivos: [],
            preguntas: [],
            datosCuriosos: [],
            interaccion: [],
            image_name: "image_placeholder",
            model_file: nil
        )
    ]
    
    let mockZona = Seccion(
        id: 1,
        nombre: "Zona Demo",
        color: "color_soy", // Hex del color
        image_url: nil,
        desc: "Descripción de la zona demo.",
        exhibiciones: mockExhibiciones,
        objetivos: []
    )
    
    ZStack {
        Text("hola")
        .sheet(isPresented: .constant(true)) {
            ViewZonaDetail(navigateToExhibicion: .constant(false), exhibiciontoNavigate: .constant(mockZona.exhibiciones[0]), zona: mockZona)
                       .presentationDetents([.fraction(0.75)])
                       .presentationCornerRadius(30)
                       .presentationDragIndicator(.visible) 
               }
       }
   }
