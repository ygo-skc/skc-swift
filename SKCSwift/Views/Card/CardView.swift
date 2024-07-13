//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct CardView: View {
    let cardID: String
    
    @State private var cardData: Card
    @State private var isDataLoaded = false
    
    init(cardID: String) {
        self.cardID = cardID
        self.cardData = Card(cardID: cardID, cardName: "", cardColor: "", cardAttribute: "", cardEffect: "")
    }
    
    private func fetchData() {
        if isDataLoaded {
            return
        }
        request(url: cardInfoURL(cardID: self.cardID)) { (result: Result<Card, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let card):
                    cardData = card
                    isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
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
                if (isDataLoaded) {
                    RelatedContentView(
                        cardName: cardData.cardName,
                        products: getProducts(),
                        tcgBanLists: getBanList(format: BanListFormat.tcg),
                        mdBanLists: getBanList(format: BanListFormat.md), dlBanLists: getBanList(format: BanListFormat.dl)
                    )
                    .padding(.horizontal)
                    CardSuggestionsView(cardID: cardID)
                        .padding(.horizontal)
                }
            }
            .task(priority: .high) {
                fetchData()
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
