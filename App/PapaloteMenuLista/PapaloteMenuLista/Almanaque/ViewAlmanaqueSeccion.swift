//
//  ViewAlmanaqueSeccion.swift
//  PapaloteMenuLista
//
//  Created by alumno on 14/11/24.
//

import SwiftUI

struct ViewAlmanaqueSeccion: View {
    var color : Color
    var title : String
    var img : Image
    var cantidad : Int
    
    let height = 130.0
    let width = UIScreen.main.bounds.width - 50
    let bord_radius = 20.0
    
    
    var body: some View {
        VStack(spacing:0) {
            ZStack (alignment: .leading) {
                Rectangle()
                    .fill(color)
                    .frame(width: width, height: 60)
                    .clipShape(
                        .rect(
                            topLeadingRadius: bord_radius,
                            bottomLeadingRadius: bord_radius,
                            bottomTrailingRadius: bord_radius,
                            topTrailingRadius: bord_radius
                        )
                    )
                    .shadow(radius: 10, x:10, y:10)
                Text(title)
                    .frame(alignment: .leading)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.leading,32)
            }
            ZStack{
                Color(color)
                    .opacity(0.25)
                    .frame(width: width, height: height * Double((cantidad/2)))
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: bord_radius,
                            bottomTrailingRadius: bord_radius,
                            topTrailingRadius: 0
                        )
                    )
                HStack{
                    Image(systemName: "photo.on.rectangle.angled")
                        
                        .resizable()
                        
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.white)
                        .frame(width: width/2, height: height)
                        .scaledToFit()
                        .shadow(radius: 5, x:5, y:5)
                        
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.white)
                        .frame(width: width/2, height: height)
                        
                        .shadow(radius: 5, x:5, y:5)
                        
                }
            }.offset(y:-20)
        }
        .padding(.bottom,20)
    }
}

#Preview {
    ViewAlmanaqueSeccion(color: Color.orange, title: "Titulo", img: Image("image_placeholder"), cantidad: 4)
}
