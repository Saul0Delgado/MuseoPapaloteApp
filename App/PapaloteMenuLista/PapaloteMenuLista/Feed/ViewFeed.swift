//
//  ViewFeed.swift
//  PapaloteMenuLista
//
//  Created by alumno on 04/11/24.
//

import SwiftUI

struct ViewFeed: View {
    @Environment(\.dismiss) var dismiss
    let article: FeedArticle
    let leftPadding : CGFloat = 25
    let wholeScreen = UIScreen.main.bounds.width
    
    var body: some View {
        ScrollView {
            HStack {
                ZStack {
                    VStack {
                        ZStack {
                            article.image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: wholeScreen, height: 200)
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 0,
                                        bottomLeadingRadius: 200,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 0
                                    )
                                )
                                .clipped()
                                .offset(x:5, y:-10)
                                .opacity(0.9)
                            
                            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.white]), startPoint: .top, endPoint: .bottom)
                                .frame(height:200)
                                .offset(x:5)
                        }
                        
                        Spacer()
                    }
                    VStack(alignment: .leading) {
                        Rectangle()
                            .foregroundStyle(Color.clear)
                            .frame(height: 120)
                        
                        Text(article.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 320, alignment: .leading)
                        
                        Text(article.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: 320, alignment: .leading)
                            .padding(.bottom, 10)
                        
                        ForEach(article.content.sorted(by: { $0.pos < $1.pos }), id: \.id) { item in
                            if let textContent = item as? TextContent {
                                Text(textContent.text)
                                    .font(.body)
                                    .frame(maxWidth: 320, alignment: .leading)
                                    .padding(.vertical, 5)
                            } else if let imageContent = item as? ImageContent {
                                imageContent.image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: wholeScreen-leftPadding*2)
                                    .cornerRadius(30)
                            }
                        }
                        .padding(.bottom,20)
                        
                        Rectangle()
                            .foregroundStyle(Color.clear)
                            .frame(height: 120)
                    }
                    .padding(.leading, leftPadding)
                }
                
                Spacer()
            }
        }
        .safeAreaInset(edge: .top) {
            PapaloteTopBar(color:Color.accent, type: .back)
        }
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
    ViewFeed(article: Feed.getArticles()[0])
}
