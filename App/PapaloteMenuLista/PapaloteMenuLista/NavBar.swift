//
//  NavBar.swift
//  PapaloteMenuLista
//
//  Created by alumno on 04/11/24.
//

import SwiftUI


struct NavBar: View {
    @Binding var selectedTab: Int
    let color: Color
    @Binding var reload: Bool
    
    @ObservedObject var colorModel = NavBarColor.shared
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    if selectedTab == 0 {
                        reload = true
                    }
                    selectedTab = 0
                }
            }) {
                Image(systemName: "house")
                    .resizable()
                    .scaledToFit()
                    .frame(height:30)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .offset(y:-20)
            
            Button(action: {
                withAnimation {
                    if selectedTab == 1 {
                        reload = true
                    }

                    selectedTab = 1
                }
            }) {
                Image(systemName: "map")
                    .resizable()
                    .scaledToFit()
                    .frame(height:30)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .offset(y:-20)
            
            ZStack {
                Circle()
                    .fill(colorModel.color)
                    .frame(width: 90)
                    .offset(y:-50)
                Button(action: {
                    withAnimation {
                        if selectedTab == 2 {
                            reload = true
                        }

                        selectedTab = 2
                    }
                }) {
                    Image(systemName: "camera.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height:75)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .offset(y:-50)
            }
            
            Button(action: {
                withAnimation {
                    if selectedTab == 3 {
                        reload = true
                    }

                    selectedTab = 3
                }
            }) {
                Image(systemName: "magazine")
                    .resizable()
                    .scaledToFit()
                    .frame(height:30)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .offset(y:-20)
            
            Button(action: {
                withAnimation {
                    if selectedTab == 4 {
                        reload = true
                    }

                    selectedTab = 4
                }
            }) {
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(height:30)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .offset(y:-20)
        }
        .padding()
        .background(colorModel.color)
        .offset(y:60)
        .animation(.easeInOut, value: colorModel.color)
    }
}

#Preview {
    ZStack {
        Color.teal

        VStack{
            Spacer()
            NavBar(selectedTab: .constant(4), color: Color.green, reload: .constant(false))
        }
    }
}
