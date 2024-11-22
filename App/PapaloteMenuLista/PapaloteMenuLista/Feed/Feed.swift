//
//  Feed.swift
//  PapaloteMenuLista
//
//  Created by alumno on 04/11/24.
//

import SwiftUI
import PostgREST

protocol FeedContent: Codable {
    var id: Int { get }
    var pos: Int { get }
}

struct TextContent: FeedContent, Codable {
    var id: Int
    var feed_id: Int
    var pos: Int
    var text: String

    // Inicializador
    init(id: Int, feed_id: Int, pos: Int, text: String) {
        self.id = id
        self.feed_id = feed_id
        self.pos = pos
        self.text = text
    }
}

struct ImageContent: FeedContent, Codable {
    var id: Int
    var feed_id: Int
    var pos: Int
    var image: String

    // Inicializador
    init(id: Int, feed_id: Int, pos: Int, image: String) {
        self.id = id
        self.feed_id = feed_id
        self.pos = pos
        self.image = image
    }
}

// Enum para manejar la decodificación dinámica de los tipos FeedContent
enum FeedContentType: FeedContent, Codable {
    case text(TextContent)
    case image(ImageContent)

    // Decodificación personalizada para decidir qué tipo de FeedContent decodificar
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let textContent = try? container.decode(TextContent.self) {
            self = .text(textContent)
        } else if let imageContent = try? container.decode(ImageContent.self) {
            self = .image(imageContent)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "No matching type found for FeedContent")
        }
    }

    // Codificación de vuelta a JSON
    func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let textContent):
            try textContent.encode(to: encoder)
        case .image(let imageContent):
            try imageContent.encode(to: encoder)
        }
    }

    var id: Int {
        switch self {
        case .text(let textContent):
            return textContent.id
        case .image(let imageContent):
            return imageContent.id
        }
    }

    var pos: Int {
        switch self {
        case .text(let textContent):
            return textContent.pos
        case .image(let imageContent):
            return imageContent.pos
        }
    }
}

class FeedArticle: Identifiable, Codable {
    var id: Int
    var title: String
    var description: String
    var image: String
    var content: [FeedContentType]  // Usar FeedContentType en lugar de FeedContent

    init(id: Int, title: String, description: String, content: [FeedContentType], image: String) {
        self.id = id
        self.title = title
        self.description = description
        self.content = content
        self.image = image
    }
}

//Intermediaria para bd
class DatabaseFeedArticle: Codable {
    var id: Int
    var title: String
    var description: String
    var image: String

    init(id: Int, title: String, description: String, image: String) {
        self.id = id
        self.title = title
        self.description = description
        self.image = image
    }
}


