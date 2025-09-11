//
//  BannedContent.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

import SwiftUI

struct BanListContentView: View {
    @State private var model = BannedContentViewModel()
    
    var body: some View {
        SegmentedView {
            Text("YOO")
        } sheetContent: {
            BanListNavigatorView(model: model)
        }
    }
}

#Preview() {
    BanListContentView()
}
