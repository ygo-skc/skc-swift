//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI
import SwiftData

struct CardLinkDestinationView: View {
    let cardLinkDestinationValue: CardLinkDestinationValue
    
    var body: some View {
        CardView(cardID: cardLinkDestinationValue.cardID)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(cardLinkDestinationValue.cardName)
    }
}

private struct CardView: View {
    @Environment(\.modelContext) var modelContext
    
    @State private var model: CardViewModel
    
    @Query
    private var history: [History]
    
    init(cardID: String) {
        self.model = .init(cardID: cardID)
        
        let predicate = #Predicate<History> { h in
            h.id == cardID
        }
        
        _history = Query(filter: predicate, sort: [SortDescriptor(\.timesAccessed, order: .reverse)])
    }
    
    var body: some View {
        VStack {
            if model.requestErrors[.card, default: nil] == nil {
                TabView {
                    Tab("Info", systemImage: "info.circle.fill") {
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
                                    mdBanLists: card.getBanList(format: BanListFormat.md)
                                )
                                .modifier(ParentViewModifier())
                                .padding(.bottom, 50)
                            } else {
                                ProgressView("Loading...")
                                    .controlSize(.large)
                            }
                        }
                    }
                    
                    Tab("Suggestions", systemImage: "sparkles") {
                        ScrollView {
                            CardSuggestionsView(model: model)
                                .modifier(ParentViewModifier(alignment: .center))
                                .padding(.bottom, 30)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity)
        .overlay {
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
            }
        }
        .task {
            await model.fetchCardData()
        }
        .toolbar {
            if model.requestErrors[.card, default: nil] == nil {
                Button {
                    //                    modelContext.insert(Favorite(resource: .card, id: model.cardID))
                    try! modelContext.delete(model: History.self, where: #Predicate { f in
                        f.id == "82570174"
                    })
                } label: {
                    Image(systemName: "heart")
                }
            }
        }
        .onChange(of: model.card) {
            Task {
                /*
                 If no history, create new instance in table
                 Else if there is at least one history record for card, update the last modified date and access time for the first record
                 */
                if history.isEmpty {
                    modelContext.insert(History(resource: .card, id: model.cardID, timesAccessed: 1))
                } else if let h1 = history.first, h1.lastAccessDate.timeIntervalSinceNow(millisConversion: .seconds) >= 3 {
                    h1.updateAccess()
                }
                
                History.consolidate(history: history, modelContext: modelContext)
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