struct Feed {
    static func getArticles() -> [FeedArticle] {
        return [
            FeedArticle(
                id: 1,
                title: "Avances en Tecnología",
                description: "Últimos avances en el campo de la inteligencia artificial y cómo están cambiando la industria.",
                content: [
                    FeedContentType.text(TextContent(id: 1, feed_id: 1, pos: 0, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla euismod, magna et cursus vulputate, purus erat luctus sapien, a tincidunt eros turpis ac metus. Suspendisse potenti. Vivamus sit amet justo vitae lorem laoreet laoreet id ac augue.")),
                    FeedContentType.image(ImageContent(id: 2, feed_id: 1,pos: 1, image: "img_soy")),
                    FeedContentType.text(TextContent(id: 3, feed_id: 1,pos: 2, text: "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")),
                    FeedContentType.image(ImageContent(id: 4, feed_id: 1,pos: 3, image: "image_placeholder")),
                    FeedContentType.text(TextContent(id: 5, feed_id: 1,pos: 4, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce tincidunt dui nec nisi tincidunt, nec volutpat nulla vehicula. Cras lobortis libero non efficitur cursus."))
                ],
                image: "img_comunico"
            ),
            FeedArticle(
                id: 2,
                title: "Noticia 2: Impacto del Cambio Climático",
                description: "Estudio revela las consecuencias a largo plazo del cambio climático en las zonas costeras.",
                content: [
                    FeedContentType.text(TextContent(id: 1, feed_id: 1, pos: 0, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla euismod, magna et cursus vulputate, purus erat luctus sapien, a tincidunt eros turpis ac metus. Suspendisse potenti. Vivamus sit amet justo vitae lorem laoreet laoreet id ac augue.")),
                    FeedContentType.image(ImageContent(id: 2, feed_id: 1,pos: 1, image: "img_soy")),
                    FeedContentType.text(TextContent(id: 3, feed_id: 1,pos: 2, text: "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")),
                    FeedContentType.image(ImageContent(id: 4, feed_id: 1,pos: 3, image: "image_placeholder")),
                    FeedContentType.text(TextContent(id: 5, feed_id: 1,pos: 4, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce tincidunt dui nec nisi tincidunt, nec volutpat nulla vehicula. Cras lobortis libero non efficitur cursus."))
                ],
                image: "img_soy"
            )
        ]
    }
}

func fetchFeedArticles() async -> [Question] {
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

func fetchFeedArticlesWithContents() async -> [FeedArticle] {
    let localKey = "FeedArticles"
    let lastLocalUpdate = UserDefaults.standard.object(forKey: "lastUpdatedFeedArticles") as? Date

    // Verificar si hay datos locales y si no necesitan actualización
    if let localFeedArticles = LocalStorage.load([FeedArticle].self, forKey: localKey),
       !(await shouldUpdate(entityName: "FeedArticles", lastLocalUpdate: lastLocalUpdate)) {
        return localFeedArticles
    }

    // Fetch remoto si es necesario
    do {
        // Obtener FeedArticles
        let response: PostgrestResponse<[DatabaseFeedArticle]> = try await supabase
            .from("FeedArticles")
            .select("id, title, description, image")
            .execute()
        
        let databaseFeedArticles = response.value
        var fetchedFeedArticles: [FeedArticle] = []

        for dbArticle in databaseFeedArticles {
            // Obtener los contenidos de texto relacionados a este artículo
            let textResponse: PostgrestResponse<[TextContent]> = try await supabase
                .from("FeedTextContent")
                .select("id, feed_id, pos, text")
                .eq("feed_id", value: dbArticle.id)
                .execute()

            let textContents = textResponse.value.map { dbText in
                FeedContentType.text(TextContent(
                    id: dbText.id,
                    feed_id: dbText.feed_id,
                    pos: dbText.pos,
                    text: dbText.text
                ))
            }
            
            // Obtener los contenidos de imagen relacionados a este artículo
            let imageResponse: PostgrestResponse<[ImageContent]> = try await supabase
                .from("FeedImageContent")
                .select("id, feed_id, pos, image")
                .eq("feed_id", value: dbArticle.id)
                .execute()

            let imageContents = imageResponse.value.map { dbImage in
                FeedContentType.image(ImageContent(
                    id: dbImage.id,
                    feed_id: dbImage.feed_id,
                    pos: dbImage.pos,
                    image: dbImage.image
                ))
            }

            // Combinar los contenidos de texto e imagen, y ordenarlos por 'pos'
            let combinedContent = (textContents + imageContents).sorted { $0.pos < $1.pos }
            
            // Crear el FeedArticle con el contenido combinado
            let feedArticle = FeedArticle(
                id: dbArticle.id,
                title: dbArticle.title,
                description: dbArticle.description,
                content: combinedContent,
                image: dbArticle.image
            )

            fetchedFeedArticles.append(feedArticle)
        }

        // Guardar datos localmente
        LocalStorage.save(fetchedFeedArticles, forKey: localKey)
        UserDefaults.standard.set(Date(), forKey: "lastUpdatedFeedArticles")
        
        return fetchedFeedArticles
    } catch {
        print("Error al obtener FeedArticles y contenidos:", error)
        return []
    }
}

