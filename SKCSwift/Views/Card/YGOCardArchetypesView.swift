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
    
    @State var isPopoverShown: Bool = false
    @State var selectedArchetype: String = ""
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading) {
                Label(title, systemImage: "apple.books.pages")
                    .font(.headline)
                    .fontWeight(.medium)
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 5) {
                        ForEach(Array(archetypes).sorted(), id: \.self) { archetype in
                            Button(archetype) {
                                selectedArchetype = archetype
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blueGray)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollClipDisabled()
            }
            .ygoNavigationDestination()
            .onChange(of: selectedArchetype) {
                if !selectedArchetype.isEmpty {
                    isPopoverShown.toggle()
                }
            }
            .onChange(of: isPopoverShown) {
                if !isPopoverShown {
                    selectedArchetype = ""
                }
            }
            .popover(isPresented: $isPopoverShown) {
                YGOCardArchetypesPopoverView(archetype: selectedArchetype,
                                             isPopoverShown: $isPopoverShown,
                                             path: $path)
                .equatable()
            }
        }
    }
}

private struct YGOCardArchetypesPopoverView: View, Equatable {
    static func == (lhs: YGOCardArchetypesPopoverView, rhs: YGOCardArchetypesPopoverView) -> Bool {
        lhs.archetype == rhs.archetype
    }
    
    let archetype: String
    @Binding var isPopoverShown: Bool
    @Binding var path: NavigationPath
    
    @State var suggestions: ArchetypeSuggestions = .init(usingName: [], usingText: [], exclusions: [])
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                Text("Archetype - \(archetype)")
                    .font(.title2)
                    .bold()
                
                ForEach(suggestions.usingName, id: \.cardID) { card in
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
        .gesture(DragGesture(minimumDistance: 0))
        .task {
            let res = await data(archetypeSuggestionsURL(archetype: archetype), resType: ArchetypeSuggestions.self)
            if case .success(let data) = res {
                suggestions = data
            }
        }
    }
}
