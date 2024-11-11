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
    private let model: CardViewModel
    
    init(cardID: String) {
        self.model = .init(cardID: cardID)
    }
    
    var body: some View {
        if let networkError = model.requestErrors[.card, default: nil] {
            switch networkError {
            case .badRequest, .unprocessableEntity:
                ContentUnavailableView("Card not currently supported",
                                       systemImage: "exclamationmark.square.fill",
                                       description: Text("Please check back later"))
            default:
                NetworkErrorView(error: networkError, action: {
                    Task {
                        await model.fetchCardData(forceRefresh: true)
                    }
                })
            }
        } else {
            TabView {
                ScrollView {
                    YGOCardView(cardID: model.cardID, card: model.card)
                        .equatable()
                        .padding(.bottom)
                    
                    if let card = model.card {
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
                    CardSuggestionsView(model: model)
                        .modifier(ParentViewModifier(alignment: .center))
                        .padding(.bottom, 30)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .task(priority: .userInitiated) {
                await model.fetchCardData()
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
