//
//  ViewHomeScreen.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 30/10/24.
//

import SwiftUI

struct ViewHomeScreen: View {
    //let verdePapalote : UIColor = UIColor(red: 198/256, green: 212/256, blue: 68/256, alpha: 1)
    let verdePapalote = Color.accent
    
    let leftPadding : CGFloat = 50
    let wholeScreen : CGFloat = UIScreen.main.bounds.width
    let elementHeight : CGFloat = 130
    
    let noticias = Feed.getArticles()
    let exhibicionRecomendada = ExhibicionEspecial().getExhibicion()
    
    @ObservedObject var colorNavBar = NavBarColor.shared
    
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
                        NavigationLink(destination: ViewExhibicion(exhibicion: exhibicionRecomendada)) {
                            ViewExhibicionMenuItem(exhibicion: exhibicionRecomendada)
                            .offset(x:-leftPadding/2)
                        }
                        
                        //Menú Carrusel
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 20) {
                                
                                //Espacio Vacío
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width:leftPadding/2-20)
                                
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
                                NavigationLink(destination: ViewFAQ()) {
                                    Image("HomeScreenButtonPreguntasFrecuentes")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: elementHeight)
                                }
                                
                                //Espacio Vacío
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width:leftPadding/2-20)
                            }
                        }
                        .padding(.top)
                        .offset(x:-leftPadding/2)
                        
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
                                
                                //Espacio Vacío
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width:leftPadding/2-20)
                            
                                
                                ForEach(noticias) { noticia in
                                    NavigationLink(destination: ViewFeed(article: noticia)) {
                                        ViewFeedMenuItem(article: noticia)
                                    }
                                }
                                
                                //Espacio Vacío
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width:leftPadding-20)
                                
                            }
                        }
                        .offset(x:-leftPadding/2)
                        
                        //Espacio para NavBar
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width:1, height:120)
                    }
                    .frame(width: wholeScreen)
                    .padding(.leading, leftPadding)
                }
            }
            //Top Bar
            .safeAreaInset(edge: .top) {
                PapaloteTopBar(color:Color(verdePapalote), type: .general)
            }
            .onAppear{
                colorNavBar.color = verdePapalote
            }
        }
        .environment(\.colorScheme, .light)
    }
}

#Preview {
    ViewHomeScreen()
}
