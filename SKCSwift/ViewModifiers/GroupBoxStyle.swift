//
//  GroupBoxStyle.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/9/24.
//

import SwiftUI

struct ListItemGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
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

struct FiltersGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
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
    func makeBody(configuration: Configuration) -> some View {
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
    static var list_item: ListItemGroupBoxStyle { .init() }
    static var filters: FiltersGroupBoxStyle { .init() }
    static var filtersSubGroup: FiltersSubGroupBoxStyle { .init() }
}
