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
    
    var body: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: "apple.books.pages")
                .font(.headline)
                .fontWeight(.medium)
            
            if archetypes.isEmpty {
                Text("Nothing to suggested based on your recent browsing history…")
                    .font(.subheadline)
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 5) {
                        ForEach(Array(archetypes).sorted(), id: \.self) { archetype in
                            NavigationLink(value: ArchetypeLinkDestinationValue(archetype: archetype), label: {
                                Text(archetype)
                            })
                            .buttonStyle(.borderedProminent)
                            .tint(.blueGray)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

struct YGOCardArchetypeView: View {
    @State private var model: ArchetypesViewModel
    
    init(archetype: String) {
        self.model = .init(archetype: archetype)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                if model.dataDTS == .done {
                    Text("Cards tied the the archetype \"\(model.archetype)\" and how they are tied")
                        .font(.subheadline)
                        .padding(.bottom, -20)
                    
                    YGOArchetypeSectionView(category: .byName, cards: model.data.usingName)
                    YGOArchetypeSectionView(category: .byText, cards: model.data.usingText)
                    YGOArchetypeSectionView(category: .exclusions, cards: model.data.exclusions)
                }
            }
            .modifier(.parentView)
            .navigationTitle(model.archetype)
            .navigationBarTitleDisplayMode(.large)
            .task {
                await model.fetchArchetypeData()
            }
        }
        .overlay {
            if model.dataDTS == .pending {
                ProgressView("Loading...")
                    .controlSize(.large)
            } else if let networkError = model.dataNE {
                if networkError == .notFound {
                    ContentUnavailableView("This suggested archetype is a false positive. We are actively improving our database.",
                                           systemImage: "exclamationmark.square.fill")
                } else {
                    NetworkErrorView(error: networkError, action: {
                        Task {
                            await model.fetchArchetypeData()
                        }
                    })
                }
            }
        }
    }
    
    private struct YGOArchetypeSectionView: View {
        let category: YGOArchetypeCategory
        let cards: [YGOCard]
        
        var body: some View {
            if !cards.isEmpty {
                VStack(alignment: .leading) {
                    NavigationLink {
                        YGOArchetypeCategoryView(category: category, cards: cards)
                    } label: {
                        HStack {
                            Text(category.rawValue)
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    CardListView(cards: Array(cards.prefix(5)))
                }
            }
        }
    }
    
    private struct YGOArchetypeCategoryView: View {
        let category: YGOArchetypeCategory
        let cards: [YGOCard]
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    CardListView(cards: cards)
                }
                .modifier(.parentView)
                .navigationTitle(category.rawValue)
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}

private enum YGOArchetypeCategory: String {
    case byName = "By Name", byText = "By Text", exclusions = "Exclusions"
}
