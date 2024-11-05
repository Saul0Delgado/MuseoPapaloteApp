//
//  FAQ.swift
//  PapaloteMenuLista
//
//  Created by alumno on 05/11/24.
//

import Foundation

class Question : Identifiable {
    let id = UUID();
    let pregunta : String
    let respuesta : String
    
    init(pregunta: String, respuesta: String) {
        self.pregunta = pregunta
        self.respuesta = respuesta
    }
}

struct FAQ {
    func getFAQ() -> [Question] {
        return [
            Question(pregunta: "¿Pregunta 1?", respuesta: "Respuesta 1!!\n\nPrueba de Respuesta 1"),
            Question(pregunta: "¿Pregunta 2 mucho texto mas texto pregunta 2?", respuesta: "Respuesta 2"),
            Question(pregunta: "¿Pregunta 3?", respuesta: "Respuesta 3!!\n\nPrueba de Respuesta 3 con mucho texto largo prueba"),
            Question(pregunta: "¿Pregunta 4?", respuesta: "Respuesta 4!!\n\nPrueba de Respuesta 4")
            
        ]
    }
}
