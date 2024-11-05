//
//  Feed.swift
//  PapaloteMenuLista
//
//  Created by alumno on 04/11/24.
//

import SwiftUI

protocol FeedContent {
    var id: UUID { get }
    var pos: Int { get }
}

struct TextContent: FeedContent {
    var id = UUID()
    var pos: Int
    var text: String

    // Inicializador
    init(pos: Int, text: String) {
        self.pos = pos
        self.text = text
    }
}

struct ImageContent: FeedContent {
    var id = UUID()
    var pos: Int
    var image: Image

    // Inicializador
    init(pos: Int, image: Image) {
        self.pos = pos
        self.image = image
    }
}

class FeedArticle: Identifiable {
    var id: UUID
    var title: String
    var description: String
    var image: Image
    var content: [FeedContent]

    init(title: String, description: String, content: [FeedContent], image: Image) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.content = content
        self.image = image
    }
}

struct Feed {
    static func getArticles() -> [FeedArticle] {
        return [
            FeedArticle(
                title: "Noticia 1: Avances en Tecnología",
                description: "Últimos avances en el campo de la inteligencia artificial y cómo están cambiando la industria.",
                content: [
                    TextContent(pos: 0, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla euismod, magna et cursus vulputate, purus erat luctus sapien, a tincidunt eros turpis ac metus. Suspendisse potenti. Vivamus sit amet justo vitae lorem laoreet laoreet id ac augue."),
                    ImageContent(pos: 1, image: Image("img_soy")),
                    TextContent(pos: 2, text: "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."),
                    ImageContent(pos: 3, image: Image("image_placeholder")),
                    TextContent(pos: 4, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce tincidunt dui nec nisi tincidunt, nec volutpat nulla vehicula. Cras lobortis libero non efficitur cursus.")
                ],
                image: Image("img_comunico")
            ),
            FeedArticle(
                title: "Noticia 2: Impacto del Cambio Climático",
                description: "Estudio revela las consecuencias a largo plazo del cambio climático en las zonas costeras.",
                content: [
                    TextContent(pos: 0, text: "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."),
                    ImageContent(pos: 1, image: Image("img_comunico")),
                    TextContent(pos: 2, text: "Maecenas gravida urna vitae purus lacinia, ac gravida nunc auctor. Integer viverra augue vel mauris iaculis, vel efficitur nulla tristique."),
                    ImageContent(pos: 3, image: Image("img_expreso")),
                    TextContent(pos: 4, text: "Aliquam erat volutpat. Nunc volutpat ligula sit amet felis mollis, sit amet fermentum nisi aliquam. Donec ut erat hendrerit, tincidunt nisl a, euismod libero.")
                ],
                image: Image("img_soy")
            )
        ]
    }
}
