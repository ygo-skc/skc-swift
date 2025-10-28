//
//  View.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/22/23.
//

import SwiftUI

extension View {
    func ygoNavigationDestination() -> some View {
        self.navigationDestination(for: CardLinkDestinationValue.self) { card in
            CardLinkDestinationView(cardLinkDestinationValue: card)
        }
        .navigationDestination(for: ProductLinkDestinationValue.self) { product in
            ProductLinkDestinationView(productLinkDestinationValue: product)
        }
    }
    
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
    
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        return modifier(self)
    }
}
