//
//  BannedContent.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

import SwiftUI

struct BannedContent: View {
    @State private var chosenFormat: BanListFormat = .tcg
    @State private var chosenDateRange: Int = 0
    @State private var banListDates = [BanListDate]()
    
    var body: some View {
        SegmentedView(mainContent: {
            Text("YOO")
        }) {
            BanListOptionsView(chosenFormat: $chosenFormat, chosenDateRange: $chosenDateRange, banListDates: $banListDates)
        }
    }
}

struct BannedContent_Previews: PreviewProvider {
    static var previews: some View {
        BannedContent()
    }
}
