//
//  ViewHomeScreenButton.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 14/11/24.
//

import SwiftUI

struct ViewHomeScreenButton: View {
    let color : Color
    let title : String
    let symbol : Image
    let size : CGFloat
    let imgOffset : [CGFloat]
    let textOffset : CGFloat
    let imgSize : CGFloat
    let fontSize : CGFloat
    
    var body: some View {
        ZStack{
            color
            symbol
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(width:imgSize)
                .offset(x:imgOffset[0],y:imgOffset[1])
            HStack {
                VStack {
                    Text(title)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .font(.system(size: fontSize))
                        .frame(maxWidth: size-textOffset, alignment:.leading)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                Spacer()
            }
            .frame(width: size, height:size)
            .offset(x:textOffset, y:textOffset)
        }
        .frame(width: size, height: size)
        .clipShape(
            .rect(
                topLeadingRadius: 30,
                bottomLeadingRadius: 30,
                bottomTrailingRadius: 30,
                topTrailingRadius: 30
            )
        )
        .clipped()
    }
}

#Preview {
    ZStack {
        Color.black
            .opacity(0.2)
            .ignoresSafeArea()
        VStack(spacing:20) {
            ViewHomeScreenButton(color: Color.teal, title: "Mapa", symbol: Image(systemName: "map"), size: 130, imgOffset:[10,40], textOffset: 20, imgSize: 100, fontSize: 17)
            ViewHomeScreenButton(color: Color.orange, title: "Almanaque", symbol: Image(systemName: "magazine"), size: 130, imgOffset: [10,55], textOffset: 20, imgSize: 100, fontSize: 17)
            ViewHomeScreenButton(color: Color.red, title: "Guía", symbol: Image("magnifying_glass"), size: 130, imgOffset: [10,30], textOffset: 20, imgSize: 110, fontSize: 17)
            ViewHomeScreenButton(color: Color.purple, title: "Preguntas\nFrecuentes", symbol: Image("FAQ_icon"), size: 130, imgOffset: [15,40], textOffset: 20, imgSize: 80, fontSize: 17)
        }
    }
}
