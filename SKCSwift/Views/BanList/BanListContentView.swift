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
            Text(model.dateRangeIndex.description)
        } sheetContent: {
            BanListNavigatorView(format: $model.format, dateRangeIndex: $model.dateRangeIndex, dates: model.banListDates)
        }
        .onChange(of: model.format, initial: true) {
            Task {
                await model.fetchBanListDates()
            }
        }
    }
}

#Preview() {
    BanListContentView()
}
