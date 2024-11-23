//
//  EditProfileView.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 14/11/24.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var user: ActiveUser?
    
    //Estados para input
    @State private var newEmail: String = ""
    
    // Estados para la alerta
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showingAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Editar Perfil")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                // Correo
                TextField("Nuevo Correo", text: $newEmail)
                    .padding()
                    .padding(.leading)
                    .background(Color.accent.opacity(0.2))
                    .cornerRadius(30)
                    .keyboardType(.emailAddress)
                
                Spacer()
                
                Button("Guardar") {
                    // Validación de datos
                    if newEmail.isEmpty {
                        alertTitle = "Datos incompletos"
                        alertMessage = "Por favor ingresa un correo electrónico."
                        showingAlert = true
                        return
                    } else if newEmail.isEmpty {
                        alertTitle = "Correo vacío"
                        alertMessage = "Por favor ingresa un correo electrónico."
                        showingAlert = true
                        return
                    }
                    
                    // Validar el formato del correo electrónico
                    if !isValidEmail(newEmail) {
                        alertTitle = "Correo inválido"
                        alertMessage = "Por favor ingresa un correo electrónico válido."
                        showingAlert = true
                        return
                    }
                    
                    // Actualizar el `user` con los nuevos valores
                    let newUser = ActiveUser(userId: user?.userId ?? UUID(), correo: newEmail)
                    UserManage.saveActiveUser(newUser)
                    user = newUser
                    
                    dismiss() // Cierra la vista
                }
                .padding()
                .background(Color.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            
        }
        .onAppear{
            newEmail = user?.correo ?? ""
            
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
        }
        .environment(\.colorScheme, .light)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        // Expresión regular para validar el formato de un correo electrónico
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        
        // Usamos NSPredicate para verificar si el correo coincide con la expresión regular
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
}

#Preview {
    EditProfileView(user: .constant(ActiveUser(userId: UUID(), correo: "rocco@lpz.com")))
}
