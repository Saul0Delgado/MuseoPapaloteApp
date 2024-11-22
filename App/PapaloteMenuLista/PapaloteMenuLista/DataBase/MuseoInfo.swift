//
//  MuseoInfo.swift
//  PapaloteMenuLista
//
//  Created by alumno on 21/11/24.
//

import Foundation
import SwiftUI

class MuseoInfo: ObservableObject {
    static let shared = MuseoInfo()
    @Published var secciones : [Seccion] = []
    @Published var FAQ : [Question] = []
    @Published var ExhibicionHomeScreen : Exhibicion = Exhibicion(id: 0, nombre: "ERROR", desc: "Error fetching exhibicion", especial: false, featured: false, objetivos: [], preguntas: [], datosCuriosos: [], interaccion: [])
    @Published var Feed : [FeedArticle] = []
    
    public func fetch(isLoading: Binding<Bool>, animated: Bool = false) async {
        isLoading.wrappedValue = true
        print("Fetching Info Museo")
        
        //MARK: Secciones y Exhibiciones
        let fetchedSecciones = await fetchSecciones()
        var updatedSecciones: [Seccion] = []
        for seccion in fetchedSecciones {
            var updatedSeccion = seccion
            updatedSeccion.exhibiciones = await fetchExhibiciones(for: seccion.id)

            updatedSecciones.append(updatedSeccion)
        }
        secciones = updatedSecciones
        
        //MARK: Exhibicion Home Screen
        ExhibicionHomeScreen = await fetchExhibicionHomeScreen()
        print(ExhibicionHomeScreen.nombre)
        
        //MARK: Faq
        let fetchedFAQ = await fetchFAQ()
        FAQ = fetchedFAQ
        
        //MARK: Feed
        print("Fetching feed")
        let fetchedFeed = await fetchFeedArticlesWithContents()
        Feed = fetchedFeed
        
        //MARK: Terminar proceso
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
