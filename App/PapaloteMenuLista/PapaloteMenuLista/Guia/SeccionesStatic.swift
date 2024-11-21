//
//  Secciones.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 09/10/24.
//

import Foundation
import SwiftUICore


struct SeccionStatic: Identifiable {
    let id = UUID()
    let nombre: String
    let color: Color
    let image: Image
    let desc: String
    let exhibiciones: [ExhibicionStatic]
    
    let objetivos: [String]

    init(nombre: String, color: Color, image: Image, desc: String, exhibiciones: [ExhibicionStatic], objetivos: [String] = []) {
        self.nombre = nombre
        self.color = color
        self.image = image
        self.desc = desc
        self.exhibiciones = exhibiciones
        self.objetivos = objetivos
    }
}

struct ExhibicionStatic: Identifiable {
    let id = UUID()
    let nombre: String
    let color: Color
    let image: Image
    let desc: String
    let especial: Bool
//    let isActive: Bool

    let objetivos: [String]
    let preguntas: [String]
    let datosCuriosos: [String]
    let interaccion: [String]
}

struct ExhibicionEspecialStatic {
    func getExhibicion() -> ExhibicionStatic {
        return ListaSeccionesBORRAMENOSIRVO().secciones[1].exhibiciones[0]
    }
}

//Secciones del Museo
struct ListaSeccionesBORRAMENOSIRVO {
    let secciones: [SeccionStatic] = [
        SeccionStatic(
            nombre: "Expreso",
            color: Color("color_expreso"),
            image: Image("img_expreso"),
            desc: "Expreso mis sentimientos y emociones por la naturaleza a través del arte.",
        exhibiciones: [
          ExhibicionStatic(
            nombre: "Composición",
            color: Color("color_expreso"),
            image: Image("img_expreso_composicion"),
            desc: "Realizo composiciones artísticas al acomodar diferentes elementos de la naturaleza.",
            especial: false,
            objetivos: ["Desarrolla composiciones artísticas utilizando diferentes elementos y objetos como arena, conchas y piezas de madera."],
            preguntas: ["¿Qué materiales necesita un artista para crear una obra?", "¿Cómo nos ayuda la naturaleza a hacer arte?", "¿Se puede hacer arte usando sólo objetos naturales?"],
            datosCuriosos: ["El Land Art es una corriente artística que fusiona el arte y el medio ambiente, el resultado son obras que forman parte de los paisajes."],
            interaccion: ["Observa lo que hay en el arenero", "¡Crea tu propia obra de arte con los elementos presentes en la exhibición!"]
                  )
        ],
            objetivos: ["Explore a través de sus sentidos: texturas, formas, patrones, colores y sonidos existentes en la naturaleza", "Reconozca la influencia que la naturaleza ha tenido sobre distintas formas de expresión artística", "Exprese sus emociones en torno a la naturaleza y el medio ambiente"]
        ),
        SeccionStatic(
            nombre: "Comunico",
            color: Color("color_comunico"),
            image: Image("img_comunico"),
            desc: "Comunico mis ideas para mejorar el medio ambiente.",
            exhibiciones: [
          ExhibicionStatic(
            nombre: "Tecnología",
            color: Color("color_comunico"),
            image: Image("img_comunico_tecnologia"),
            desc: "La basura electrónica se reusa, recicla y reduce.",
            especial: true,
            objetivos: ["En esta exhibición, identificarás que los aparatos electrónicos se pueden usar, reciclar y reducir."],
            preguntas: ["¿Qué haces con los aparatos electrónicos que dejan de funcionar?", "¿Conoces el ciclo de vida de los aparatos electrónicos?", "¿Cómo crees que afecta al medio ambiente cuando los residuos electrónicos no se desechan correctamente?"],
            datosCuriosos: ["De acuerdo con la Waste Electrical and Electronic Equipment, 40 millones de toneladas de desechos electrónicos se van a tiraderos a nivel mundial", "Anualmente, en México se produce alrededor de 1.1 millones de toneladas de residuos electrónicos y eléctricos y se estima que para 2026 esta cantidad podría crecer en 17%", "Cada 14 de octubre se celebra el Día Internacional de los Residuos Electrónicos"],
            interaccion: ["Gira los cubos y colócalos en el orden correcto para conocer el ciclo de vida de los electrodomésticos que usamos en la vida cotidiana."]
                  )
        ],
            objetivos: ["Reconozca el valor de divulgar proyectos e iniciativas a favor del medio ambiente", "Identifique que las tecnologías de la información son medios para divulgar proyectos e iniciativas a favor del medio ambiente", "Conozca el trabajo colaborativo que hay detrás de los medios de comunicación"]
        ),
        SeccionStatic(
            nombre: "Pertenezco",
            color: Color("color_pertenezco"),
            image: Image("img_pertenezco"),
            desc: "Pertenezco a una gran red de vida en la que todo se relaciona para funcionar.",
            exhibiciones: [],
            objetivos: ["objetivo1", "objetivo2", "objetivo3"]
        ),
        SeccionStatic(
            nombre: "Pequeños",
            color: Color("color_pequenos"),
            image: Image("img_pequenos"),
            desc: "Exploro la naturaleza a través de mis sentidos.",
            exhibiciones: [],
            objetivos: ["objetivo1", "objetivo2", "objetivo3"]
        ),
        SeccionStatic(
            nombre: "Soy",
            color: Color("color_soy"),
            image: Image("img_soy"),
            desc: "Soy consciente que mis decisiones pueden dañar o mejorar el medio ambiente.",
            exhibiciones: [],
            objetivos: ["objetivo1", "objetivo2", "objetivo3"]
        ),
        SeccionStatic(
            nombre: "Comprendo",
            color: Color("color_comprendo"),
            image: Image("img_comprendo"),
            desc: "Comprendo cómo funciona mi planeta y cómo cuidarlo a través de la ciencia.",
            exhibiciones: [],
            objetivos: ["objetivo1", "objetivo2", "objetivo3"]
        )
    ]
}
