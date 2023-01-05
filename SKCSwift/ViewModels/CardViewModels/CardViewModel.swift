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
    
    let screenWidth = UIScreen.main.bounds.width - 15
    let imageSize = UIScreen.main.bounds.width - 50
    private let imageUrl: URL
    
    init(cardId: String) {
        self.cardId = cardId
        self.imageUrl =  URL(string: "https://images.thesupremekingscastle.com/cards/original/\(cardId).jpg")!
    }
    
    var body: some View {
        ScrollView {
            VStack {
                RoundedRectImage(width: imageSize, height: imageSize, imageUrl: imageUrl)
                if (isDataLoaded) {
                    CardStatsViewModel(cardName: cardData.cardName, monsterType: cardData.monsterType, cardEffect: cardData.cardEffect, monsterAssociation: cardData.monsterAssociation, cardId: cardData.cardID, cardAttribute: cardData.cardAttribute)
                } else {
                    RectPlaceholderViewModel(width: screenWidth, height: 200, radius: 10)
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
            
            Button {
                showView.toggle()
            } label: {
                Text("Suggestions")
                    .font(.title3)
            }
            .sheet(isPresented: $showView) {
                Text("Yo")
            }
            
        }.frame(width: screenWidth)
    }
}

struct CardViewModel_Previews: PreviewProvider {
    static var previews: some View {
        CardViewModel(cardId: "90307498")
    }
}
