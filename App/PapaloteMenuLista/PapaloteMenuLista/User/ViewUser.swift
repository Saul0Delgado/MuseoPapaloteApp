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
    
    @Binding var isLoggedIn : Bool
    let leftPadding : CGFloat = 25
    let wholeScreen = UIScreen.main.bounds.width
    
    @State private var showEditSheet = false
    
    @State var user: ActiveUser? = UserManage.loadActiveUser()
    //@State var user : ActiveUser? = ActiveUser(userId: 10, nombre: "Rocco", correo: "rocco_lpz@hotmail.com") // Para test
    
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
                                .padding([.top, .bottom],8)
                            Spacer()
                        }
                        .frame(width: wholeScreen-leftPadding*2)
                        

                        
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.accent)
                    )
                    
                    /*
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
                            
                            isLoggedIn = false
                        }
                        .padding()
                        .background(Color.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.top,50)
                    }
                    .frame(width: 250)
                    */
                    
                    //Botón editar
                    Button("Cerrar Sesión") {
                        UserManage.deleteActiveUser()
                        
                        isLoggedIn = false
                    }
                    .padding()
                    .background(Color.accent)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.top,50)
                    
                    
                }
                .padding(.bottom,100)
            }
            .offset(y:-8)
            //Top Bar
            .safeAreaInset(edge: .top) {
                PapaloteTopBar(color:Color(Color.accent), type: .general)
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




#Preview {
    ViewUser(isLoggedIn: .constant(true))
}
