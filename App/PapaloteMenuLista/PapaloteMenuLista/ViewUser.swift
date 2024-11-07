//
//  ViewUser.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 05/11/24.
//

import SwiftUI

struct ViewUser: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var colorNavBar = NavBarColor.shared
    let leftPadding : CGFloat = 25
    let wholeScreen = UIScreen.main.bounds.width
    
    @State private var showEditSheet = false
    
    //@State var user: ActiveUser? = UserManage.loadActiveUser()
    @State var user : ActiveUser? = ActiveUser(userId: 10, nombre: "Rocco", correo: "rocco_lpz@hotmail.com", edad: 30) // Para test
    
    var body: some View {
        if let userActive = user{
            ZStack{
                Color.white
                
                VStack{
                    
                    //Título tu perfil
                    HStack {
                        Text("Tu Perfil:")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.leading, leftPadding)
                        Spacer()
                    }
                    
                    //Datos Perfil
                    VStack(spacing:0){
                        
                        //Nombre
                        HStack{
                            Image(systemName: "person")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                                .foregroundStyle(.white)
                                .padding()
                                .padding(.leading)
                            Text(userActive.nombre)
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width:220, alignment: .leading)
                                .padding([.top, .bottom],8)
                            Spacer()
                        }
                        .frame(width: wholeScreen-leftPadding*2)
                        
                        Divider()
                            .frame(width:wholeScreen-leftPadding*2)
                        
                        //Correo
                        HStack{
                            Image(systemName: "envelope")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                                .foregroundStyle(.white)
                                .padding()
                                .padding(.leading)
                            Text(userActive.correo)
                                .frame(width:220, alignment: .leading)
                                .font(.title3)
                                .tint(.white)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .frame(width: wholeScreen-leftPadding*2)
                        
                        Divider()
                            .frame(width:wholeScreen-leftPadding*2)
                        
                        //Edad
                        HStack{
                            Text("Edad: \(userActive.edad)")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .padding([.top, .bottom], 14)
                        }
                        .frame(width: wholeScreen-leftPadding*2)
                        
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.accent)
                    )
                    
                    //Botón editar
                    HStack {
                        Button("Editar") {
                            showEditSheet = true
                        }
                        .padding()
                        .background(Color.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.top,50)
                        
                        Spacer()
                        
                        //Botón editar
                        Button("Cerrar Sesión") {
                            UserManage.deleteActiveUser()
                            
                            //TODO: Llevar a la pantalla de inicio
                        }
                        .padding()
                        .background(Color.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.top,50)
                    }
                    .frame(width: 250)
                    
                    
                    
                }
                .padding(.bottom,100)
            }
            .offset(y:-8)
            //Top Bar
            .safeAreaInset(edge: .top) {
                PapaloteTopBar(color:Color(Color.accent), type: .back)
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
            .sheet(isPresented: $showEditSheet) {
                EditProfileView(user: $user)
            }
            .environment(\.colorScheme, .light)
        }
        else{
            Text("Nada !!")
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var user: ActiveUser?
    
    @State private var newName: String = ""
    @State private var newEmail: String = ""
    @State private var newAge: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Editar Perfil")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                // Nombre
                TextField("Nuevo Nombre", text: $newName)
                    .padding()
                    .padding(.leading)
                    .background(Color.accent.opacity(0.2))
                    .cornerRadius(30)
                
                // Correo
                TextField("Nuevo Correo", text: $newEmail)
                    .padding()
                    .padding(.leading)
                    .background(Color.accent.opacity(0.2))
                    .cornerRadius(30)
                    .keyboardType(.emailAddress)
                
                // Edad
                TextField("Nueva Edad", text: $newAge)
                    .padding()
                    .padding(.leading)
                    .background(Color.accent.opacity(0.2))
                    .cornerRadius(30)
                    .keyboardType(.numberPad)
                
                Spacer()
                
                Button("Guardar") {
                    // Actualizar el `user` con los nuevos valores
                    let newUser = ActiveUser(userId: user?.userId ?? -1, nombre: newName, correo: newEmail, edad: Int(newAge) ?? 0)
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
            newName = user?.nombre ?? ""
            newEmail = user?.correo ?? ""
            newAge = String(user?.edad ?? 0)
            
        }
        .environment(\.colorScheme, .light)
    }
}


#Preview {
    ViewUser()
}
