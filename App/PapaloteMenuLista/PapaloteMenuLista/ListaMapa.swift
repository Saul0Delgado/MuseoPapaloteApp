//
//  ListaMapa.swift
//  PapaloteMenuLista
//
//  Created by alumno on 15/10/24.
//

import SwiftUI

struct ListaMapa: View {
    @Environment(\.dismiss) var dismiss
	let secciones : ListaSecciones = ListaSecciones()
    let leftPadding : CGFloat = 25
    @ObservedObject var colorNavBar = NavBarColor.shared
	
	//let verdePapalote : UIColor = UIColor(red: 198/256, green: 212/256, blue: 68/256, alpha: 1)
    let verdePapalote = Color.accent
	
	var body: some View {
		NavigationStack {
			VStack {
				ScrollView {
					Text("Secciones")
						.font(.largeTitle)
						.fontWeight(.bold)
                        .padding(.leading, leftPadding)
						.padding(.top, 40.0)
						.padding(.bottom, 0)
						.frame(maxWidth: .infinity,alignment: .leading)
					ForEach(secciones.secciones, id: \.nombre) { item in
						NavigationLink(destination: ViewSeccion(seccion: item)) {
							ViewZonaMenuItem(color: item.color, title: item.nombre, img: item.image)
						}
					}
                    
                    Rectangle()
                        .frame(height:120)
                        .foregroundStyle(.clear)
				}
			}
            //Top Bar
            .safeAreaInset(edge: .top) {
                PapaloteTopBar(color:Color(verdePapalote), type: .textConBack, text: "Guía")
            }
            .gesture(DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if value.translation.width > 0 {
                        dismiss()
                    }
                }
            )
			.navigationBarHidden(true)
		}
		.environment(\.colorScheme, .light)
        .onAppear{
            colorNavBar.color = verdePapalote
        }
	}
}


#Preview {
    ZStack {
        ListaMapa()

        VStack{
            Spacer()
            NavBar(selectedTab: .constant(4), color: Color.green, reload: .constant(false))
        }
    }
}
