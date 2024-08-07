//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct CardLinkDestinationView: View {
    let cardLinkDestinationValue: CardLinkDestinationValue
    
    var body: some View {
        CardView(cardID: cardLinkDestinationValue.cardID)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(cardLinkDestinationValue.cardName)
    }
}

private struct CardView: View {
    let cardID: String
    
    @State private var cardData: Card
    @State private var isDataLoaded = false
    
    init(cardID: String) {
        self.cardID = cardID
        self.cardData = Card(cardID: cardID, cardName: "", cardColor: "", cardAttribute: "", cardEffect: "")
    }
    
    private func fetchData() async {
        if isDataLoaded {
            return
        }
        request(url: cardInfoURL(cardID: self.cardID), priority: 0.4) { (result: Result<Card, Error>) -> Void in
            switch result {
            case .success(let card):
                DispatchQueue.main.async {
                    cardData = card
                    isDataLoaded = true
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getProducts() -> [Product] {
        return cardData.foundIn ?? [Product]()
    }
    
    private func getBanList(format: BanListFormat) -> [BanList] {
        switch format {
        case .tcg:
            return cardData.restrictedIn?.TCG ?? [BanList]()
        case .md:
            return cardData.restrictedIn?.MD ?? [BanList]()
        case .dl:
            return cardData.restrictedIn?.DL ?? [BanList]()
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 30) {
                YGOCardView(card: cardData, isDataLoaded: isDataLoaded)
                    .equatable()
                if (isDataLoaded) {
                    Group {
                        RelatedContentView(
                            cardName: cardData.cardName,
                            products: getProducts(),
                            tcgBanLists: getBanList(format: BanListFormat.tcg),
                            mdBanLists: getBanList(format: BanListFormat.md), dlBanLists: getBanList(format: BanListFormat.dl)
                        )
                        CardSuggestionsView(cardID: cardID)
                    }
                    .modifier(ParentViewModifier())
                }
            }
            .task(priority: .userInitiated) {
                await fetchData()
            }
            .frame(maxHeight: .infinity)
        }
        .scrollIndicators(.hidden)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(cardID: "90307498")
    }
}
