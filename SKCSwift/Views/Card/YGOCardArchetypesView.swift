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
    @State var model = ArchetypesViewModel()
    
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
                                Task {
                                    isPopoverShown.toggle()
                                    await model.fetchArchetypeData(archetype: archetype)
                                }
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
            .popover(isPresented: $isPopoverShown) {
                YGOCardArchetypesPopoverView(archetype: model.archetype,
                                             archetypeData: model.data,
                                             dts: model.dataDTS,
                                             ne: model.dataNE,
                                             retryCB: { archetype in
                    await model.fetchArchetypeData(archetype: archetype)
                }, isPopoverShown: $isPopoverShown, path: $path)
            }
        }
    }
}

private struct YGOCardArchetypesPopoverView: View, Equatable {
    static func == (lhs: YGOCardArchetypesPopoverView, rhs: YGOCardArchetypesPopoverView) -> Bool {
        lhs.dts == rhs.dts && lhs.archetype == rhs.archetype
    }
    
    let archetype: String
    let archetypeData: ArchetypeData
    let dts: DataTaskStatus
    let ne: NetworkError?
    let retryCB: (String) async -> Void
    @Binding var isPopoverShown: Bool
    @Binding var path: NavigationPath
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if dts == .done {
                    Text("Archetype - \(archetype)")
                        .font(.title2)
                        .bold()
                    CardListView(cards: archetypeData.usingName, path: $path) {
                        isPopoverShown = false
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .modifier(.parentView)
        }
        .gesture(DragGesture(minimumDistance: 0))
        .overlay {
            if dts == .pending {
                ProgressView("Loading...")
                    .controlSize(.large)
            } else if let networkError = ne {
                NetworkErrorView(error: networkError, action: {
                    Task {
                        await retryCB(archetype)
                    }
                })
            }
        }
    }
}
