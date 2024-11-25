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
        print("⏳ Starting data fetch for MuseoInfo...")

        //MARK: Secciones y Exhibiciones
        let fetchedSecciones = await fetchSecciones()
        var updatedSecciones: [Seccion] = []
        print("✅ Secciones fetched: \(fetchedSecciones.count)")
        for seccion in fetchedSecciones {
            var updatedSeccion = seccion
            updatedSeccion.exhibiciones = await fetchExhibiciones(for: seccion.id)
            print("📦 Exhibiciones for \(seccion.nombre): \(updatedSeccion.exhibiciones.count)")
            updatedSecciones.append(updatedSeccion)
        }
        secciones = updatedSecciones
        print("✅ Secciones updated with Exhibiciones.")

        
        //MARK: Exhibicion Home Screen
        ExhibicionHomeScreen = await fetchExhibicionHomeScreen()
        print(ExhibicionHomeScreen.nombre)
        print("✅ Exhibición Home Screen fetched: \(ExhibicionHomeScreen.nombre)")

        
        //MARK: Faq
        let fetchedFAQ = await fetchFAQ()
        FAQ = fetchedFAQ
        print("✅ FAQ fetched: \(fetchedFAQ.count)")

        
        //MARK: Feed
        print("Fetching feed")
        let fetchedFeed = await fetchFeedArticlesWithContents()
        Feed = fetchedFeed
        print("✅ Feed fetched: \(fetchedFeed.count)")

        
        //MARK: Terminar proceso
        if animated {
            withAnimation{
                isLoading.wrappedValue = false
            }
        }
        else {
            isLoading.wrappedValue = false
        }
        print("🏁 Data fetch completed.")

    }
    
    private init() {}
}
