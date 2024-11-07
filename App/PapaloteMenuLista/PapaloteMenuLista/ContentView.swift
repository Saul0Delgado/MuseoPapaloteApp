//
//  ContentView.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 09/10/24.
//

import SwiftUI

struct ContentView: View {
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
                    ViewLogin()
                        .id(reloadKey)
                case 2:
                    ViewHomeScreen()
                        .id(reloadKey)
                case 3:
                    ViewHomeScreen()
                        .id(reloadKey)
                case 4:
                    ViewUser()
                        .id(reloadKey)
                default:
                    ViewHomeScreen()
                        .id(reloadKey)
                }
            }
            .animation(.easeInOut, value: selectedTab)
            .animation(.easeInOut, value: reloadKey)
            
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
        }
    }
}


#Preview {
    ContentView()
}
