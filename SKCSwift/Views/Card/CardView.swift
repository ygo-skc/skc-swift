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
        if cardData == nil, let card = try? await data(Card.self, url: cardInfoURL(cardID: self.cardID)) {
            DispatchQueue.main.async {
                cardData = card
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
                VStack {
                    YGOCardView(cardID: cardID, card: cardData)
                        .equatable()
                        .padding(.bottom)
                    
                    if let cardData {
                        RelatedContentView(
                            cardName: cardData.cardName,
                            cardColor: cardData.cardColor,
                            products: getProducts(),
                            tcgBanLists: getBanList(format: BanListFormat.tcg),
                            mdBanLists: getBanList(format: BanListFormat.md), dlBanLists: getBanList(format: BanListFormat.dl)
                        )
                        .modifier(ParentViewModifier())
                    }
                }
                .task(priority: .userInitiated) {
                    await fetchData()
                }
                .padding(.bottom, 40)
                .frame(maxHeight: .infinity)
            }
            
            ScrollView {
                VStack {
                    if let cardData {
                        CardSuggestionsView(cardID: cardID, cardName: cardData.cardName)
                    } else {
                        ProgressView()
                    }
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
