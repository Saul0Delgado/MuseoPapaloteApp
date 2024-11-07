//
//  User.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 05/11/24.
//

import Foundation

struct ActiveUser: Codable {
    var userId: Int
    var nombre: String
    var correo: String
    var edad: Int
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
