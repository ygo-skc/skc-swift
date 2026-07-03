//
//  LoadingView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/2/26.
//

import SwiftUI

struct LoadingView: View {
    private let label: String
    
    init(_ label: String = "Loading…") {
        self.label = label
    }
    
    var body: some View {
        ProgressView(label)
            .controlSize(.large)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .modify { view in
                if #available(iOS 26, *) {
                    view.glassEffect(in: .rect(cornerRadius: 16))
                } else {
                    view.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
    }
}

#Preview("Loading") {
    LoadingView()
}

#Preview("Custom Label") {
    LoadingView("Deleting…")
}
