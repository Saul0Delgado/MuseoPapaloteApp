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
    
    @State var showARView = false
    @State var showDinoGame = false
    
    //let noticias = Feed.getArticles()
    var noticias : [FeedArticle] = MuseoInfo.shared.Feed
    var exhibicionRecomendada : Exhibicion = MuseoInfo.shared.ExhibicionHomeScreen
    
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
                        
                        // Exhibicion Recomendada
                        NavigationLink(destination: ViewExhibicion(exhibicion: exhibicionRecomendada, color: Color("color_comunico"))) {
                            ViewExhibicionMenuItem(exhibicion: exhibicionRecomendada)
                            .offset(x:-leftPadding/2)
                        }
                        .shadow(radius: 5)
                        
                        //Menú Carrusel
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 20) {
                                
                                //Espacio Vacío
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width:leftPadding/2-20)
                                
                                //Botón Mapa
                                NavigationLink(destination: ViewMapa(topBarType : .back)) {
                                    ViewHomeScreenButton(color: Color(red: 0, green: 150/256, blue: 167/256), title: "Mapa", symbol: Image(systemName: "map"), size: 130, imgOffset:[10,40], textOffset: 20, imgSize: 100, fontSize: 17)
                                }
                                
                                //Botón Almanaque
                                NavigationLink(destination: ViewAlmanaque(topBarType:.back)) {
                                    ViewHomeScreenButton(color: Color("color_expreso"), title: "Almanaque", symbol: Image(systemName: "magazine"), size: 130, imgOffset: [10,55], textOffset: 20, imgSize: 100, fontSize: 17)
                                }
                                
                                //Botón Guía
                                NavigationLink(destination: ViewGuia()) {
                                    ViewHomeScreenButton(color:Color.accent, title: "Guía", symbol: Image("magnifying_glass"), size: 130, imgOffset: [10,30], textOffset: 20, imgSize: 110, fontSize: 17)
                                }
                                
                                //Botón Preguntas
                                NavigationLink(destination: ViewFAQ()) {
                                    ViewHomeScreenButton(color: Color("color_pequenos"), title: "Preguntas\nFrecuentes", symbol: Image("FAQ_icon"), size: 130, imgOffset: [15,40], textOffset: 20, imgSize: 80, fontSize: 17)
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
                        .shadow(radius: 8)
                        
                        //Conocenos
                        HStack {
                            Text("Juegos ")
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
                            
                                // AR Button
                                Button(action: {
                                    showARView = true
                                }) {
                                    HStack {
                                        Image(systemName: "cube.transparent")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height:50)
                                            .padding(.trailing, 20)
                                        Text("Decidir")
                                            .font(.title)
                                            .multilineTextAlignment(.leading)
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.horizontal, 50)
                                    .padding(.vertical, 30)
                                    .background(Color.accent)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .padding(.vertical, 10)
                                
                                // Dino Button
                                Button(action: {
                                    showDinoGame = true
                                }) {
                                    HStack {
                                        Image(systemName: "fossil.shell.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height:50)
                                            .padding(.trailing, 20)
                                        Text("Descubre")
                                            .font(.title)
                                            .multilineTextAlignment(.leading)
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.horizontal, 50)
                                    .padding(.vertical, 30)
                                    .background(Color.accent)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .padding(.vertical, 10)
                                
                                
                                
                                //Espacio Vacío
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width:leftPadding-20)
                                
                            }
                        }
                        .offset(x:-leftPadding/2)
                        .shadow(radius: 8)
                        
                        //Toco juego y aprendo
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width:1, height:10)
                        Image("toco_juego_aprendo")
                            .resizable()
                            .scaledToFit()
                            .frame(width:200)
                            .padding(.trailing, leftPadding)
                        
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
            .sheet(isPresented: $showARView) {
                ARViewContainer(onDismiss: {
                    showARView = false
                })
            }
            .sheet(isPresented: $showDinoGame) {
                ContentViewDino()
                    .ignoresSafeArea()  // Add this to ensure full screen coverage
                    .onDisappear {
                        showDinoGame = false
                    }
            }
        }
        .environment(\.colorScheme, .light)
    }
}

#Preview {
    ViewHomeScreen()
}
