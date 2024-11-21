//
//  ViewMain.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 11/11/24.
//

import SwiftUI

struct ContentView: View {
    @State var isLoggedIn = false
    
    @State var isLoading = true
    @State var hasAppeared = false
    @State var infoMuseo : [Seccion] = MuseoInfo.shared.secciones
    
    var body: some View {
        VStack {
            if isLoggedIn {
                if isLoading {
                    //Loading
                    ZStack{
                        Color.accent
                            .ignoresSafeArea()
                        VStack {
                            Spacer()
                            Text("Cargando")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.bottom, 30)
                                .offset(y:-70)
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(2.0, anchor: .center)
                                .offset(y:-70)
                            
                            Text("MEJORAR ESTA PANTALLA IMPORTANTE")
                            Spacer()
                        }
                    }
                }
                else {
                    ViewMain(isLoggedIn: $isLoggedIn)
                        .transition(.blurReplace(.upUp))
                }
            } else {
                ViewLogin(isLoggedIn: $isLoggedIn)
                    .transition(.blurReplace(.downUp))
            }
        }
        .onAppear {
            if !hasAppeared {
                hasAppeared = true
                print("appearing")
                
                //Cargar cuenta activa
                let user = UserManage.loadActiveUser()
                
                if user == nil {
                    isLoggedIn = false
                } else {
                    isLoggedIn = true
                }
                
                //Activar tutorial de Scanner
                UserDefaults.standard.set(false, forKey: "hasSeenScannerTutorial")
                
                //FetchSecciones
                
                if infoMuseo.count == 0{
                    //Primer fetch, cargar
                    Task{
                        await MuseoInfo.shared.fetch(isLoading: $isLoading, animated: true)
                    }
                }else{
                    //Todo al tiro, no cargar
                    isLoading = false
                }
                
            }
        }
        .animation(.easeInOut, value: isLoggedIn)
        .environment(\.colorScheme, .light)
    }
}

#Preview {
    ContentView()
}
