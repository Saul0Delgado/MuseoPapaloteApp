//
//  ScannerBody.swift
//  PapaloteMenuLista
//
//  Created by alumno on 14/11/24.
//

import SwiftUI

struct ScannerBody : View {
    var body: some View {
        ZStack{
            Color.white.ignoresSafeArea()
            Text("Scanner Body")
                .foregroundStyle(.black)
                .offset(y:-50)
        }
        
    }
}

#Preview {
    ScannerBody()
}
