//
//  Secciones.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 09/10/24.
//

import Foundation
import SwiftUICore


struct Seccion: Identifiable {
    let id = UUID()
    let nombre: String
    let color: Color
    let image: Image
    let desc: String
    let exhibiciones: [Exhibicion]

    init(nombre: String, color: Color, image: Image, desc: String, exhibiciones: [Exhibicion] = []) {
        self.nombre = nombre
        self.color = color
        self.image = image
        self.desc = desc
        self.exhibiciones = exhibiciones
    }
}

struct Exhibicion: Identifiable {
    let id = UUID()
    let nombre: String
    let color: Color
    let image: Image
    let desc: String
    let especial: Bool

    let objetivos: [String]
    let preguntas: [String]
    let datosCuriosos: [String]
    let interaccion: [String]
}

//Secciones del Museo
struct ListaSecciones {
    let secciones: [Seccion] = [
        Seccion(
            nombre: "Expreso",
            color: Color(red: 240/255, green: 131/255, blue: 55/255),
            image: Image("img_expreso"),
            desc: "Expreso mis sentimientos y emociones por la naturaleza a través del arte.",
        exhibiciones: [
          Exhibicion(
            nombre: "Composición",
            color: Color(red: 240/255, green: 131/255, blue: 55/255),
            image: Image("img_expreso_composicion"),
            desc: "Realizo composiciones artísticas al acomodar diferentes elementos de la naturaleza.",
            especial: false,
            objetivos: ["Desarrolla composiciones artísticas utilizando diferentes elementos y objetos como arena, conchas y piezas de madera."],
            preguntas: ["¿Qué materiales necesita un artista para crear una obra?", "¿Cómo nos ayuda la naturaleza a hacer arte?", "¿Se puede hacer arte usando sólo objetos naturales?"],
            datosCuriosos: ["El Land Art es una corriente artística que fusiona el arte y el medio ambiente, el resultado son obras que forman parte de los paisajes."],
            interaccion: ["Observa lo que hay en el arenero", "¡Crea tu propia obra de arte con los elementos presentes en la exhibición!"]
                  )
        ]
        ),
        Seccion(
            nombre: "Comunico",
            color: Color(red: 27/255, green: 98/255, blue: 172/255),
            image: Image("img_comunico"),
            desc: "Comunico mis ideas para mejorar el medio ambiente.",
            exhibiciones: [
          Exhibicion(
            nombre: "Tecnología",
            color: Color(red: 27/255, green: 98/255, blue: 172/255),
            image: Image("img_comunico_tecnologia"),
            desc: "La basura electrónica se reusa, recicla y reduce.",
            especial: false,
            objetivos: ["En esta exhibición, identificarás que los aparatos electrónicos se pueden usar, reciclar y reducir"],
            preguntas: ["¿Qué haces con los aparatos electrónicos que dejan de funcionar?", "¿Conoces el ciclo de vida de los aparatos electrónicos?", "¿Cómo crees que afecta al medio ambiente cuando los residuos electrónicos no se desechan correctamente?"],
            datosCuriosos: ["De acuerdo con la Waste Electrical and Electronic Equipment, 40 millones de toneladas de desechos electrónicos se van a tiraderos a nivel mundial", "Anualmente, en México se produce alrededor de 1.1 millones de toneladas de residuos electrónicos y eléctricos y se estima que para 2026 esta cantidad podría crecer en 17%", "Cada 14 de octubre se celebra el Día Internacional de los Residuos Electrónicos"],
            interaccion: ["Gira los cubos y colócalos en el orden correcto para conocer el ciclo de vida de los electrodomésticos que usamos en la vida cotidiana."]
                  )
        ]
        ),
        Seccion(
            nombre: "Pertenezco",
            color: Color(red: 114/255, green: 165/255, blue: 68/255),
            image: Image("img_pertenezco"),
            desc: "Pertenezco a una gran red de vida en la que todo se relaciona para funcionar.",
            exhibiciones: []
        ),
        Seccion(
            nombre: "Pequeños",
            color: Color(red: 104/255, green: 197/255, blue: 216/255),
            image: Image("img_pequenos"),
            desc: "Exploro la naturaleza a través de mis sentidos.",
            exhibiciones: []
        ),
        Seccion(
            nombre: "Soy",
            color: Color(red: 231/255, green: 61/255, blue: 44/255),
            image: Image("img_soy"),
            desc: "Soy consciente que mis decisiones pueden dañar o mejorar el medio ambiente.",
            exhibiciones: []
        ),
        Seccion(
            nombre: "Comprendo",
            color: Color(red: 47/255, green: 47/255, blue: 120/255),
            image: Image("img_comprendo"),
            desc: "Comprendo cómo funciona mi planeta y cómo cuidarlo a través de la ciencia.",
            exhibiciones: []
        )
    ]
}
