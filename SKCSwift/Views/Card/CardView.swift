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
    private let cardViewModel = CardViewModel()
    
    var body: some View {
        if let error = cardViewModel.error {
            switch error {
            case .badRequest:
                ContentUnavailableView("Card not currently supported",
                                       systemImage: "exclamationmark.square.fill",
                                       description: Text("Please check back later"))
            default:
                ContentUnavailableView {
                    Label("Could not fetch content", systemImage: "network.slash")
                } description: {
                    Button(action: { cardViewModel.error = nil }) {
                        Label("Retry", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
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
                            products: card.getProducts(),
                            tcgBanLists: card.getBanList(format: BanListFormat.tcg),
                            mdBanLists: card.getBanList(format: BanListFormat.md),
                            dlBanLists: card.getBanList(format: BanListFormat.dl)
                        )
                        .modifier(ParentViewModifier())
                        .padding(.bottom, 50)
                    } else {
                        ProgressView("Loading...")
                            .controlSize(.large)
                    }
                }
                
                ScrollView {
                    CardSuggestionsView(cardID: cardID, cardName: cardViewModel.card?.cardName)
                        .modifier(ParentViewModifier(alignment: .center))
                        .padding(.bottom, 30)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .task(priority: .userInitiated) {
                await cardViewModel.fetchData(cardID: cardID)
            }
        }
    }
}

#Preview("Kluger")  {
    CardView(cardID: "90307498")
}

#Preview("Token")  {
    CardView(cardID: "0034")
}

#Preview("Card DNE")  {
    CardView(cardID: "12345678")
}
