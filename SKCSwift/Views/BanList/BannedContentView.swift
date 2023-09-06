//
//  BannedContent.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

import SwiftUI

struct BannedContent: View {
    @State private var format: BanListFormat = .tcg
    
    var body: some View {
        SegmentedView(mainContent: {
            Text("YOO")
        }) {
            VStack(alignment: .center, spacing: 20) {
                Capsule()
                    .fill(.gray.opacity(0.7))
                    .frame(width: 50, height: 5)
                    .padding(.top, 5)
                BanListFormatsView(selectedFormat: $format)
                BanListDatesView(format: $format)
            }
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: BottomSheetMinHeightPreferenceKey.self,
                    value: geometry.size.height
                )
            })
        }
    }
}

struct BannedContent_Previews: PreviewProvider {
    static var previews: some View {
        BannedContent()
    }
}
