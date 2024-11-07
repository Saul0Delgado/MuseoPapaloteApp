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
    
    //Para alerta
    @State var showingAlert : Bool = false
    @State var AlertTitle : String = ""
    @State var AlertMessage : String = ""
    
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
                    if email.isEmpty{
                        //No hay email, enviar error email empty
                        AlertTitle = "Correo Faltante"
                        AlertMessage = "Ingrese su correo electrónico, por favor."
                        showingAlert = true
                    }
                    else if password.isEmpty {
                        //No hay contraseña, enviar error contraseña empty
                        AlertTitle = "Contraseña Faltante"
                        AlertMessage = "Ingrese su contraseña, por favor."
                        showingAlert = true
                    }
                    else{
                        //TODO: Solicitud login a db
                    }
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
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(AlertTitle),
                message: Text(AlertMessage),
                dismissButton: .default(Text("Aceptar"))
            )
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
    
    //Para alerta
    @State var showingAlert : Bool = false
    @State var AlertTitle : String = ""
    @State var AlertMessage : String = ""
    
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
            TextField("Ej. Rocco", text: $nombre)
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
            SecureField("Confirma tu Contraseña", text: $confirmPassword)
                .padding()
                .background(Color.black.opacity(0.03))
                .cornerRadius(18)
                .foregroundColor(.black)
            
            Button("Registrate"){
                if nombre.isEmpty{
                    //No hay email, enviar error email empty
                    AlertTitle = "Nombre Faltante"
                    AlertMessage = "Ingrese su nombre, por favor."
                    showingAlert = true
                }
                else if email.isEmpty{
                    //No hay email, enviar error email empty
                    AlertTitle = "Correo Faltante"
                    AlertMessage = "Ingrese su correo electrónico, por favor."
                    showingAlert = true
                }
                else if !isValidEmail(email) {
                    //Email formato incorrecto
                    AlertTitle = "Correo Electrónico Inválido"
                    AlertMessage = "Ingrese una dirección de correo válida, por favor."
                    showingAlert = true
                }
                else if password.isEmpty {
                    //No hay contraseña, enviar error contraseña empty
                    AlertTitle = "Contraseña Faltante"
                    AlertMessage = "Ingrese su contraseña, por favor."
                    showingAlert = true
                }
                else if confirmPassword.isEmpty {
                    //No hay confirmContraseña, enviar error contraseña empty
                    AlertTitle = "Confirmar Contraseña"
                    AlertMessage = "Confirme su contraseña, por favor."
                    showingAlert = true
                }
                else if confirmPassword != password {
                    //No hay confirmContraseña, enviar error contraseña empty
                    AlertTitle = "Contraseñas Diferentes"
                    AlertMessage = "Las contraseñas no coinciden, por favor, intente de nuevo."
                    showingAlert = true
                }
                else{
                    // TODO: Mandar solicitud register a db
                }
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
                        if showRegister {
                            showRegister = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    showLogin = true
                                }
                            }
                        }
                        else {
                            showLogin = false
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
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(AlertTitle),
                message: Text(AlertMessage),
                dismissButton: .default(Text("Aceptar"))
            )
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        // Expresión regular para validar el formato de un correo electrónico
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        
        // Usamos NSPredicate para verificar si el correo coincide con la expresión regular
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
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

#Preview {
    ViewLogin()
}
