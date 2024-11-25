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
        VStack {
            Text(iconName)
                .font(.headline)
                .padding()
            
            Image(uiImage: iconImage)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .padding()
            
            Button(action: {
                
                Task {
                    let user_id = UserManage.loadActiveUser()?.userId ?? UUID()
                    
                    //let exh_id = nameToId[iconName]
                    
//                    await InsertRegistro(user_id: UUID, exhibicion_id: Int)
                    
                    selectedTab = 3
                    dismiss()
                }
                
            }) {
                Text("Ver en Álbum")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onAppear{
            let sec = MuseoInfo.shared.secciones
//            nameToId: [String: Int] = sec.flatMap { $0.exhibiciones }.reduce(into: [String: Int]()) { dict, icon in
//                    dict[icon.nombre] = icon.id
//            }
        }
    }
    
    func InsertRegistro(user_id: UUID, exhibicion_id: Int) async {
        
    }
}

#Preview {
    ViewIcono(selectedTab: .constant(2), iconName: "Wind Icon", iconImage: UIImage(named: "Icono_Viento") ?? UIImage(), isShowing: .constant(true))
}
