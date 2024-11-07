//
//  ViewLogin.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 06/11/24.
//

import SwiftUI

struct ViewLogin: View {
    @State private var showAlert: Bool = false
    
    @State private var showLogin = true
    @State private var showRegister = false
    
    //Valores para ui
    let wholeScreen = UIScreen.main.bounds.width
    let leftPadding : CGFloat = 25
    
    var body: some View{
        ZStack{
            Background()
            
            //Login
            if showLogin {
                Login(showLogin: $showLogin, showRegister: $showRegister)
            }else{
                Register(showLogin: $showLogin, showRegister: $showRegister)
            }
            
            //Logos
            VStack{
                Spacer()
                Image("toco_juego_aprendo_blanco")
                    .resizable()
                    .scaledToFit()
                    .frame(width:220)
                    .padding(.bottom,10)
            }
        }
    }
}

struct Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    let mailPlaceholder = "rocco@ejemplo.com"
    
    //Valores para ui
    let wholeScreen = UIScreen.main.bounds.width
    let leftPadding : CGFloat = 25
    
    @Binding var showLogin : Bool
    @Binding var showRegister : Bool
    
    var body: some View {
        //Login
        ZStack {
            VStack{
                
                //Bienvenid@
                HStack {
                    Text("¡Bienvenid@!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.bottom,20)
                
                //Email input
                HStack {
                    Text("E-MAIL")
                        .font(.callout)
                        .foregroundStyle(.gray.opacity(0.7))
                    Spacer()
                }
                TextField(mailPlaceholder, text: $email)
                    .padding()
                    .background(Color.black.opacity(0.03))
                    .cornerRadius(18)
                    .foregroundColor(.black)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.bottom)
                
                // Campo de contraseña
                HStack {
                    Text("CONTRASEÑA")
                        .font(.callout)
                        .foregroundStyle(.gray.opacity(0.7))
                    Spacer()
                }
                SecureField("Ingresa tu Contraseña", text: $password)
                    .padding()
                    .background(Color.black.opacity(0.03))
                    .cornerRadius(18)
                    .foregroundColor(.black)
                
                Button("Iniciar Sesión"){
                    print("hola")
                }
                .padding()
                .frame(width:250)
                .background(Color.accent)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .cornerRadius(18)
                .padding(.top,20)
                .padding(.bottom,10)
                
                
                HStack{
                    Text("¿No tienes cuenta?")
                    Button("Regístrate"){
                        withAnimation(.easeOut(duration: 0.3)) {
                            if showLogin {
                                showLogin = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.easeIn(duration: 0.3)) {
                                        showRegister = true
                                    }
                                }
                            }
                            else {
                                showRegister = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.easeIn(duration: 0.3)) {
                                        showLogin = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(width:wholeScreen-leftPadding*2)
            .offset(y:-20)
            
            VStack{
                HStack {
                    Spacer()
                    Image("logo_verde")
                        .resizable()
                        .scaledToFit()
                        .frame(height:120)
                        .padding(.top)
                        .padding(.trailing, leftPadding+10)
                }
                Spacer()
            }
        }
    }
}

struct Register: View {
    @State private var nombre: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    let mailPlaceholder = "rocco@ejemplo.com"
    
    @Binding var showLogin : Bool
    @Binding var showRegister : Bool
    
    //Valores para ui
    let wholeScreen = UIScreen.main.bounds.width
    let leftPadding : CGFloat = 25
    
    var body: some View {
        //Login
        VStack{
            
            //Bienvenid@
            HStack {
                Text("Registrate")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.bottom,20)
            
            //Nombre input
            HStack {
                Text("NOMBRE")
                    .font(.callout)
                    .foregroundStyle(.gray.opacity(0.7))
                Spacer()
            }
            TextField("Ej. Rocco", text: $email)
                .padding()
                .background(Color.black.opacity(0.03))
                .cornerRadius(18)
                .foregroundColor(.black)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.bottom)
            
            //Email input
            HStack {
                Text("E-MAIL")
                    .font(.callout)
                    .foregroundStyle(.gray.opacity(0.7))
                Spacer()
            }
            TextField(mailPlaceholder, text: $email)
                .padding()
                .background(Color.black.opacity(0.03))
                .cornerRadius(18)
                .foregroundColor(.black)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.bottom)
            
            // Campo de contraseña
            HStack {
                Text("CONTRASEÑA")
                    .font(.callout)
                    .foregroundStyle(.gray.opacity(0.7))
                Spacer()
            }
            SecureField("Ingresa tu Contraseña", text: $password)
                .padding()
                .background(Color.black.opacity(0.03))
                .cornerRadius(18)
                .foregroundColor(.black)
                .padding(.bottom)
            
            // Confirmar contra
            HStack {
                Text("CONFIRMAR CONTRASEÑA")
                    .font(.callout)
                    .foregroundStyle(.gray.opacity(0.7))
                Spacer()
            }
            SecureField("Confirma tu Contraseña", text: $password)
                .padding()
                .background(Color.black.opacity(0.03))
                .cornerRadius(18)
                .foregroundColor(.black)
            
            Button("Registrate"){
                print("Hola")
            }
            .padding()
            .frame(width:250)
            .background(Color.accent)
            .foregroundColor(.white)
            .fontWeight(.bold)
            .cornerRadius(18)
            .padding(.top,20)
            .padding(.bottom,10)
        
            
            HStack{
                Text("¿Ya tienes cuenta?")
                Button("Inicia Sesión"){
                    withAnimation(.easeOut(duration: 0.3)) {
                        if showLogin {
                            showLogin = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    showRegister = true
                                }
                            }
                        }
                        else {
                            showRegister = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    showLogin = true
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(width:wholeScreen-leftPadding*2)
        .offset(y:-60)
    }
}

struct Background: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.accent
                
                // Azul
                Circle()
                    .fill(Color(red: 0, green: 150/256, blue: 167/256))
                    .frame(width: geometry.size.width * 3, height: geometry.size.width * 3)
                    .offset(x: -geometry.size.width, y: -490)
                
                //Blanco
                Circle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * 3.2, height: geometry.size.width * 3.2)
                    .offset(x: -geometry.size.width, y: -550)
                
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

struct nada: View {
    @State private var showLogin = true
    @State private var showRegister = false
    
    var body: some View {
        VStack {
            // Botón para alternar entre cuadrado y círculo
            Button(action: {
                withAnimation(.easeOut(duration: 0.15)) {
                    if showLogin {
                        showLogin = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.easeIn(duration: 0.15)) {
                                showRegister = true
                            }
                        }
                    }
                    else {
                        showRegister = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.easeIn(duration: 0.15)) {
                                showLogin = true
                            }
                        }
                    }
                }
            }) {
                Text("Cambiar entre cuadrado y círculo")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 100)
            
            Spacer()
            
            // Si showSquare es true, muestra el cuadrado
            if showLogin {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 200, height: 200)
                    .transition(.opacity)
            }
            
            // Si showCircle es true, muestra el círculo
            if showRegister {
                Circle()
                    .fill(Color.green)
                    .frame(width: 200, height: 200)
                    .transition(.opacity)
            }
            
            Spacer()
        }
        .padding()
    }
}



#Preview {
    ViewLogin()
}
