import SwiftUI
struct ViewIcono: View {
    //let nameToId: [String: Int]
    @Binding var selectedTab : Int
    @Environment(\.dismiss) var dismiss
    
    var iconName: String // Name of the detected icon
    var iconImage: UIImage // Image of the detected icon
    @State private var reloadKey = UUID()
    
    @Binding var isShowing: Bool // Binding to dismiss the sheet
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            if iconName == "No se encontró ningún ícono. Asegura de que el ícono esté claro y completo en la foto e intenta de nuevo."{
                Text(iconName)
                    .foregroundStyle(.black)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .frame(width:300)
            }
            else{
                VStack {
                    Text(iconName)
                        .foregroundStyle(.black)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    Image(uiImage: iconImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .padding()
                    
                    Button(action: {
                        
                        Task {
                            let user_id = UserManage.loadActiveUser()?.userId ?? UUID()
                            
                            print(user_id)
                            print(iconName)
                            
                            let secciones = MuseoInfo.shared.secciones
                            
                            if let exhibicionEspecies = secciones.flatMap({ $0.exhibiciones }).first(where: { $0.nombre == iconName }) {
                                print("Encontrado, id: \(exhibicionEspecies.id)")
                                await InsertRegistro(user_id: user_id, exhibicion_id: exhibicionEspecies.id)
                                selectedTab = 3
                                dismiss()
                            } else {
                                print("No se encontró una exhibición llamada \(iconName).")
                            }
                        }
                        
                    }) {
                        Text("Agregar al Almanaque")
                            .padding(.vertical, 10)
                            .padding(.horizontal, 50)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(15)
                    }
                }
                .padding()
                .onAppear{
                    print(iconName)
                }
            }
        }
    }
    
    func InsertRegistro(user_id: UUID, exhibicion_id: Int) async {
        let registro = RegistroAlmanaque(id_usuario: user_id, id_exhibicion: exhibicion_id)
        
        do {
            try await supabase
                .from("RegistrosAlmanaque")
                .insert(registro)
                .execute()
        }
        catch {
            print("Error al insertar registro en la base de datos: \(error)")
        }
    }
    
    struct RegistroAlmanaque: Encodable {
        let id_usuario: UUID
        let id_exhibicion: Int
    }
}

#Preview {
    ViewIcono(selectedTab: .constant(2), iconName: "Wind Icon", iconImage: UIImage(named: "Icono_Viento") ?? UIImage(), isShowing: .constant(true))
}
