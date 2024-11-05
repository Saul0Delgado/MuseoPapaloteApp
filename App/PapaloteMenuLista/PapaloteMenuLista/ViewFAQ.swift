//
//  ViewFAQ.swift
//  PapaloteMenuLista
//
//  Created by alumno on 05/11/24.
//

import SwiftUI

struct ViewFAQ: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var colorNavBar = NavBarColor.shared
    let leftPadding : CGFloat = 25
    
    let faq = FAQ().getFAQ()
    
    var body: some View {
        ScrollView{
            VStack{
                
                //Título
                HStack {
                    Text("Preguntas Frecuentes")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 40)
                        .padding(.leading, leftPadding)
                    Spacer()
                }
                
                //For Each del FAQ
                ForEach(faq) { pregunta in
                    ViewFAQItem(pregunta: pregunta)
                }
            }
        }
        //Top Bar
        .safeAreaInset(edge: .top) {
            PapaloteTopBar(color:Color(Color.accent), type: .back)
        }
        //Set navbar color
        .onAppear{
            colorNavBar.color = Color.accent
        }
        //Slide para ir atras
        .gesture(DragGesture(minimumDistance: 30)
            .onEnded { value in
                if value.translation.width > 0 {
                    dismiss()
                }
            }
        )
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ViewFAQ()
}
