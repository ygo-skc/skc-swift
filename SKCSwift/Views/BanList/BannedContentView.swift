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
            VStack {
                BanListFormatsView(selectedFormat: $format)
                BanListDatesView(format: $format)
            }
        }
    }
}

struct BannedContent_Previews: PreviewProvider {
    static var previews: some View {
        BannedContent()
    }
}
