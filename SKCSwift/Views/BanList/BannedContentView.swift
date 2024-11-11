//
//  BannedContent.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

import SwiftUI

struct BannedContent: View {
    private var model = BannedContentViewModel()
    
    var body: some View {
        SegmentedView(mainContent: {
            Text("YOO")
        }) {
            BanListOptionsView(model: model)
        }
    }
}

struct BannedContent_Previews: PreviewProvider {
    static var previews: some View {
        BannedContent()
    }
}
