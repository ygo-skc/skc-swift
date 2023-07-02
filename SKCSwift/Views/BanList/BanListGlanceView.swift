//
//  BanListGlanceView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/1/23.
//

import SwiftUI

struct BanListGlanceView: View {
    @State private var format: BanListFormat = .tcg
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Capsule()
                .fill(.gray.opacity(0.7))
                .frame(width: 50, height: 5)
                .padding(.top, 5)
            BanListFormatsView(selectedFormat: $format)
            BanListDatesView(format: $format)
        }
        .frame(alignment: .topLeading)
        .padding(.horizontal)
        .background(GeometryReader { geometry in
            Color.clear.preference(
                key: BanListDatesBottomViewMinHeightPreferenceKey.self,
                value: geometry.size.height
            )
        })
    }
}

struct BanListGlanceView_Previews: PreviewProvider {
    static var previews: some View {
        BanListGlanceView()
    }
}
