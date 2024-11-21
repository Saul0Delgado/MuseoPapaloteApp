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
    let exhibicionRecomendada : Exhibicion = Exhibicion(
        id: 1,
        nombre: "Tecnología",
        desc: "La basura electrónica se reusa, recicla y reduce.",
        especial: true,
        featured: false,
        objetivos: ["Identificar que los aparatos electrónicos se pueden usar, reciclar y reducir."],
        preguntas: [
            "¿Qué haces con los aparatos electrónicos que dejan de funcionar?",
            "¿Conoces el ciclo de vida de los aparatos electrónicos?",
            "¿Cómo crees que afecta al medio ambiente cuando los residuos electrónicos no se desechan correctamente?"
        ],
        datosCuriosos: [
            "40 millones de toneladas de desechos electrónicos se van a tiraderos a nivel mundial.",
            "En México se produce alrededor de 1.1 millones de toneladas de residuos electrónicos.",
            "Cada 14 de octubre se celebra el Día Internacional de los Residuos Electrónicos."
        ],
        interaccion: [
            "Gira los cubos y colócalos en el orden correcto.",
            "Conoce el ciclo de vida de los electrodomésticos."
        ],
        image_name: "img_comunico_tecnologia" // Nombre de la imagen en los assets

    )
    
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
        }
        .environment(\.colorScheme, .light)
    }
}

#Preview {
    ViewHomeScreen()
}
