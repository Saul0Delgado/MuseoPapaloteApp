
//
//  Secciones.swift
//  PapaloteMenuLista
//
//  Created by alumno on 19/11/24.
//

import Foundation
import SwiftUICore
import SwiftUI
import PostgREST

// Estructura intermedia para decodificación de la tabla zona
struct DatabaseSeccion: Codable {
    let id: Int
    let nombre: String
    let color: String
    let image_url: String?
    let descripcion: String
}

// Estructura intermedia para decodificación de la tabla exhibicion
struct DatabaseExhibicion: Codable {
    let exhib_id: Int
    let nombre: String
    let descripcion: String?
    let especial: Bool
    let featured: Bool
    let image_name: String?
    let model_file: String?
}

struct Seccion: Identifiable, Codable {
    var id: Int
    var nombre: String
    var color: String
    var image_url: String?
    var desc: String
    var exhibiciones: [Exhibicion]
    var objetivos: [String]
}

struct Exhibicion: Identifiable, Codable {
    var id: Int
    var nombre: String
    var desc: String
    var especial: Bool
    var featured: Bool
    var objetivos: [String]
    var preguntas: [String]
    var datosCuriosos: [String]
    var interaccion: [String]
    var image_name: String?
    var model_file: String?
    
}

struct DatabaseExhibicionHomeScreen: Identifiable, Codable {
    var id: Int
}

func fetchSecciones() async -> [Seccion] {
    let localKey = "secciones"
    let lastLocalUpdate = UserDefaults.standard.object(forKey: "lastUpdatedSecciones") as? Date

    // Verificar si hay datos locales y si no necesitan actualización
    if let localSecciones = LocalStorage.load([Seccion].self, forKey: localKey),
       !(await shouldUpdate(entityName: "secciones", lastLocalUpdate: lastLocalUpdate)) {
        return localSecciones
    }

    // Fetch remoto si es necesario
    do {
        let response: PostgrestResponse<[DatabaseSeccion]> = try await supabase
            .from("zona")
            .select("id, nombre, color, descripcion, image_url")
            .execute()
        
        let databaseSecciones = response.value
        let fetchedSecciones = databaseSecciones.map { dbSeccion in
            Seccion(
                id: dbSeccion.id,
                nombre: dbSeccion.nombre,
                color: dbSeccion.color,
                image_url: dbSeccion.image_url,
                desc: dbSeccion.descripcion,
                exhibiciones: [], // Las exhibiciones se cargarán por separado
                objetivos: []     // Los objetivos se cargarán por separado
            )
        }

        // Guardar datos localmente
        LocalStorage.save(fetchedSecciones, forKey: localKey)
        UserDefaults.standard.set(Date(), forKey: "lastUpdatedSecciones")

        return fetchedSecciones
    } catch {
        print("Error al obtener secciones:", error)
        return []
    }
}

func fetchExhibicionHomeScreen() async -> Exhibicion {
    let localKey = "ExhibicionHomeScreen"
    let lastLocalUpdate = UserDefaults.standard.object(forKey: "lastUpdatedExhHomeScreen") as? Date
    var exhibicionFetched : Exhibicion = Exhibicion(id: 0, nombre: "ERROR", desc: "Error fetching exhibicion", especial: false, featured: false, objetivos: [], preguntas: [], datosCuriosos: [], interaccion: [])

    // Verificar si hay datos locales y si no necesitan actualización
    if let localExh = LocalStorage.load(Exhibicion.self, forKey: localKey),
       !(await shouldUpdate(entityName: "ExhibicionHomeScreen", lastLocalUpdate: lastLocalUpdate)) {
        return localExh
    }

    // Fetch remoto si es necesario
    do {
        let response: PostgrestResponse<[DatabaseExhibicionHomeScreen]> = try await supabase
            .from("exhibicion_home_screen")
            .select("id")
            .execute()
        
        
        let databaseSecciones = response.value[0]
        if let objetoEncontrado = MuseoInfo.shared.secciones
            .flatMap({ $0.exhibiciones })
            .first(where: { $0.id == databaseSecciones.id })
        {
            exhibicionFetched = objetoEncontrado
        }

        
        // Guardar datos localmente
        LocalStorage.save(exhibicionFetched, forKey: localKey)
        UserDefaults.standard.set(Date(), forKey: "lastUpdatedExhHomeScreen")

        return exhibicionFetched
    } catch {
        print("Error al obtener secciones:", error)
        return exhibicionFetched
    }
}

