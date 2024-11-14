//
//  AccountHandler.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 11/11/24.
//

import Foundation

enum LoginResult {
    case success
    case unauthorized
    case error
}

func CheckLogin(email: String, password: String) async -> LoginResult {
    //TODO: Llamar bd y checar login exitoso
    
    await UserManage.saveActiveUser(GetUser(email: email)) // Esta linea corre si el registro fue exitoso
    return .success // Temporal
}

enum RegisterResult {
    case success
    case error
}

func CheckRegister(name: String, email: String, password: String) async -> RegisterResult {
    //TODO: Llamar bd y crear cuenta, regresar true si el movimiento fue exitoso
    
    await UserManage.saveActiveUser(GetUser(email: email)) // Esta linea corre si el registro fue exitoso
    return .success // Temporal
}

func GetUser(email: String) async -> ActiveUser {
    //TODO: Llamar bd y obtener información de una cuenta (id, nombre y correo) usando email como parametro
    
    return ActiveUser(userId: 1, nombre: "Test", correo: "placeholder@papalote.com") // Temporal
}

// Funciones y Clase Usuario

struct ActiveUser: Codable {
    var userId: Int
    var nombre: String
    var correo: String
}

class UserManage {

    static func saveActiveUser(_ user: ActiveUser) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: "activeUser")
        }
    }

    static func loadActiveUser() -> ActiveUser? {
        if let savedUserData = UserDefaults.standard.data(forKey: "activeUser") {
            let decoder = JSONDecoder()
            if let loadedUser = try? decoder.decode(ActiveUser.self, from: savedUserData) {
                return loadedUser
            }
        }
        return nil
    }
    
    static func deleteActiveUser() {
            UserDefaults.standard.removeObject(forKey: "activeUser")
    }
}

