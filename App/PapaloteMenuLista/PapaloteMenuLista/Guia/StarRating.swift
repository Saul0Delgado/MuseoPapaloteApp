//
//  StarRating.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 16/10/24.
//

import SwiftUI

struct StarRating: View {
	@Binding var rating: Int
	
	var maximumRating = 5
	
	var offImage = Image(systemName: "star")
	var onImage = Image(systemName: "star.fill")
	
	func image(for number: Int) -> Image {
		if number > rating {
			offImage
		} else {
			onImage
		}
	}
	
	var body: some View {
		HStack {
			ForEach(1..<maximumRating + 1, id: \.self) { number in
				Button {
					rating = number
				} label: {
					image(for: number)
						.resizable()
						.scaledToFit()
						.frame(width:35)
						.foregroundStyle(.white)
				}
				.buttonStyle(PlainButtonStyle())
			}
		}
	}
}


#Preview {
	@Previewable @State var num = 0
	StarRating(rating: $num)
}
