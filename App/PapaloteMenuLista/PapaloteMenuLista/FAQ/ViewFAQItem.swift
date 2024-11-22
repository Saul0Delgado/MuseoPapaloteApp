//
//  ViewFAQItem.swift
//  PapaloteMenuLista
//
//  Created by alumno on 05/11/24.
//

import SwiftUI

struct ViewFAQItem: View {
    let pregunta: Question
    let leftPadding: CGFloat = 50
    let wholeScreen = UIScreen.main.bounds.width
    
    let colorPregunta = Color.accent
    
    @State private var isAnswerVisible = false
    
    var body: some View {
        ZStack {
            HStack {
                Text(pregunta.pregunta)
                    .frame(width: 200, alignment: .leading)
                    .padding()
                    .padding(.leading)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                Spacer()
                ZStack {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(width: 40, height: 40)
                        .padding(.trailing, 30)
                        .padding([.top, .bottom])
                    Image(systemName: "chevron.forward.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(isAnswerVisible ? 90 : 0))
                        .animation(.easeInOut(duration: 0.3), value: isAnswerVisible)
                }
            }
            .frame(width: wholeScreen - leftPadding)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(colorPregunta)
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isAnswerVisible.toggle()
                }
            }
        }
        
        if isAnswerVisible {
            HStack {
                Text(.init(pregunta.respuesta))
                    .frame(width: 300, alignment: .leading)
                    .padding()
                    .padding(.leading)
                    .foregroundColor(.black)
                Spacer()
            }
            .frame(width: wholeScreen - leftPadding)
        }
    }
}

#Preview {
    ViewFAQItem(pregunta: FAQ().getFAQ()[0])
    ViewFAQItem(pregunta: FAQ().getFAQ()[1])
    ViewFAQItem(pregunta: FAQ().getFAQ()[2])
    ViewFAQItem(pregunta: FAQ().getFAQ()[3])
}
