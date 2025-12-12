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
                LazyHStack(spacing: 10) {
                    ForEach(Array(archetypes), id: \.self) { archetype in
                        Button(archetype) {
                            
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.container)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
        }
    }
}
