//
//  AccountHandler.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 11/11/24.
//

import Foundation
import PostgREST

enum LoginResult {
    case success
    case unauthorized
    case error
}

struct DatabaseName : Codable {
    var nombre : TextContent
}

func CheckLogin(email: String, password: String) async -> LoginResult {
    do {
        // Intenta hacer login utilizando Supabase
        let response = try await supabase.auth.signIn(email: email, password: password)
        
        // Si el login es exitoso
        let user = response.user
        
        let active_user = ActiveUser(userId: user.id, correo: user.email ?? "")
        UserManage.saveActiveUser(active_user)
        print(user.id)
        
        return .success

    } catch {
        // Si ocurre algún error en el proceso (por ejemplo, problemas de red o servicio)
        print("Error al hacer login: \(error.localizedDescription)")
        
        if error.localizedDescription == "Invalid login credentials" {
            return .unauthorized
        }
        
        return .error
    }
}

enum RegisterResult {
    case success
    case error
}

func CheckRegister(email: String, password: String) async -> RegisterResult {
    do {
        // Intenta hacer login utilizando Supabase
        let response = try await supabase.auth.signUp(email: email, password: password)
        
        // Si el login es exitoso
        let user = response.user
        
        let active_user = ActiveUser(userId: user.id, correo: user.email ?? "")
        UserManage.saveActiveUser(active_user)
        print("cuenta creada \(user.id)")
        
        return .success

    } catch {
        // Si ocurre algún error en el proceso (por ejemplo, problemas de red o servicio)
        print("Error al hacer login: \(error.localizedDescription)")
        
        if error.localizedDescription == "Invalid login credentials" {
            return .error
        }
        
        return .error
    }
}



// Funciones y Clase Usuario

struct ActiveUser: Codable {
    var userId: UUID
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

