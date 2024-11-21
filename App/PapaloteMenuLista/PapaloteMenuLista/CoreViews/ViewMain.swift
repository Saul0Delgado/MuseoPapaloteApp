//
//  ContentView.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 09/10/24.
//

import SwiftUI

struct ViewMain: View {
    @Binding var isLoggedIn : Bool
    @State var selectedTab = 0
    @State var reload: Bool = false
    
    @State private var reloadKey = UUID()
    
    @ObservedObject var colorNavBar = NavBarColor.shared
    
    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case 0:
                    ViewHomeScreen()
                        .id(reloadKey)
                case 1:
                    ViewMapa(topBarType : .general)
                        .id(reloadKey)
                case 2:
                    ViewScanner()
                        .id(reloadKey)
                case 3:
                    ViewAlmanaque(topBarType:.general)
                        .id(reloadKey)
                case 4:
                    ViewUser(isLoggedIn: $isLoggedIn)
                        .id(reloadKey)
                default:
                    ViewHomeScreen()
                        .id(reloadKey)
                }
            }
            .animation(.smooth, value: selectedTab)
            .animation(.smooth, value: reloadKey)
            
            VStack{
                Spacer()
                NavBar(selectedTab: $selectedTab, color: Color.accent, reload: $reload)
                    .onChange(of: reload) { oldValue, newValue in
                        if newValue == true {
                            print("Recargando página", selectedTab)
                            reload = false
                            withAnimation {
                                reloadKey = UUID()
                            }
                        }
                    }
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}


#Preview {
    ViewMain(isLoggedIn: .constant(true))
}
