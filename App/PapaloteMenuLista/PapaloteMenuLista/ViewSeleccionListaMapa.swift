//
//  ViewSeleccionListaMapa.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 09/10/24.
//

import SwiftUI

struct ViewSeleccionListaMapa: View {
    var color : Color
    var title : String
    var img : Image
    
    let height = 130.0
    let width = 360.0
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
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
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
                img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: bord_radius,
                            bottomTrailingRadius: bord_radius,
                            topTrailingRadius: 0
                        )
                    )
                    .clipped()
                    .shadow(radius: 10, x:10, y:10)

                Color.black
                    .opacity(0.3)
                    .frame(width: width, height: height)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: bord_radius,
                            bottomTrailingRadius: bord_radius,
                            topTrailingRadius: 0
                        )
                    )
                HStack {
                    Spacer()
                    Image(systemName: "arrowshape.right.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .foregroundStyle(.white)
                        .padding(.trailing,45)
                        .padding(.top, 40)
                }
            }
        }
        .padding(.bottom,20)
    }
}

#Preview {
    ViewSeleccionListaMapa(color: Color.orange, title: "Titulo", img: Image("image_placeholder"))
}
