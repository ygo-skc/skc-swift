//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct BanListNavigatorView: View {
    @Binding var format: BanListFormat
    @Binding var dateRangeIndex: Int
    var dates: [BanListDate]
    
    var body: some View {
        VStack(spacing: 10) {
            BanListFormatsView(format: $format)
            BanListDatesView(dateRangeIndex: $dateRangeIndex, dates: dates)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct BanListFormatsView: View {
    @Binding var format: BanListFormat
    
    @Namespace private var animation
    
    private static let formats: [BanListFormat] = [.tcg, .md]
    
    var body: some View {
        HStack(spacing: 20) {
            Text("Format")
                .font(.headline)
                .fontWeight(.bold)
            ForEach(BanListFormatsView.formats, id: \.rawValue) { format in
                TabButton(selected: $format, value: format, animmation: animation)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

#Preview() {
    @Previewable @State var chosenFormat: BanListFormat = .tcg
    BanListFormatsView(format: $chosenFormat)
        .padding(.horizontal)
}
