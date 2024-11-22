//
//  FAQ.swift
//  PapaloteMenuLista
//
//  Created by alumno on 05/11/24.
//

import Foundation
import SwiftUI
import PostgREST

struct DatabaseFAQ: Codable {
    let id: Int
    let pregunta: String
    let respuesta: String
    let isActive : Bool
}

class Question : Codable {
    let id : Int;
    let pregunta : String
    let respuesta : String
    let isActive : Bool
    
    init(id: Int, pregunta: String, respuesta: String, isActive: Bool) {
        self.id = id
        self.pregunta = pregunta
        self.respuesta = respuesta
        self.isActive = isActive
    }
}

struct FAQ {
    func getFAQ() -> [Question] {
        return [
            Question(id: 1, pregunta: "¿Pregunta 1?", respuesta: "Respuesta 1!!\n\nPrueba de Respuesta 1", isActive: true),
            Question(id: 2, pregunta: "¿Pregunta 2 mucho texto mas texto pregunta 2?", respuesta: "Respuesta 2", isActive: true),
            Question(id: 3, pregunta: "¿Pregunta 3?", respuesta: "Respuesta 3!!\n\nPrueba de Respuesta 3 con mucho texto largo prueba", isActive: true),
            Question(id: 4, pregunta: "¿Pregunta 4?", respuesta: "Respuesta 4!!\n\nPrueba de Respuesta 4", isActive: true)
            
        ]
    }
}


func fetchFAQ() async -> [Question] {
    let localKey = "FAQ"
    let lastLocalUpdate = UserDefaults.standard.object(forKey: "lastUpdatedFAQ") as? Date

    // Verificar si hay datos locales y si no necesitan actualización
    if let localFAQ = LocalStorage.load([Question].self, forKey: localKey),
       !(await shouldUpdate(entityName: "FAQ", lastLocalUpdate: lastLocalUpdate)) {
        return localFAQ
    }

    // Fetch remoto si es necesario
    do {
        let response: PostgrestResponse<[DatabaseFAQ]> = try await supabase
            .from("FAQ")
            .select("id, pregunta, respuesta, isActive")
            .execute()
        
        let databaseFAQ = response.value
        let fetchedFAQ = databaseFAQ.map { dbSeccion in
            Question(
                id: dbSeccion.id,
                pregunta: dbSeccion.pregunta,
                respuesta: dbSeccion.respuesta,
                isActive: dbSeccion.isActive
            )
        }

        // Guardar datos localmente
        LocalStorage.save(fetchedFAQ, forKey: localKey)
        UserDefaults.standard.set(Date(), forKey: "lastUpdatedFAQ")

        return fetchedFAQ
    } catch {
        print("Error al obtener FAQ:", error)
        return []
    }
}
