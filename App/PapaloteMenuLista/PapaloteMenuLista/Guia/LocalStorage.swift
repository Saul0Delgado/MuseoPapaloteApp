//
//  LocalStorage.swift
//  PapaloteMenuLista
//
//  Created by alumno on 19/11/24.
//

import Foundation


struct LocalStorage {
    // Guardar cualquier objeto codificable
    static func save<T: Codable>(_ data: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    // Cargar cualquier objeto codificable
    static func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(type, from: savedData) {
            return decoded
        }
        return nil
    }
}
