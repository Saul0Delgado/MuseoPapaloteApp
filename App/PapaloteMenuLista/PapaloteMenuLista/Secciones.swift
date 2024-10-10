//
//  Secciones.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 09/10/24.
//

import Foundation
import SwiftUICore


struct Seccion : Identifiable{
    let id = UUID()
    let nombre : String
    let color : Color
    let image : Image
    let desc : String
    
    init(nombre: String, color: Color, image: Image, desc: String) {
            self.nombre = nombre
            self.color = color
            self.image = image
            self.desc = desc
        }
}

//Secciones del museo
struct ListaSecciones {
    let secciones: [Seccion] = [
        Seccion(nombre: "Expreso", color: Color(red: 240/255, green: 131/255, blue: 55/255), image: Image("image_placeholder"), desc: "Descripcion Expreso"),
        Seccion(nombre: "Comunico", color: Color(red: 27/255, green: 98/255, blue: 172/255), image: Image("image_placeholder"), desc: "Descripcion Comunico"),
        Seccion(nombre: "Pertenezco", color: Color(red: 114/255, green: 165/255, blue: 68/255), image: Image("image_placeholder"), desc: "Descripcion Pertenezco"),
        Seccion(nombre: "Pequeños", color: Color(red: 104/255, green: 197/255, blue: 216/255), image: Image("image_placeholder"), desc: "Descripcion Pequeños"),
        Seccion(nombre: "Soy", color: Color(red: 231/255, green: 61/255, blue: 44/255), image: Image("image_placeholder"), desc: "Descripcion Soy"),
        Seccion(nombre: "Comprendo", color: Color(red: 47/255, green: 47/255, blue: 120/255), image: Image("image_placeholder"), desc: "Comprendo")
        ]
}
