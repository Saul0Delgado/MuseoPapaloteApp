//
//  ViewScanner.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 12/11/24.
//

import SwiftUI

struct ViewScanner: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var colorNavBar = NavBarColor.shared
    @State var firstLaunch: Bool = false
    
    var body: some View {
        VStack{
            if firstLaunch{
                ZStack {
                    ScannerBody()
                    ScannerTutorial(isShowing: $firstLaunch)
                        .transition(.opacity)
                }
            } else {
                ScannerBody()
            }
        }
        .animation(.easeInOut(duration: 0.5), value: firstLaunch)
        //Top Bar
        .safeAreaInset(edge: .top) {
            PapaloteTopBar(color:Color(Color.accent), type: .general)
        }
        //Set navbar color
        .onAppear{
            firstLaunch = isFirstLaunch()
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
    
    func isFirstLaunch() -> Bool {
        let hasSeenTutorial = UserDefaults.standard.bool(forKey: "hasSeenScannerTutorial")
        return !hasSeenTutorial
    }
}

struct ScannerBody : View {
    var body: some View {
        ZStack{
            Color.white.ignoresSafeArea()
            Text("Scanner!!!")
                .foregroundStyle(.black)
        }
        
    }
}

struct ScannerTutorial : View {
    @Binding var isShowing : Bool
    @State private var scale : CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack {
                Image(systemName: "qrcode.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.accent)
                    .frame(width:150)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                            scale = 1.1
                        }
                    }
                Spacer()
                    .frame(height:120)
                Text("Descubre lo invisible! 👀 Escanea los códigos y explora el museo de una manera única. ¡Busca el icono para empezar!")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .frame(width:300)
                    .foregroundStyle(.white)
                    .padding(.bottom,30)
                Button(action:{
                    UserDefaults.standard.set(true, forKey: "hasSeenScannerTutorial")
                    isShowing.toggle()
                }){
                    HStack{
                        Text("Comenzar")
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                        Spacer()
                            .frame(width:60)
                        Image(systemName: "chevron.forward")
                            .resizable()
                            .scaledToFit()
                            .frame(height:25)
                            .foregroundStyle(.white)
                    }
                    .frame(width: 200, height:60)
                    .padding(.horizontal,40)
                    .background{
                        Color.accent
                            .cornerRadius(30)
                    }
                }
            }
            .frame(height:500)
            .offset(y:-45)
        }
    }
}

#Preview {
    ViewScanner()
}
