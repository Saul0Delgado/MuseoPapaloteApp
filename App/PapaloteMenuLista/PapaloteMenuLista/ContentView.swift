//
//  ViewMain.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 11/11/24.
//

import SwiftUI

struct ContentView: View {
    @State var isLoggedIn = false
    
    var body: some View {
        VStack {
            if isLoggedIn {
                ViewMain(isLoggedIn: $isLoggedIn)
                    .transition(.blurReplace(.upUp))
            } else {
                ViewLogin(isLoggedIn: $isLoggedIn)
                    .transition(.blurReplace(.downUp))
            }
        }
        .onAppear {
            let user = UserManage.loadActiveUser()
            
            if user == nil {
                isLoggedIn = false
            } else {
                isLoggedIn = true
            }
        }
        .animation(.easeInOut, value: isLoggedIn)
    }
}

#Preview {
    ContentView()
}
