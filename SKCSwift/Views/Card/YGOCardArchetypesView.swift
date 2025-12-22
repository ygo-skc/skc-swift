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

struct YGOCardArchetypeView: View {
    @State private var model: ArchetypesViewModel
    
    init(archetype: String) {
        self.model = .init(archetype: archetype)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if model.dataDTS == .done {
                    CardListView(cards: model.data.usingName)
                }
            }
            .modifier(.parentView)
        }
        .gesture(DragGesture(minimumDistance: 0))
        .scrollDisabled(!model.hasContent)
        .navigationTitle(model.archetype)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await model.fetchArchetypeData()
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
}
