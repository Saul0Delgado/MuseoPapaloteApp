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
    let wholeScreen : CGFloat = UIScreen.main.bounds.width
    let seccion : Seccion

    
    //View
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView{
                    VStack(spacing:0){
                        Color(seccion.color)
                            .frame(height: 115)
                        
                        
                        //MARK: Sección Titulo y Descripción
                        ZStack {
                            Image(seccion.image_url ?? "image_placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width:wholeScreen, height: 330)
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
                        
                        
                        //MARK: Sección Exibiciones divertidas
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
                                        .foregroundStyle(Color(seccion.color))
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
                                            
                                            if item.featured{
                                                NavigationLink(destination: ViewExhibicion(exhibicion: item, color: Color(seccion.color))) {
                                                    ZStack {
                                                        Image(item.image_name ?? "image_placeholder")
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
                                        }
                                        
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
                        
                        //MARK: Objetivos
                        VStack(spacing:0){
                            
                            
                            
                            
                            HStack {
                                
                                Text("Objetivos de esta zona")
                                    .fontWeight(.bold)
                                    .font(.largeTitle)
                                    .multilineTextAlignment(.leading)
                                    .frame(width:300, height:95, alignment:.leading)
                                    .foregroundStyle(Color(seccion.color))
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
                        
                        
                        //MARK: Todas Exhibiciones
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
                                ForEach(seccion.exhibiciones, id:\.id) { e in
                                    NavigationLink(destination: ViewExhibicion(exhibicion:e, color: Color(seccion.color))) {
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
                colorNavBar.color = Color(seccion.color)
            }
        }
        
    }
    
    
}

#Preview {
    ViewSeccion(
        seccion: Seccion(
            id: 1,
            nombre: "Expreso",
            color: "color_expreso",
            image_url: "img_pertenezco",
            desc: "Expreso mis sentimientos y emociones por la naturaleza a través del arte.",
            exhibiciones: [
                Exhibicion(
                    id: 1,
                    nombre: "Ex",
                    desc: "Realizo composiciones artísticas al acomodar diferentes elementos de la naturaleza.",
                    especial: false,
                    featured: true,
                    objetivos: ["Objetivo 1", "Objetivo 2"],
                    preguntas: ["¿Qué materiales necesita un artista para crear una obra?"],
                    datosCuriosos: ["El Land Art fusiona el arte y el medio ambiente."],
                    interaccion: ["Crea tu obra con los elementos presentes."],
                    image_name: "img_expreso_composicion"
                ),
                Exhibicion(
                    id: 2,
                    nombre: "Ho",
                    desc: "Realizo composiciones artísticas al acomodar diferentes elementos de la naturaleza.",
                    especial: false,
                    featured: true,
                    objetivos: ["Objetivo 1", "Objetivo 2"],
                    preguntas: ["¿Qué materiales necesita un artista para crear una obra?"],
                    datosCuriosos: ["El Land Art fusiona el arte y el medio ambiente."],
                    interaccion: ["Crea tu obra con los elementos presentes."],
                    image_name: "img_expreso_composicion"
                ),
                Exhibicion(
                    id: 3,
                    nombre: "FALSOOO",
                    desc: "Realizo composiciones artísticas al acomodar diferentes elementos de la naturaleza.",
                    especial: false,
                    featured: false,
                    objetivos: ["Objetivo 1", "Objetivo 2"],
                    preguntas: ["¿Qué materiales necesita un artista para crear una obra?"],
                    datosCuriosos: ["El Land Art fusiona el arte y el medio ambiente."],
                    interaccion: ["Crea tu obra con los elementos presentes."],
                    image_name: "img_expreso_composicion"
                ),
                Exhibicion(
                    id: 4,
                    nombre: "FALSOO",
                    desc: "Realizo composiciones artísticas al acomodar diferentes elementos de la naturaleza.",
                    especial: false,
                    featured: false,
                    objetivos: ["Objetivo 1", "Objetivo 2"],
                    preguntas: ["¿Qué materiales necesita un artista para crear una obra?"],
                    datosCuriosos: ["El Land Art fusiona el arte y el medio ambiente."],
                    interaccion: ["Crea tu obra con los elementos presentes."],
                    image_name: "img_expreso_composicion"
                )
            ],
            objetivos: [
                "Explore a través de sus sentidos texturas, formas y patrones.",
                "Reconozca la influencia que la naturaleza tiene sobre el arte."
            ]
        )
    )
}

