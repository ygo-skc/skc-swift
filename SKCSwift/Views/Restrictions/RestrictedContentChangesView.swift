//
//  RestrictedContentChangesView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 3/25/26.
//
import SwiftUI

struct RestrictedContentChangesView: View {
    @State private var model: RestrictedContentChangesViewModel
    
    init(values: RestrictedContentChangesLinkDestinationValue) {
        self.model = RestrictedContentChangesViewModel(effectiveDate: values.effectiveDate, format: values.format)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                newContent
            }
            .modifier(.parentView)
        }
        .frame(maxWidth: .infinity) // needed by overlay
        .task {
            await model.fetchNewContent()
        }
        .scrollDisabled(model.newContentDTS == .pending)
        .overlay {
            overlay
        }
        .navigationTitle("Changes")
    }
    
    @ViewBuilder
    private var newContent: some View {
        if model.newContentDTS == .done, let newContent = model.newContent {
            if !newContent.forbidden.isEmpty {
                VStack(alignment: .leading) {
                    Label("Newly forbidden", systemImage: "x.circle.fill")
                        .font(.headline)
                        .fontWeight(.medium)
                    CardListView(cards: newContent.forbidden.map({$0.card}), showAllInfo: true)
                }
            }
            
            if !newContent.limited.isEmpty {
                VStack(alignment: .leading) {
                    Label("Newly limited", systemImage: "1.circle.fill")
                        .font(.headline)
                        .fontWeight(.medium)
                    CardListView(cards: newContent.limited.map({$0.card}), showAllInfo: true)
                }
            }
            
            if !newContent.semiLimited.isEmpty {
                VStack(alignment: .leading) {
                    Label("Newly semi-limited", systemImage: "2.circle.fill")
                        .font(.headline)
                        .fontWeight(.medium)
                    CardListView(cards: newContent.semiLimited.map({$0.card}), showAllInfo: true)
                }
            }
        }
    }
    
    @ViewBuilder
    private var overlay: some View {
        if model.newContentDTS == .pending {
            ProgressView("Loading…")
                .controlSize(.large)
        } else if let e = model.newContentNE {
            NetworkErrorView(error: e) {
                Task {
                    await model.fetchNewContent()
                }
            }
        }
    }
}
