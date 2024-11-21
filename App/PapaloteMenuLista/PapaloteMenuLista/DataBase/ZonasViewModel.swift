//
//  ZonasViewModel.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 20/11/24.
//

import Supabase
import SwiftUI

class ZonasViewModel: ObservableObject {
    @Published var zonas: [Zona] = []
    @Published var errorMessage: String? = nil

    func fetchZonas() {
        Task {
            do {
                errorMessage = nil
                print("Intentando obtener datos de la tabla 'zona'...") // Mensaje de inicio
                
                // Llama a Supabase para obtener los datos
                let response: PostgrestResponse<[Zona]> = try await supabase
                    .from("zona") // Asegúrate de que el nombre de la tabla coincida
                    .select()
                    .execute()
                
                // Verifica el estado de la respuesta
                print("Estado de la respuesta de Supabase:", response)
                
                // Asigna los datos a zonas y muestra la cantidad obtenida
                self.zonas = response.value
                print("Cantidad de zonas obtenidas:", self.zonas.count)
                
                if self.zonas.isEmpty {
                    print("No se encontraron zonas en la base de datos.")
                } else {
                    print("Zonas obtenidas:", self.zonas)
                }
            } catch {
                print("Error al obtener zonas desde Supabase:", error)
                self.errorMessage = "No se pudo cargar las zonas. Intenta nuevamente."
            }
        }
    }
}
