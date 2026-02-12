//
//  ParentViewModifier.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/26/24.
//

import SwiftUI

struct ContainerConstants {
    static let CORNER_RADIUS: CGFloat = 12
}

struct ParentViewModifier: ViewModifier {
    let alignment: Alignment
    
    func body(content: Content) -> some View {
        content
            .frame(alignment: alignment)
            .safeAreaPadding(.horizontal)
    }
}

struct SheetParentViewModifier: ViewModifier {
    let alignment: Alignment
    
    func body(content: Content) -> some View {
        content
            .frame(alignment: alignment)
            .presentationDragIndicator(.visible)
            .safeAreaPadding(.horizontal)
            .safeAreaPadding(.top)
    }
}

struct CardViewModifier: ViewModifier {
    let hasShadow: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: ContainerConstants.CORNER_RADIUS)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: ContainerConstants.CORNER_RADIUS)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 1)
            )
            .clipped()
            .if(hasShadow) { $0.shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 2) }
    }
}

extension ViewModifier where Self == ParentViewModifier {
    static var parentView: ParentViewModifier { .init(alignment: .topLeading) }
    static var sheetParentView: SheetParentViewModifier { .init(alignment: .topLeading) }
    static var centeredParentView: ParentViewModifier { .init(alignment: .center) }
}

extension ViewModifier where Self == CardViewModifier {
    static var card: CardViewModifier { .init(hasShadow: true) }
    static var cardNoShadow: CardViewModifier { .init(hasShadow: false) }
}