func fetchExhibiciones(for zonaID: Int) async -> [Exhibicion] {
    let localKey = "exhibiciones_\(zonaID)"
    let lastLocalUpdate = UserDefaults.standard.object(forKey: "lastUpdatedExhibiciones_\(zonaID)") as? Date

    // Verificar si hay datos locales y si no necesitan actualización
    if let localExhibiciones = LocalStorage.load([Exhibicion].self, forKey: localKey),
       !(await shouldUpdate(entityName: "exhibiciones", lastLocalUpdate: lastLocalUpdate)) {
        return localExhibiciones
    }

    // Fetch remoto si es necesario
    do {
        let response: PostgrestResponse<[DatabaseExhibicion]> = try await supabase
            .from("exhibicion")
            .select("exhib_id, nombre, descripcion, especial, featured, image_name, model_file")
            .eq("zona_id", value: zonaID)
            .execute()
        
        let databaseExhibiciones = response.value
        let fetchedExhibiciones = databaseExhibiciones.map { dbExhibicion in
            Exhibicion(
                id: dbExhibicion.exhib_id,
                nombre: dbExhibicion.nombre,
                desc: dbExhibicion.descripcion ?? "Esta actividad no tiene descripcion",
                especial: dbExhibicion.especial,
                featured: dbExhibicion.featured,
                objetivos: [],
                preguntas: [],
                datosCuriosos: [],
                interaccion: [],
                image_name: dbExhibicion.image_name ?? "placeholder_image",
                model_file: dbExhibicion.model_file
            )
        }

        // Guardar datos localmente
        LocalStorage.save(fetchedExhibiciones, forKey: localKey)
        UserDefaults.standard.set(Date(), forKey: "lastUpdatedExhibiciones_\(zonaID)")

        return fetchedExhibiciones
    } catch {
        print("Error al obtener exhibiciones:", error)
        return []
    }
}

func fetchObjetivos(for exhibID: Int) async -> [String] {
    let localKey = "objetivos_\(exhibID)"
    let lastLocalUpdate = UserDefaults.standard.object(forKey: "lastUpdatedObjetivos_\(exhibID)") as? Date

    // Comprobar datos locales
    if let localObjetivos = LocalStorage.load([String].self, forKey: localKey),
       !(await shouldUpdate(entityName: "objetivos", lastLocalUpdate: lastLocalUpdate)) {
        return localObjetivos
    }

    // Si no hay datos locales o es necesario actualizar, fetch remoto
    do {
        let response: PostgrestResponse<[String]> = try await supabase
            .from("objetivo_exhibicion")
            .select("objetivo")
            .eq("exhib_id", value: exhibID)
            .eq("is_selected", value: true)
            .execute()
        
        let objetivos = response.value

        // Guardar datos localmente
        LocalStorage.save(objetivos, forKey: localKey)
        UserDefaults.standard.set(Date(), forKey: "lastUpdatedObjetivos_\(exhibID)")

        return objetivos
    } catch {
        print("Error al obtener objetivos:", error)
        return []
    }
}

func shouldUpdate(entityName: String, lastLocalUpdate: Date?) async -> Bool {
    guard let lastLocalUpdate = lastLocalUpdate else {
        // Si no hay una fecha de última actualización local, forzar fetch
        return true
    }
    
    do {
        let response: PostgrestResponse<[UpdateRecord]> = try await supabase
            .from("updates")
            .select("entity_name, last_updated")
            .eq("entity_name", value: entityName)
            .execute()
        
        guard let serverUpdate = response.value.first else {
            // Si no hay registros en el servidor, no es necesario actualizar
            return false
        }
        
        // Compara las fechas de actualización
        if let serverLastUpdated = ISO8601DateFormatter().date(from: serverUpdate.last_updated) {
            return serverLastUpdated > lastLocalUpdate
        }
    } catch {
        print("Error al verificar actualizaciones para \(entityName):", error)
    }
    
    return false
}

struct UpdateRecord: Codable {
    let entity_name: String
    let last_updated: String
}
<<<<<<< Updated upstream
=======


class MuseoInfo: ObservableObject {
    static let shared = MuseoInfo()
    @Published var secciones : [Seccion] = []
    
    public func fetch(isLoading: Binding<Bool>, animated: Bool = false) async {
        isLoading.wrappedValue = true
        print("Fetching Info Museo")
        
        let fetchedSecciones = await fetchSecciones()
        
        var updatedSecciones: [Seccion] = []
        
        for seccion in fetchedSecciones {
            var updatedSeccion = seccion
            updatedSeccion.exhibiciones = await fetchExhibiciones(for: seccion.id)

            updatedSecciones.append(updatedSeccion)
        }
        
        secciones = updatedSecciones
        
        if animated {
            withAnimation{
                isLoading.wrappedValue = false
            }
        }
        else {
            isLoading.wrappedValue = false
        }
    }
    
    private init() {}
}
>>>>>>> Stashed changes
