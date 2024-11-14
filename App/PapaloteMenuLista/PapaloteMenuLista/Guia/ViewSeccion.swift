//
//  ViewSeccion.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 09/10/24.
//

import SwiftUI

struct ViewSeccion: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var colorNavBar = NavBarColor.shared
    
    let leftPadding : CGFloat = 50
    let seccion : Seccion
    
    //let verdePapalote : UIColor = UIColor(red: 198/256, green: 212/256, blue: 68/256, alpha: 1)
    
    //View
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView{
                    VStack(spacing:0){
                        seccion.color
                            .frame(height: 115)
                        
                        
                        //Sección Titulo y Descripción
                        ZStack {
                            seccion.image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 330)
                                .clipped()
                            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0), Color.black]),
                                           startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all)
                            VStack {
                                Text(seccion.nombre)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                Text(seccion.desc)
                                    .font(.title2)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.white)
                                    .frame(width: UIScreen.main.bounds.width-50)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        
                        //Sección Exibiciones divertidas
                        ZStack {
                            Color.black
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: UIScreen.main.bounds.width, height: 60)
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 45,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 45
                                    )
                                )
                        }
                        ZStack {
                            Color.white
                            
                            VStack {
                                HStack {
                                    Text("Exhibiciones\nDivertidas")
                                        .fontWeight(.bold)
                                        .font(.largeTitle)
                                        .multilineTextAlignment(.leading)
                                        .padding(.bottom,40)
                                        .foregroundStyle(seccion.color)
                                    Spacer()
                                }
                                .frame(width:UIScreen.main.bounds.width)
                                
                                //Lista de Exhibiciones Recomendadas
                                ScrollView(.horizontal, showsIndicators: false) {
                                    
                                    
                                    HStack(spacing:25) {
                                        
                                        Rectangle()
                                            .foregroundStyle(.clear)
                                            .frame(width:leftPadding/2-20)
                                        
                                        ForEach(seccion.exhibiciones, id: \.nombre) { item in
                                            NavigationLink(destination: ViewExhibicion(exhibicion: item)) {
                                                ZStack {
                                                    item.image
                                                        .frame(width: 300, height: 180)
                                                        .cornerRadius(30)
                                                    Color.black
                                                        .cornerRadius(30)
                                                        .opacity(0.2)
                                                    VStack{
                                                        HStack{
                                                            Text(item.nombre)
                                                                .font(.title)
                                                                .foregroundStyle(.white)
                                                                .fontWeight(.bold)
                                                                .padding(.leading, 30)
                                                            Spacer()
                                                        }
                                                        .padding(.top, 30)
                                                        Spacer()
                                                        HStack{
                                                            Spacer()
                                                            Image(systemName: "chevron.forward.circle")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 50)
                                                                .foregroundStyle(.white)
                                                                .padding(.trailing, 20)
                                                                .padding(.bottom, 20)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        }
                                        seccion.color
                                            .frame(width: 300, height: 180)
                                            .cornerRadius(30)
                                        
                                        //Espacio Vacío
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width:leftPadding-25)
                                    }
                                }
                                .frame(width:UIScreen.main.bounds.width)
                                .offset(x:-leftPadding/2)
                            }
                            .padding(.leading,leftPadding)
                        }
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: UIScreen.main.bounds.width, height: 60)
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 45,
                                    bottomTrailingRadius: 45,
                                    topTrailingRadius: 0
                                )
                            )
                        
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: 50)
                        
                        //Datos Curiosos
                        VStack(spacing:0){
                            HStack {
                                
                                Text("Objetivos de esta zona")
                                    .fontWeight(.bold)
                                    .font(.largeTitle)
                                    .multilineTextAlignment(.leading)
                                    .frame(width:300, height:95, alignment:.leading)
                                    .foregroundStyle(seccion.color)
                                    .padding(.leading,45)
                                Spacer()
                                
                            }
                            .frame(width:UIScreen.main.bounds.width-leftPadding)
                        }
                        .padding(.vertical)
                        .frame(width:UIScreen.main.bounds.width)
                        .background{
                            Color.white
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 45,
                                        bottomLeadingRadius: 45,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 0
                                    )
                                )
                                .offset(x:leftPadding/2)
                        }
                        .padding(.bottom,20)
                        ForEach(seccion.objetivos.indices, id: \.self) { index in
                            HStack {
                                
                                Text("\(index + 1).")
                                    .font(.system(size: 40))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.trailing, 8)
                                
                                // El objetivo
                                Text(seccion.objetivos[index])
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: 250, alignment: .leading)
                                
                                Spacer()
                                
                            }.padding(.leading, leftPadding)
                        }
                        .frame(width:UIScreen.main.bounds.width)
                        .padding(.vertical)
                        
                        VStack {
                            Spacer()
                            Text("Todas las\nExhibiciones")
                                .fontWeight(.bold)
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                                .frame(maxWidth:.infinity, alignment:.leading)
                                .padding(.leading, leftPadding)
                                .padding(.bottom,15)
                        }
                        
                        .frame(height:150)
                        
                        ZStack {
                            Color.white
                                .padding(.top,50)
                            VStack {
                                ForEach(seccion.exhibiciones) { e in
                                    NavigationLink(destination: ViewExhibicion(exhibicion:e)) {
                                        ViewExhibicionMenuItem(exhibicion: e)
                                            .padding(.bottom,25)
                                    }
                                    
                                    //Test, luego quitar
                                    NavigationLink(destination: ViewExhibicion(exhibicion:e)) {
                                        ViewExhibicionMenuItem(exhibicion: e)
                                            .padding(.bottom,25)
                                    }
                                    NavigationLink(destination: ViewExhibicion(exhibicion:e)) {
                                        ViewExhibicionMenuItem(exhibicion: e)
                                            .padding(.bottom,25)
                                    }
                                    NavigationLink(destination: ViewExhibicion(exhibicion:e)) {
                                        ViewExhibicionMenuItem(exhibicion: e)
                                            .padding(.bottom,25)
                                    }
                                    
                                }
                            }
                        }
                        
                        ZStack {
                            Rectangle()
                                .foregroundStyle(.white)
                                .frame(height: 150)
                                .offset(y:150)
                            Rectangle()
                                .foregroundStyle(.white)
                                .frame(height: 150)
                        }
                        
                    }
                }
                .background(Color(seccion.color))
                .ignoresSafeArea()
                .navigationBarBackButtonHidden(true)
                
                
                //Top Bar
                .safeAreaInset(edge: .top) {
                    PapaloteTopBar(color:Color(seccion.color), type: .back)
                }
                .gesture(DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if value.translation.width > 0 {
                            dismiss()
                        }
                    }
                )
            }
            .onAppear{
                colorNavBar.color = seccion.color
            }
        }
        
    }
    
    
}

#Preview {
    
    ViewSeccion(seccion: ListaSecciones().secciones[0])
}
