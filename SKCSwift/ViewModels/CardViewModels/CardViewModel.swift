//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct CardViewModel: View {
    var cardId: String
    
    @State private var cardData = Card(cardID: "", cardName: "", cardColor: "", cardAttribute: "", cardEffect: "", monsterType: "")
    @State private var showView = false
    @State private var isDataLoaded = false
    
    private let screenWidth = UIScreen.main.bounds.width - 15
    private let imageSize = UIScreen.main.bounds.width - 60
    private let imageUrl: URL
    
    init(cardId: String) {
        self.cardId = cardId
        self.imageUrl =  URL(string: "https://images.thesupremekingscastle.com/cards/lg/\(cardId).jpg")!
    }
    
    var body: some View {
        ScrollView {
            VStack {
                RoundedRectImage(width: imageSize, height: imageSize, imageUrl: imageUrl)
                if (isDataLoaded) {
                    CardStatsViewModel(
                        cardName: cardData.cardName, monsterType: cardData.monsterType, cardEffect: cardData.cardEffect, monsterAssociation: cardData.monsterAssociation,
                        cardId: cardData.cardID, cardAttribute: cardData.cardAttribute
                    )
                } else {
                    RectPlaceholderViewModel(width: screenWidth, height: 200, radius: 10)
                }
                
                
                Button {
                    showView.toggle()
                } label: {
                    Text("Products")
                        .font(.title3)
                }
                .sheet(isPresented: $showView) {
                    RelatedProductsContentViewModels(cardName: cardData.cardName, products: cardData.foundIn ?? [Product]())
                }
                
                Button {
                    showView.toggle()
                } label: {
                    Text("Ban Lists")
                        .font(.title3)
                }
                .sheet(isPresented: $showView) {
                }
            }
            .onAppear {
                getCardData(cardId: cardId, {result in
                    switch result {
                    case .success(let card):
                        self.cardData = card
                        self.isDataLoaded = true
                    case .failure(let error):
                        print(error)
                    }
                })
            }
        }.frame(width: screenWidth)
    }
}

struct CardViewModel_Previews: PreviewProvider {
    static var previews: some View {
        CardViewModel(cardId: "90307498")
    }
}
