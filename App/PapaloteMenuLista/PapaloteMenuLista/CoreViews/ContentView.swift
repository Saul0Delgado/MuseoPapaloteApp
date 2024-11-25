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
                    ViewLoading()
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
                //Borrar Data Local para hacer fetch
                clearAllLocalData()

                
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

func clearAllLocalData() {
    if let appDomain = Bundle.main.bundleIdentifier {
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        UserDefaults.standard.synchronize() // Asegúrate de sincronizar para aplicar los cambios
    }
    print("🧹 Todos los datos locales han sido eliminados.")
}
