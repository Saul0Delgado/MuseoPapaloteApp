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
    
    //let faq = FAQ().getFAQ()
    @State var faq : [Question] = MuseoInfo.shared.FAQ
    
    @State var isLoading : Bool = false
    @State var hasAppeared : Bool = false
    
    var body: some View {
        ScrollView{
            VStack{
                
                //Título
                HStack {
                    Text("Preguntas\nFrecuentes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 40)
                        .padding(.leading, leftPadding)
                    Spacer()
                }
                
                //For Each del FAQ
                ForEach(faq, id:\.id) { pregunta in
                    ViewFAQItem(pregunta: pregunta)
                }
                
                //Rectangulo Vacio
                Rectangle()
                    .fill(.clear)
                    .frame(height: 100)
            }
        }
        //Top Bar
        .safeAreaInset(edge: .top) {
            PapaloteTopBar(color:Color(Color.accent), type: .back)
        }
        //Set navbar color
        .onAppear{
            colorNavBar.color = Color.accent
            if !hasAppeared{
                hasAppeared = true
                
                if faq.count == 0{
                    // Secciones no ha cargado, fetch
                    print("Cargando Fetch por primera vez")
                    Task {
                        await MuseoInfo.shared.fetch(isLoading: $isLoading)
                        faq = MuseoInfo.shared.FAQ
                    }
                    
                }else{
                    print("Ya hay datos, no fetch")
                }
                
            }
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
