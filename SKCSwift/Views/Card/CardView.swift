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
    let cardViewModel = CardViewModel()
    
    var body: some View {
        if cardViewModel.error != nil {
            ContentUnavailableView("Could not fetch content", systemImage: "network.slash", description: Text("Please try again later"))
        } else {
            TabView {
                ScrollView {
                    YGOCardView(cardID: cardID, card: cardViewModel.card)
                        .equatable()
                        .padding(.bottom)
                    
                    if let card = cardViewModel.card {
                        RelatedContentView(
                            cardName: card.cardName,
                            cardColor: card.cardColor,
                            products: cardViewModel.getProducts(),
                            tcgBanLists: cardViewModel.getBanList(format: BanListFormat.tcg),
                            mdBanLists: cardViewModel.getBanList(format: BanListFormat.md),
                            dlBanLists: cardViewModel.getBanList(format: BanListFormat.dl)
                        )
                        .modifier(ParentViewModifier())
                        .padding(.bottom, 50)
                    }
                }
                .task(priority: .userInitiated) {
                    await cardViewModel.fetchData(cardID: cardID)
                }
                
                ScrollView {
                    CardSuggestionsView(cardID: cardID, cardName: cardViewModel.card?.cardName)
                        .padding(.bottom, 30)
                        .modifier(ParentViewModifier())
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(cardID: "90307498")
    }
}
