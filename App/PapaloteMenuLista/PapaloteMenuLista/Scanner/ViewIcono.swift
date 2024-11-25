import SwiftUI
struct ViewIcono: View {
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
                ViewAlmanaque(topBarType: .general)
                    .id(reloadKey)
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
        //.background(
            //RoundedRectangle(cornerRadius: 20)
              //  .fill(Color(UIColor.systemBackground))
                //.shadow(radius: 10)
        //)
    }
}

#Preview {
    ViewIcono(iconName: "Wind Icon", iconImage: UIImage(named: "Icono_Viento") ?? UIImage(), isShowing: .constant(true))
}
