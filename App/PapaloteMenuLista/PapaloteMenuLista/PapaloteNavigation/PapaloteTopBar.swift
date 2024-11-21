//
//  topBarGoBack.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 28/10/24.
//

import SwiftUI

enum TopBarType {
    case back
    case general
    case textConBack
    case textSinBack
}

struct PapaloteTopBar: View {
    @Environment(\.dismiss) var dismiss
    let color : Color
    let type : TopBarType
    var text : String = ""
    
    var body: some View {
        
        if type == .back {
            
            HStack() {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left.circle.fill")
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
            .background(color)
            
        } else if type == .textSinBack {
            
            HStack() {
                Spacer()
                Text(text)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.bottom,7)
            .frame(height: 70)
            .background(color)
            
        } else if type == .textConBack {
            
            HStack() {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width:35)
                        .foregroundStyle(.white)
                        .padding(.leading,24)
                }
                Spacer()
                Text(text)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.trailing,59)
                Spacer()
            }
            .padding(.bottom,7)
            .frame(height: 70)
            .background(color)
            
        } else {
            
            HStack() {
                Spacer()
                Image("papaloteLogoLargo")
                    .resizable()
                    .scaledToFit()
                    .frame(width:280)
                Spacer()
            }
            .padding(.bottom,7)
            .frame(height: 70)
            .background(color)
            
        }
    }
}

#Preview {
    VStack {
        PapaloteTopBar(color: Color.green, type: .textConBack, text: "Hooola")
        Spacer()
    }
}
