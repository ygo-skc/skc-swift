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

extension GroupBoxStyle where Self == ListItemGroupBoxStyle {
    static var trending: ListItemGroupBoxStyle { .init() }
}
