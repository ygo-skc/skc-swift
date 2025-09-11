//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct BanListNavigatorView: View {
    @Bindable var model: BannedContentViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            BanListFormatsView(chosenFormat: $model.chosenFormat)
            BanListDatesView(model: model)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct BanListFormatsView: View {
    @Binding var chosenFormat: BanListFormat
    
    @Namespace private var animation
    
    private static let formats: [BanListFormat] = [.tcg, .md]
    
    var body: some View {
        HStack(spacing: 20) {
            Text("Format")
                .font(.headline)
                .fontWeight(.bold)
            ForEach(BanListFormatsView.formats, id: \.rawValue) { format in
                TabButton(selected: $chosenFormat, value: format, animmation: animation)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

#Preview() {
    @Previewable @State var chosenFormat: BanListFormat = .tcg
    BanListFormatsView(chosenFormat: $chosenFormat)
        .padding(.horizontal)
}
