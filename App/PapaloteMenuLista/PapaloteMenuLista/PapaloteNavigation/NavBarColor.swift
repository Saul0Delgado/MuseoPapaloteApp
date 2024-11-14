//
//  NavBarColor.swift
//  PapaloteMenuLista
//
//  Created by alumno on 04/11/24.
//

import SwiftUI
import Combine

class NavBarColor: ObservableObject {
    static let shared = NavBarColor()
    @Published var color: Color = .accent

    private init() {}
}
