//
//  IconItem.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 22/11/24.
//


import SwiftUI

struct IconItem: Identifiable {
    let id: Int
    let placeholderImage: UIImage
    var albumImage: UIImage?
    var isFound: Bool {
        return albumImage != nil
    }
}

class IconAlbumViewModel: ObservableObject {
    @Published var icons: [IconItem] = [
        IconItem(id: 1, placeholderImage: UIImage(named: "Icono_Viento")!),
        IconItem(id: 2, placeholderImage: UIImage(named: "Icono_Especies")!),
        IconItem(id: 3, placeholderImage: UIImage(named: "Icono_Tutorial")!)
    ]
    
    private let nameToId: [String: Int] = [
        "Wind Icon": 1,
        "Bug Icon": 2,
        "Fire Icon": 3
    ]
    
    func getIdExhibicionWithIcon(name: String) -> Int {
        if let id = nameToId[name] {
            return id
        }
        return -1
    }

    func updateIcon(with name: String, image: UIImage) {
        if let id = nameToId[name] {
            updateIcon(id: id, with: image)
        } else {
            print("Unknown icon name: \(name)")
        }
    }

    private func updateIcon(id: Int, with image: UIImage) {
        if let index = icons.firstIndex(where: { $0.id == id }) {
            icons[index].albumImage = image
        }
    }
}
