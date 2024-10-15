//
//  ViewSeccion.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 09/10/24.
//

import SwiftUI

struct ViewSeccion: View {
    @Environment(\.dismiss) var dismiss
    
    let seccion : Seccion
    let verdePapalote : UIColor = UIColor(red: 198/256, green: 212/256, blue: 68/256, alpha: 1)
    
    var body: some View {
        ZStack {
            ScrollView{
                VStack(spacing:0){
                    seccion.color
                        .frame(height: 132)
                    ZStack {
                        seccion.image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                        LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0), Color.black]),
                                       startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                        VStack {
                            Text(seccion.nombre)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            Text(seccion.desc)
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .lineLimit(/*@START_MENU_TOKEN@*/4/*@END_MENU_TOKEN@*/)
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    ZStack {
                        Color.black
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: UIScreen.main.bounds.width, height: 60)
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 50,
                                    bottomLeadingRadius: 0,
                                    bottomTrailingRadius: 0,
                                    topTrailingRadius: 50
                                )
                            )
                    }
                    Color.white
                        .frame(height: 300)

                    seccion.image
                    seccion.image
                }
                .padding(0)
            }
            .background(Color(seccion.color))
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            //Top Bar
            .safeAreaInset(edge: .top) {
                HStack() {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrowshape.left.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width:35)
                            .foregroundStyle(.white)
                            .padding(.leading,24)
                    }
                    Spacer()
                    Image("papaloteIsotipo")
                        .resizable()
                        .scaledToFit()
                        .frame(width:40)
                        .padding(.trailing,59)
                    Spacer()
                }
                .padding(.bottom,7)
                .frame(height: 70)
                .background(Color(seccion.color))
            }
            .gesture(DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if value.translation.width > 0 {
                        dismiss()
                    }
                }
            )
        }
    }
}


#Preview {
    ViewSeccion(seccion: ListaSecciones().secciones[0])
}
