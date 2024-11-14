//
//  ViewFeedMenuItem.swift
//  PapaloteMenuLista
//
//  Created by Alumno on 04/11/24.
//

import SwiftUI

struct ViewFeedMenuItem: View {
    let article : FeedArticle
    
    var body: some View {
        ZStack {
            article.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 250, height: 300)
                .clipShape(
                    .rect(
                        topLeadingRadius: 30,
                        bottomLeadingRadius: 30,
                        bottomTrailingRadius: 30,
                        topTrailingRadius: 30
                    )
                )
                .clipped()
                .opacity(0.9)
            
            Color.black
                .frame(width: 250, height: 300)
                .cornerRadius(30)
                .opacity(0.4)
            
            VStack{
                HStack {
                    Text(article.title)
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .frame(maxWidth: 200)
                        .padding([.top, .leading])
                    Spacer()
                }
                
                Spacer()
                HStack{
                    Spacer()
                    Text("Leer")
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                    Image(systemName: "chevron.forward.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .foregroundStyle(.white)
                }
                .padding([.bottom, .trailing],20)
            }
                
        }
        .frame(width: 250, height: 300)
    }
}

#Preview {
    ViewFeedMenuItem(article: Feed.getArticles()[1])
}
