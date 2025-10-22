//
//  GroupBoxStyle.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/9/24.
//

import SwiftUI

fileprivate struct GroupBoxStyleConstants {
    static let CORNER_RADIUS: CGFloat = 12
    static let PADDING: CGFloat = 10
    
    static let BORDER_COLOR: Color = Color(UIColor.systemGray5).opacity(0.9)
}

struct ListItemGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .fontWeight(.semibold)
            configuration.content
        }
        .contentShape(Rectangle())
        .padding(.all, GroupBoxStyleConstants.PADDING)
        .background(Color(UIColor.systemBackground).mix(with: .white, by: 0.27), in: RoundedRectangle(cornerRadius: 12))
        .clipped()
        .shadow(color: Color(UIColor.systemGray5), radius: 2, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: GroupBoxStyleConstants.CORNER_RADIUS)
                .stroke(GroupBoxStyleConstants.BORDER_COLOR, lineWidth: 1)
        )
    }
}

struct SectionContentGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.content
        }
        .contentShape(Rectangle())
        .padding(.all, GroupBoxStyleConstants.PADDING)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .clipped()
        .overlay(
            RoundedRectangle(cornerRadius: GroupBoxStyleConstants.CORNER_RADIUS)
                .stroke(GroupBoxStyleConstants.BORDER_COLOR, lineWidth: 1)
        )
    }
}

struct FiltersGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .contentShape(Rectangle())
        .padding(.all, GroupBoxStyleConstants.PADDING)
        .background(.orange.opacity(0.35), in: RoundedRectangle(cornerRadius: GroupBoxStyleConstants.CORNER_RADIUS))
        .clipped()
        .overlay(
            RoundedRectangle(cornerRadius: GroupBoxStyleConstants.CORNER_RADIUS)
                .stroke(.orange.opacity(0.8), lineWidth: 1)
        )
    }
}

struct FiltersSubGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .contentShape(Rectangle())
        .padding(.all, GroupBoxStyleConstants.PADDING / 2)
        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: GroupBoxStyleConstants.CORNER_RADIUS))
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
