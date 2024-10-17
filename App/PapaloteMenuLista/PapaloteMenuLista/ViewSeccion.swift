//
//  ViewSeccion.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 09/10/24.
//

import SwiftUI

struct ViewSeccion: View {
	@Environment(\.dismiss) var dismiss
	
	let leftPadding : CGFloat = 50
	let seccion : Seccion
	let verdePapalote : UIColor = UIColor(red: 198/256, green: 212/256, blue: 68/256, alpha: 1)
	
	@State var rating : Int = 4
	@State var opinion : String = ""
	@FocusState private var isKeyboardFocused : Bool
	@State private var scrollToBottom : Bool = false
	@State var keyboardHeight : CGFloat = 0
	
	@State private var showAlert: Bool = false
	@State private var alertTitle : String = ""
	@State private var alertMessage: String = ""
	
	func ShowAlert(alert_message: String, alert_title: String) {
		alertMessage = alert_message
		alertTitle = alert_title
		showAlert = true
	}
	
	func EnviarOpinion(user: Int, rating: Int, opinion: String, completion: @escaping (Bool) -> Void) {
		
		print(user, seccion.nombre, rating, opinion)
		
		//Simulación de envio
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			let success = true
			completion(success)
		}
	}
	
	//View
	var body: some View {
		ZStack {
			ScrollViewReader { scrollProxy in
				ScrollView{
					VStack(spacing:0){
						seccion.color
							.frame(height: 132)
						
						
						//Sección Titulo y Descripción
						ZStack {
							seccion.image
								.resizable()
								.aspectRatio(contentMode: .fill)
								.frame(height: 330)
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
						
						
						//Sección Exibiciones divertidas
						ZStack {
							Color.black
							Rectangle()
								.fill(Color.white)
								.frame(width: UIScreen.main.bounds.width, height: 60)
								.clipShape(
									.rect(
										topLeadingRadius: 45,
										bottomLeadingRadius: 0,
										bottomTrailingRadius: 0,
										topTrailingRadius: 45
									)
								)
						}
						ZStack {
							Color.white
							
							VStack {
								HStack {
									Text("Exhibiciones\nDivertidas")
										.fontWeight(.bold)
										.font(.largeTitle)
										.multilineTextAlignment(.leading)
										.padding(.bottom,40)
										.foregroundStyle(seccion.color)
									Spacer()
								}
								.frame(width:UIScreen.main.bounds.width)
								
								//Lista de Exhibiciones Recomendadas
								ScrollView(.horizontal, showsIndicators: false) {
									HStack(spacing:25) {
										seccion.color
											.frame(width: 300, height: 180)
											.cornerRadius(30)
										seccion.color
											.frame(width: 300, height: 180)
											.cornerRadius(30)
										seccion.color
											.frame(width: 300, height: 180)
											.cornerRadius(30)
											.padding(.trailing,50)
									}
									
								}
								.frame(width:UIScreen.main.bounds.width)
							}
							.padding(.leading,leftPadding)
						}
						Rectangle()
							.fill(Color.white)
							.frame(width: UIScreen.main.bounds.width, height: 60)
							.clipShape(
								.rect(
									topLeadingRadius: 0,
									bottomLeadingRadius: 45,
									bottomTrailingRadius: 45,
									topTrailingRadius: 0
								)
							)
						
						
						//Sección Retroalimentacion
						VStack{
							
							//Titulo
							HStack{
								Text("¿Ya visitaste esta zona? Déjanos tus comentarios")
									.font(.largeTitle)
									.fontWeight(.bold)
									.frame(width: 300)
									.foregroundStyle(.white)
								Spacer()
							}
							.frame(width: UIScreen.main.bounds.width)
							.padding(.top,30)
							.padding(.leading,leftPadding)
							
							//Estrellas
							HStack {
								StarRating(rating: $rating)
								Spacer()
							}
							.padding(.leading,leftPadding)
							
							//TextField
							HStack {
								ZStack{
									Rectangle()
										.foregroundStyle(.white)
										.clipShape(
											.rect(
												topLeadingRadius: 0,
												bottomLeadingRadius: 30,
												bottomTrailingRadius: 30,
												topTrailingRadius: 30
											)
										)
									VStack {
										TextField("", text: $opinion, prompt: Text("Escribe tu opinión...").foregroundStyle(.gray), axis:.vertical)
											.lineLimit(5)
											.padding(.top,20)
											.padding(.leading,10)
											.frame(width: 300)
											.focused($isKeyboardFocused)
											.foregroundStyle(.black)
											.id(101010)
										Spacer()
									}
								}
								.frame(width: 320, height:150)
								Spacer()
							}
							.padding(.leading,leftPadding)
							.padding(.top,20)
							
							//Botón Enviar
							HStack{
								Button {
									guard !opinion.isEmpty else {
										ShowAlert(alert_message: "Por favor, escribe una opinión", alert_title: "Datos Faltantes")
										return
									}
									
									EnviarOpinion(user: 1, rating: rating, opinion: opinion) { success in
										if !success {
											ShowAlert(alert_message: "Ocurrió un error al enviar tu opinión, inténtalo más tarde.", alert_title: "Error")
										} else {
											ShowAlert(alert_message: "¡Tu retroalimentación se envió correctamente, Agradecemos tus comentarios!", alert_title: "¡Listo!")
											opinion = ""
											rating = 4
										}
									}
									
									
									isKeyboardFocused = false
								} label: {
									ZStack{
										RoundedRectangle(cornerRadius: 30.0)
											.foregroundStyle(.white)
										Text("Enviar")
											.fontWeight(.bold)
											.foregroundStyle(seccion.color)
									}
									.frame(width: 150, height:60)
									.padding(.bottom,20)
								}
								Spacer()
							}
							.padding(.top, 20)
							.padding(.leading, leftPadding)
							
							Rectangle()
								.fill(seccion.color)
								.frame(width: 1, height:keyboardHeight)
							
						}
					}
				}
				.onTapGesture(perform: {
					isKeyboardFocused = false
				})
				.background(Color(seccion.color))
				.ignoresSafeArea()
				.navigationBarBackButtonHidden(true)
				
				//Cuando se abre el teclado, hacer un scroll para que se vea en pantalla
				.onChange(of: isKeyboardFocused) { _, value in
					if value {
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
							withAnimation {
								scrollProxy.scrollTo(101010, anchor: .top)
							}
						}
					}
				}
				
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
		.onAppear(perform: subscribeToKeyboardNotifications)
		.onDisappear(perform: unsubscribeFromKeyboardNotifications)
		.alert(isPresented: $showAlert) {
			Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
		}
	}
	
	//Observers para cambiar el tamaño de la pantalla cuando abra el teclado
	private func subscribeToKeyboardNotifications() {
		NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
			withAnimation {
				self.keyboardHeight = 350
			}
		}
		
		NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
			withAnimation {
				self.keyboardHeight = 0
			}
		}
	}
	
	private func unsubscribeFromKeyboardNotifications() {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
}

#Preview {
	ViewSeccion(seccion: ListaSecciones().secciones[0])
}
