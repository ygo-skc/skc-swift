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
    
    @State private var cardData: Card?
    
    private func fetchData() async {
        if cardData != nil {
            return
        }
        request(url: cardInfoURL(cardID: self.cardID), priority: 0.4) { (result: Result<Card, Error>) -> Void in
            switch result {
            case .success(let card):
                DispatchQueue.main.async {
                    cardData = card
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getProducts() -> [Product] {
        return cardData?.foundIn ?? [Product]()
    }
    
    private func getBanList(format: BanListFormat) -> [BanList] {
        switch format {
        case .tcg:
            return cardData?.restrictedIn?.TCG ?? [BanList]()
        case .md:
            return cardData?.restrictedIn?.MD ?? [BanList]()
        case .dl:
            return cardData?.restrictedIn?.DL ?? [BanList]()
        }
    }
    
    var body: some View {
        TabView {
            ScrollView {
                VStack(spacing: 30) {
                    YGOCardView(cardID: cardID, card: cardData)
                        .equatable()
                    if let cardData {
                        RelatedContentView(
                            cardName: cardData.cardName,
                            products: getProducts(),
                            tcgBanLists: getBanList(format: BanListFormat.tcg),
                            mdBanLists: getBanList(format: BanListFormat.md), dlBanLists: getBanList(format: BanListFormat.dl)
                        )
                        .padding(.bottom)
                        .modifier(ParentViewModifier())
                    }
                }
                .task(priority: .userInitiated) {
                    await fetchData()
                }
                .padding(.bottom, 30)
                .frame(maxHeight: .infinity)
            }
            .scrollIndicators(.hidden)
            
            ScrollView {
                LazyVStack(spacing: 30) {
                    CardSuggestionsView(cardID: cardID)
                }
                .padding(.bottom, 30)
                .modifier(ParentViewModifier())
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(cardID: "90307498")
    }
}
