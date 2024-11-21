//
//  ViewAlmanaqueSeccion.swift
//  PapaloteMenuLista
//
//  Created by alumno on 14/11/24.
//

import SwiftUI

struct ViewAlmanaqueSeccion: View {
    var seccion : Seccion
    
    let height = 160.0
    let width = UIScreen.main.bounds.width - 50
    let bord_radius = 20.0
    
    
    var body: some View {
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
                
                    .frame(width: width, height: height * Double(((seccion.exhibiciones.count+1)/2)))
                
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
                    ForEach(0..<seccion.exhibiciones.count/2 + (seccion.exhibiciones.count % 2 == 0 ? 0 : 1), id: \.self) { index in
                        HStack {
                            // Primer exhibición
                            ZStack {
                                //Text(seccion.exhibiciones[index * 2].nombre)
                                Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(.white)
                                    .frame(height: height*0.6)
                            }
                            
                            
                            // Segundo exhibición (si existe)
                            if index * 2 + 1 < seccion.exhibiciones.count {
                                Spacer()
                                ZStack {
                                    //Text(seccion.exhibiciones[index * 2 + 1].nombre)
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundStyle(.white)
                                        .frame(height: height*0.6)
                                }
                            }
                        }
                        .frame(width: width*0.8)
                    }
                }
                
            }.offset(y:-20)
        }
        
        .padding(.bottom,20)
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
