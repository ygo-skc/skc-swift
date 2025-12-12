//
//  YGOCardArchetypesView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 12/11/25.
//
import SwiftUI

struct YGOCardArchetypesView: View {
    let title: String
    let archetypes: Set<String>
    
    @State private var path = NavigationPath()
    @State var archetypeData: ArchetypeSuggestions = .init(usingName: [], usingText: [], exclusions: [])
    @State var isPopoverShown: Bool = false
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading) {
                Label(title, systemImage: "apple.books.pages")
                    .font(.headline)
                    .fontWeight(.medium)
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 10) {
                        ForEach(Array(archetypes).sorted(), id: \.self) { archetype in
                            Button(archetype) {
                                Task {
                                    isPopoverShown.toggle()
                                    let res = await data(archetypeSuggestionsURL(archetype: archetype), resType: ArchetypeSuggestions.self)
                                    if case .success(let data) = res {
                                        archetypeData = data
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.container)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollClipDisabled()
            }
            .ygoNavigationDestination()
            .popover(isPresented: $isPopoverShown) {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        Text("Archetype Suggestions")
                            .font(.title2)
                            .bold()
                        
                        ForEach(archetypeData.usingName, id: \.cardID) { card in
                            Button {
                                isPopoverShown = false
                                path.append(CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName))
                            } label: {
                                GroupBox() {
                                    CardListItemView(card: card)
                                        .equatable()
                                }
                                .groupBoxStyle(.listItem)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
        }
    }
}
