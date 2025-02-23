//
//  ViewAlmanaqueSeccion.swift
//  PapaloteMenuLista
//
//  Created by alumno on 14/11/24.
//

import SwiftUI

struct ViewAlmanaqueSeccion: View {
    @State var seccion : Seccion
    
    let height = 180.0
    let width = UIScreen.main.bounds.width - 50
    let bord_radius = 20.0
    
    @State var isLoading : Bool = true
    
    
    var body: some View {
        
        if isLoading{
            
            VStack(spacing:0) {
                
                ZStack (alignment: .leading) {
                    Rectangle()
                        .fill(Color(seccion.color))
                        .frame(width: width, height: 60)
                        .clipShape(
                            .rect(
                                topLeadingRadius: bord_radius,
                                bottomLeadingRadius: bord_radius,
                                bottomTrailingRadius: bord_radius,
                                topTrailingRadius: bord_radius
                            )
                        )
                    //.shadow(radius: 10, x:10, y:10)
                    Text(seccion.nombre)
                        .frame(alignment: .leading)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.leading,32)
                }
                ZStack{
                    Color(seccion.color)
                    
                        .opacity(0.25)
                    
                        .frame(width: width, height: height * Double((((seccion.almanaque?.count ?? 1)+1)/2)))
                    
                        .clipShape(
                            .rect(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: bord_radius,
                                bottomTrailingRadius: bord_radius,
                                topTrailingRadius: 0
                            )
                        )
                    
                    VStack{
                        Text("Cargando")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.black.opacity(0.5))
                            .padding(.bottom, 10)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black.opacity(0.5)))
                            .scaleEffect(2.0, anchor: .center)
                    }
                }
                .offset(y:-20)
            }
            .onAppear{
                Task{
                    await definirIconos(seccion: $seccion)
                    isLoading = false
                }
            }
                
            
        } else {
            VStack(spacing:0) {
                ZStack (alignment: .leading) {
                    Rectangle()
                        .fill(Color(seccion.color))
                        .frame(width: width, height: 60)
                        .clipShape(
                            .rect(
                                topLeadingRadius: bord_radius,
                                bottomLeadingRadius: bord_radius,
                                bottomTrailingRadius: bord_radius,
                                topTrailingRadius: bord_radius
                            )
                        )
                    //.shadow(radius: 10, x:10, y:10)
                    Text(seccion.nombre)
                        .frame(alignment: .leading)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.leading,32)
                }
                ZStack{
                    Color(seccion.color)
                    
                        .opacity(0.25)
                    
                        .frame(width: width, height: height * Double((((seccion.almanaque?.count ?? 1)+1)/2)))
                    
                        .clipShape(
                            .rect(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: bord_radius,
                                bottomTrailingRadius: bord_radius,
                                topTrailingRadius: 0
                            )
                        )
                    
                    VStack(spacing:55) {
                        // Usamos el índice del arreglo y creamos grupos de 2
                        if let almanaque = seccion.almanaque {
                            ForEach(0..<almanaque.count/2 + (almanaque.count % 2 == 0 ? 0 : 1), id: \.self) { index in
                                HStack {
                                    // Primer exhibición
                                    ZStack {
                                        //Text(seccion.exhibiciones[index * 2].nombre)
                                        IconPlaceholderView(isUnlocked: false, placeholderIcon: UIImage(imageLiteralResourceName: almanaque[index*2].icono_name)
                                        )
                                    }
                                    
                                    
                                    // Segundo exhibición (si existe)
                                    if index * 2 + 1 < almanaque.count {
                                        Spacer()
                                        ZStack {
                                            //Text(seccion.exhibiciones[index * 2 + 1].nombre)
                                            IconPlaceholderView(isUnlocked: true, placeholderIcon: UIImage(imageLiteralResourceName: almanaque[index*2+1].icono_name))
                                        }
                                    }
                                }
                                .frame(width: width*0.8)
                            }
                        } else {
                            Text("No has desbloqueado íconos\npara esta exhibicion.")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.black.opacity(0.5))
                        }
                    }
                    
                }.offset(y:-20)
            }
            .padding(.bottom,20)
        }
        
    }
    
    
    func definirIconos(seccion: Binding<Seccion>) async {
        print("Cargando almanaque para \(seccion.wrappedValue.nombre)...")
        
        for exhibicion in seccion.wrappedValue.exhibiciones {
            
            let hasObtainedIcon = await hasObtainedIcon(exhibicion_id: exhibicion.id)
            
            let icono = exhibicion.icono
            

            if let icono {
                print("Icono encontrado para \(exhibicion.nombre)")
                
                if hasObtainedIcon{
                    print("Icono obtenido!!")
                    let newIcon = IconoAlmanaque(exhibicion: exhibicion, icono_name: icono)
                    if seccion.wrappedValue.almanaque == nil {
                        seccion.wrappedValue.almanaque = []
                    }
                    
                    seccion.wrappedValue.almanaque?.append(newIcon)
                }else{
                    print("Icono no obtenido")
                }
            }
        }
    }
    
}

#Preview {
    ViewAlmanaqueSeccion(seccion: Seccion(
        id: 1,
        nombre: "Expreso",
        color: "color_expreso",
        image_url: "img_expreso",
        desc: "Expreso mis sentimientos y emociones por la naturaleza a través del arte.",
        exhibiciones: [
            Exhibicion(
                id: 1,
                nombre: "Composición",
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
                id: 2,
                nombre: "Composición",
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
                id: 3,
                nombre: "Composición",
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
                nombre: "Composición",
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
                id: 5,
                nombre: "Composición",
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
    ))
}
