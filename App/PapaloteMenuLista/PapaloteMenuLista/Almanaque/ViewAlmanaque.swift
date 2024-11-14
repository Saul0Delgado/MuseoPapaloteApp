//
//  ViewAlmanaque.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 12/11/24.
//

import SwiftUI

struct ViewAlmanaque: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var colorNavBar = NavBarColor.shared
    
    var body: some View {
        ScrollView{
            VStack{
                
                //Body
                Text("Almanaque")
            }
        }
        //Top Bar
        .safeAreaInset(edge: .top) {
            PapaloteTopBar(color:Color(Color.accent), type: .general)
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
    ViewAlmanaque()
}
