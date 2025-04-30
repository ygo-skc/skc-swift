//
//  GroupBoxStyle.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/9/24.
//

import SwiftUI

struct ListItemGroupBoxStyle: GroupBoxStyle {
    nonisolated func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .fontWeight(.semibold)
            configuration.content
        }
        .contentShape(Rectangle())
        .padding(.all, 10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct SectionContentGroupBoxStyle: GroupBoxStyle {
    nonisolated func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.content
        }
        .contentShape(Rectangle())
        .padding(.all, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct FiltersGroupBoxStyle: GroupBoxStyle {
    nonisolated func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .contentShape(Rectangle())
        .padding(.all, 10)
        .background(.orange.opacity(0.35), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct FiltersSubGroupBoxStyle: GroupBoxStyle {
    nonisolated func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .contentShape(Rectangle())
        .padding(.all, 6)
        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 6))
    }
}

extension GroupBoxStyle where Self == ListItemGroupBoxStyle {
    static var listItem: ListItemGroupBoxStyle { .init() }
}

extension GroupBoxStyle where Self == SectionContentGroupBoxStyle {
    static var sectionContent: SectionContentGroupBoxStyle { .init() }
}

extension GroupBoxStyle where Self == FiltersGroupBoxStyle {
    static var filters: FiltersGroupBoxStyle { .init() }
}

extension GroupBoxStyle where Self == FiltersSubGroupBoxStyle {
    static var filtersSubGroup: FiltersSubGroupBoxStyle { .init() }
}
