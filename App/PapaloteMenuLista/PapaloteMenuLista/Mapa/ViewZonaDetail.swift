import SwiftUI

struct ViewZonaDetail: View {
    let zona: SeccionStatic  // Zona seleccionada desde el mapa
    let leftPadding: CGFloat = 25
    let wholeScreen: CGFloat = UIScreen.main.bounds.width
    @State private var selectedIndex = 0  // Índice del modelo actual
    
    @State private var showingCallout = true
    
    var body: some View {
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
                    .foregroundStyle(zona.color)
                    .fontWeight(.bold)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 40)
                    .background{
                        Color.white
                    }
                    .cornerRadius(5)
                
                //Monkey
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
                    
                    // Modelo 3D en el centro
                    SceneModelView(
                        modelName: "monkey",
                        color: Color.red
                    )
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
                
                HStack {
                    Text("Gusanos")
                        .frame(height:40)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    if true {
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
                        .foregroundStyle(zona.color)
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
                    Text("Esta es la descripción de la exhibicion en cuestion hola si que tal")
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.leading, leftPadding)
                .padding(.bottom, 16)
                
                Button(action: {
                                    
                }) {
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
                    .foregroundStyle(zona.color)
                    .padding(.vertical, 30)
                    .frame(width:wholeScreen-leftPadding*2)
                    .background{
                        Color.white
                    }
                    .cornerRadius(20)
                }
                
                Color.clear
                    .frame(height:10)
            }
            

        }
    }
    
}


#Preview {
    ZStack {
        Text("Hola")
            .sheet(isPresented: .constant(true)) {
                ViewZonaDetail(zona: ListaSeccionesBORRAMENOSIRVO().secciones[0])
                    .presentationDetents([.fraction(0.75)])
                    .presentationCornerRadius(30)
                    .presentationDragIndicator(.visible)
            }
        
        
    }
}
