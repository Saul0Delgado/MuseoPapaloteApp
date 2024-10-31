//
//  ViewHomeScreen.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 30/10/24.
//

import SwiftUI

struct ViewHomeScreen: View {
    let verdePapalote : UIColor = UIColor(red: 198/256, green: 212/256, blue: 68/256, alpha: 1)
    
    let leftPadding : CGFloat = 50
    let wholeScreen : CGFloat = UIScreen.main.bounds.width
    let elementHeight : CGFloat = 130
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.white
                ScrollView {
                    VStack (spacing:15) {
                        //Bienvenid@ (al código también!!)
                        HStack {
                            Text("¡Bienvenid@!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 30)
                            Spacer()
                        }
                        
                        HStack {
                            Text("Te invitamos a conocer esta exhibición:")
                                .font(.callout)
                                .padding(.top, 10)
                                .padding(.bottom,5)
                                .opacity(0.5)
                            Spacer()
                        }
                        
                        //Exhibicion Recomendada
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(verdePapalote)
                                )
                            .frame(width: wholeScreen-leftPadding, height:elementHeight)
                            .offset(x:-leftPadding/2)
                        
                        //Menú Carrusel
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 20) {
                                
                                //Botón Mapa
                                Image("HomeScreenButtonMapa")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: elementHeight)
                                
                                //Botón Almanaque
                                Image("HomeScreenButtonAlmanaque")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: elementHeight)
                                
                                //Botón Guía
                                NavigationLink(destination: ListaMapa()) {
                                    Image("HomeScreenButtonGuia")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: elementHeight)
                                }
                                
                                //Botón Preguntas
                                Image("HomeScreenButtonPreguntasFrecuentes")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: elementHeight)
                                
                                //Espacio Vacío
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width:leftPadding-20)
                            }
                        }
                        .padding(.top)
                        
                        //Conocenos
                        HStack {
                            Text("Conócenos")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 30)
                            Spacer()
                        }
                        
                        //Carrusel Noticias
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 20) {
                                
                                //Noticia PlaceHolder
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.teal)
                                    .frame(width: 280, height:elementHeight)
                                
                                //Noticia PlaceHolder
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.teal)
                                    .frame(width: 280, height:elementHeight)
                                
                                //Espacio Vacío
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width:leftPadding-20)
                                
                            }
                        }
                        
                        //Espacio para NavBar
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width:1, height:150)
                    }
                    .frame(width: wholeScreen)
                    .padding(.leading, leftPadding)
                }
            }
            //Top Bar
            .safeAreaInset(edge: .top) {
                PapaloteTopBar(color:Color(verdePapalote), type: .general)
            }
        }
        .environment(\.colorScheme, .light)
    }
}

#Preview {
    ViewHomeScreen()
}
