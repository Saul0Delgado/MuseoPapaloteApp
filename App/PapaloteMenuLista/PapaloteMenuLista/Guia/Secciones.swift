
//  Secciones.swift
//  PapaloteMenuLista


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


struct Seccion: Identifiable, Codable {
    var id: Int
    var nombre: String
    var color: String
    var image_url: String?
    var desc: String
    var exhibiciones: [Exhibicion]
    var objetivos: [String]
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
    let preguntas: [String]?
    let objetivos: [String]?
    let interaccion: [String]?
    let datosCuriosos: [String]?
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
        
        var fetchedSecciones: [Seccion] = []
        for dbSeccion in databaseSecciones{
            
            let objetivos = await fetchObjetivosZona(for: dbSeccion.id)
            
            let seccion = Seccion(
                id: dbSeccion.id,
                nombre: dbSeccion.nombre,
                color: dbSeccion.color,
                image_url: dbSeccion.image_url,
                desc: dbSeccion.descripcion,
                exhibiciones: [], // Las exhibiciones se cargarán por separado
                objetivos:  objetivos     // Los objetivos se cargarán por separado
            )
            
            fetchedSecciones.append(seccion)
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
        
        
        var fetchedExhibiciones: [Exhibicion] = []
        for dbExhibicion in databaseExhibiciones {
            async let objetivos = await fetchObjetivos(for: dbExhibicion.exhib_id)
            async let preguntas = await fetchPreguntas(for: dbExhibicion.exhib_id)
            async let interaccion = await fetchInteracciones(for: dbExhibicion.exhib_id)
            async let datosCuriosos = await fetchDatosCuriosos(for: dbExhibicion.exhib_id)

            let exhibicion = Exhibicion(
                id: dbExhibicion.exhib_id,
                nombre: dbExhibicion.nombre,
                desc: dbExhibicion.descripcion ?? "Esta actividad no tiene descripción",
                especial: dbExhibicion.especial,
                featured: dbExhibicion.featured,
                objetivos: await objetivos,
                preguntas: await preguntas,
                datosCuriosos: await datosCuriosos,
                interaccion: await interaccion,
                image_name: dbExhibicion.image_name ?? "image_placeholder",
                model_file: dbExhibicion.model_file
            )
            fetchedExhibiciones.append(exhibicion)
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

func fetchInteracciones(for exhibID: Int) async -> [String] {
    do {
        let response: PostgrestResponse<[DatabaseInteraccion]> = try await supabase
            .from("interaccion_exhibicion")
            .select("interaccion")
            .eq("exhib_id", value: exhibID)
            .order("paso", ascending: true)
            .execute()

        return response.value.map { $0.interaccion }
    } catch {
        print("Error al obtener interacciones:", error)
        return []
    }
}

func fetchPreguntas(for exhibID: Int) async -> [String] {
    do {
        let response: PostgrestResponse<[DatabasePregunta]> = try await supabase
            .from("pregunta_exhibicion")
            .select("pregunta")
            .eq("exhib_id", value: exhibID)
            .eq("is_selected", value: true)
            .execute()

        return response.value.map { $0.pregunta }
    } catch {
        print("Error al obtener preguntas:", error)
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
        let response: PostgrestResponse<[DatabaseObjetivo]> = try await supabase
            .from("objetivo_exhibicion")
            .select("objetivo")
            .eq("exhib_id", value: exhibID)
            .eq("is_selected", value: true)
            .execute()
        
        let objetivos = response.value

        // Guardar datos localmente
        LocalStorage.save(objetivos, forKey: localKey)
        UserDefaults.standard.set(Date(), forKey: "lastUpdatedObjetivos_\(exhibID)")

        return response.value.map { $0.objetivo } // Extrae los valores de la clave "objetivo"
    } catch {
        print("Error al obtener objetivos:", error)
        return []
    }
}
struct DatabaseObjetivo: Codable {
    let objetivo: String
}
func fetchDatosCuriosos(for exhibID: Int) async -> [String] {
    do {
        let response: PostgrestResponse<[DatabaseDatoCurioso]> = try await supabase
            .from("datocurioso_exhibicion")
            .select("dato_curioso")
            .eq("exhib_id", value: exhibID)
            .eq("is_selected", value: true)
            .execute()

        return response.value.map { $0.dato_curioso }
    } catch {
        print("Error al obtener datos curiosos:", error)
        return []
    }
}

// Define the structure for decoding "dato_curioso" table
struct DatabaseDatoCurioso: Codable {
    let dato_curioso: String
}

struct DatabaseInteraccion: Codable {
    let interaccion: String
}

struct DatabasePregunta: Codable {
    let pregunta: String
}


func shouldUpdate(entityName: String, lastLocalUpdate: Date?) async -> Bool {
    guard let lastLocalUpdate = lastLocalUpdate else {
        // Si no hay una fecha de última actualización local, forzar fetch
        print("🛑 No local update date found for \(entityName). Fetch required.")
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
            print("📅 Server update for \(entityName): \(serverLastUpdated), Local: \(lastLocalUpdate)")

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

// MARK  Objetivos Zonas
func fetchObjetivosZona(for zonaID: Int) async -> [String] {
    do {
        let response: PostgrestResponse<[DatabaseObjetivoZona]> = try await supabase
            .from("objetivo_zona")
            .select("objetivo")
            .eq("id_zona", value: zonaID)
            .eq("isActive", value: true)
            .execute()
        
        return response.value.map { $0.objetivo }
    } catch {
        print("Error al obtener objetivos de la zona \(zonaID):", error)
        return []
    }
}
// Estructura de decodificación para los objetivos de la zona
struct DatabaseObjetivoZona: Codable {
    let objetivo: String
}
