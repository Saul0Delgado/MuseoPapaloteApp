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
    @State private var isShowingTutorial = false
    
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
                    NavigationStack {
                        ViewMapa(topBarType : .general)
                            .id(reloadKey)
                    }
                case 2:
                    ViewScanner(selectedTab: $selectedTab)
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
            
            VStack {
                if selectedTab == 2 {
                    HStack {
                        Button(action: {
                            // Navigate back to the previous screen or reset the tab
                            // Reset to home screen or another view
                            withAnimation {
                                selectedTab = 0
                                reloadKey = UUID()
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.backward.circle.fill") // Back icon
                                    .resizable() // Make the icon resizable
                                    .background(Circle().fill(Color.white)) // Circular white background
                                    .scaledToFit() // Keep aspect ratio
                                    .frame(width: 45) // Set the size of the arrow
                                    .padding(25) // Add padding inside the circular background
                                    .foregroundColor(.accent) // Set the arrow color
                                
                            }
                            .foregroundColor(.blue)
                        }
                        .padding(.leading, 10)
                        .padding(.top, 10) // Add top padding to push it down from the top edge
                        
                        Spacer() // Pushes the button to the left
                        Button(action: {
                            // Navigate back to the previous screen or reset the tab
                            // Reset to home screen or another view
                            withAnimation {
                                isShowingTutorial = true
                            }
                        }) {
                            ZStack{
                                Circle()
                                    .fill(.accent)
                                    .frame(height: 45)
                                Image(systemName: "questionmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height:20)
                                    .foregroundStyle(.white)
                            }
                            .padding(.trailing, 25)
                        }
                    }
                    Spacer() // Fills the remaining space below the button
                } else {
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
            .ignoresSafeArea(.keyboard)
        }
          .sheet(isPresented: $isShowingTutorial) {
                      ScannerTutorial(isShowing: $isShowingTutorial)
      }
  }
}


#Preview {
    ViewMain(isLoggedIn: .constant(true))
}
