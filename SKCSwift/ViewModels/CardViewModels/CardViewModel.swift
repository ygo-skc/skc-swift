//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

private class CardInformationViewModel: ObservableObject {
    @Published private(set) var cardData = Card(cardID: "", cardName: "", cardColor: "", cardAttribute: "", cardEffect: "", monsterType: "")
    @Published private(set) var isDataLoaded = false
    
    func fetchData(cardId: String) {
        getCardData(cardId: cardId, {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let card):
                    self.cardData = card
                    self.isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            }
        })
    }
    
    func getProducts() -> [Product] {
        return cardData.foundIn ?? [Product]()
    }
    
    func getBanList(format: BanListFormat) -> [BanList] {
        switch format {
        case .tcg:
            return cardData.restrictedIn?.TCG ?? [BanList]()
        case .md:
            return cardData.restrictedIn?.MD ?? [BanList]()
        case .dl:
            return cardData.restrictedIn?.DL ?? [BanList]()
        }
    }
}

private class CardSuggestionInformationViewModel: ObservableObject {
    @Published private(set) var hasSelfReference: Bool = false
    @Published private(set) var namedMaterials: [CardReference] = [CardReference]()
    @Published private(set) var namedReferences: [CardReference] = [CardReference]()
    @Published private(set) var isDataLoaded = false
    
    
    func fetchData(cardId: String) {
        getCardSuggestionsTask(cardId: cardId, {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let suggestions):
                    self.hasSelfReference = suggestions.hasSelfReference
                    self.namedMaterials = suggestions.namedMaterials
                    self.namedReferences = suggestions.namedReferences
                    
                    self.isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            }
        })
    }
}

struct CardViewModel: View {
    var cardId: String
    
    @StateObject private var cardInformation = CardInformationViewModel()
    @StateObject private var cardSuggestions = CardSuggestionInformationViewModel()
    
    private let imageSize = UIScreen.main.bounds.width - 60
    private let imageUrl: URL
    
    init(cardId: String) {
        self.cardId = cardId
        self.imageUrl =  URL(string: "https://images.thesupremekingscastle.com/cards/lg/\(cardId).jpg")!
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                RoundedRectImage(width: imageSize, height: imageSize, imageUrl: imageUrl)
                if (cardInformation.isDataLoaded) {
                    CardStatsViewModel(
                        cardName: cardInformation.cardData.cardName, cardColor: cardInformation.cardData.cardColor, monsterType: cardInformation.cardData.monsterType,
                        cardEffect: cardInformation.cardData.cardEffect, monsterAssociation: cardInformation.cardData.monsterAssociation,
                        cardId: cardInformation.cardData.cardID, cardAttribute: cardInformation.cardData.cardAttribute,
                        monsterAttack: cardInformation.cardData.monsterAttack, monsterDefense: cardInformation.cardData.monsterDefense
                    )
                    
                    CardSuggestionsViewModel(namedMaterials: cardSuggestions.namedMaterials, namedReferences: cardSuggestions.namedReferences, isDataLoaded: cardSuggestions.isDataLoaded)
                    
                    RelatedContentViewModel(
                        cardName: cardInformation.cardData.cardName, products: cardInformation.getProducts(), tcgBanLists: cardInformation.getBanList(format: BanListFormat.tcg),
                        mdBanLists: cardInformation.getBanList(format: BanListFormat.md), dlBanLists: cardInformation.getBanList(format: BanListFormat.dl)
                    )
                } else {
                    RectPlaceholderViewModel(width: .infinity, height: 200, radius: 10)
                }
            }
            .padding(.horizontal, 5)
            .onAppear {
                cardInformation.fetchData(cardId: cardId)
                cardSuggestions.fetchData(cardId: cardId)
            }
            .frame(maxHeight: .infinity)
        }
    }
}

struct CardViewModel_Previews: PreviewProvider {
    static var previews: some View {
        CardViewModel(cardId: "90307498")
    }
}
