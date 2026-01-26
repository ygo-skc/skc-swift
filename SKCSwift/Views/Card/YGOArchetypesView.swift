//
//  YGOArchetypesView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 12/11/25.
//
import SwiftUI

struct YGOArchetypesView: View {
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
                            NavigationLink(value: YGOArchetypeLinkDestinationValue(archetype: archetype), label: {
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

struct YGOArchetypeView: View {
    @State private var model: ArchetypesViewModel
    
    init(archetype: String) {
        self.model = .init(archetype: archetype)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                if model.dataDTS == .done {
                    Text("Cards tied to the **\(model.archetype)** archetype")
                        .font(.callout)
                        .padding(.bottom, -20)
                    
                    YGOArchetypeSectionView(archetype: model.archetype, category: .byName, cards: model.data.usingName)
                    YGOArchetypeSectionView(archetype: model.archetype, category: .byText, cards: model.data.usingText)
                    YGOArchetypeSectionView(archetype: model.archetype, category: .exclusions, cards: model.data.exclusions)
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
        let archetype: String
        let category: YGOArchetypeCategory
        let categorySystemImage: String
        let cards: [YGOCard]
        
        init(archetype: String, category: YGOArchetypeCategory, cards: [YGOCard]) {
            self.archetype = archetype
            self.category = category
            self.categorySystemImage = switch (category) {
            case .byName: "person.crop.circle"
            case .byText: "text.document"
            case .exclusions: "xmark.circle"
            }
            self.cards = cards
        }
        
        var body: some View {
            if !cards.isEmpty {
                VStack(alignment: .leading) {
                    NavigationLink(value: YGOArchetypeCategoryLinkDestinationValue(archetype: archetype, category: category, cards: cards)) {
                        HStack {
                            Label("\(category.rawValue) • \(cards.count)", systemImage: categorySystemImage)
                                .font(.headline)
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
}

enum YGOArchetypeCategory: String {
    case byName = "By Name", byText = "By Text", exclusions = "Exclusions"
}

struct YGOArchetypeCategoryView: View {
    let category: YGOArchetypeCategory
    let categoryExplanation: String
    let cards: [YGOCard]
    
    init(values: YGOArchetypeCategoryLinkDestinationValue) {
        self.category = values.category
        self.categoryExplanation = switch (values.category) {
        case .byName: "The cards below are part of the **\(values.archetype)** archetype because the archetype is found in the name of the card verbatim"
        case .byText: "The cards below are part of the **\(values.archetype)** archetype because the text box explicitly denotes them as such"
        case .exclusions: "The cards below are not part of the **\(values.archetype)** archetype because the text box explicitly excludes them"
        }
        self.cards = values.cards
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Label(LocalizedStringKey(categoryExplanation), systemImage: "info.circle")
                    .font(.callout)
                    .padding(.bottom)
                CardListView(cards: cards)
            }
            .modifier(.parentView)
            .navigationTitle(category.rawValue)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
