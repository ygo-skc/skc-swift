//
//  BanListFormats.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/1/23.
//

import SwiftUI

struct BanListFormatsView: View {
    @Binding var selectedFormat: BanListFormat
    
    @Namespace private var animation
    
    private static let formats: [BanListFormat] = [.tcg, .md, .dl]
    
    var body: some View {
        HStack {
            Text("Format")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .padding(.trailing)
            ForEach(BanListFormatsView.formats, id: \.rawValue) { format in
                TabButton(selected: $selectedFormat, value: format, animmation: animation)
                if BanListFormatsView.formats.last != format {
                    Spacer()
                }
            }
        }
    }
}

struct BanListFormatsView_Previews: PreviewProvider {
    static var previews: some View {
        @State var selectedFormat: BanListFormat = .tcg
        BanListFormatsView(selectedFormat: $selectedFormat)
    }
}
