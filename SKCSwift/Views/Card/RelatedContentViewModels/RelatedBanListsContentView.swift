//
//  RelatedBanListsContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/24/23.
//

import SwiftUI

struct RelatedBanListsContentView: RelatedContent {
    var cardName: String
    var banlists: [BanList]
    var format: BanListFormat
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Ban Lists: \(banlists.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .padding(.top)
                    Text("\(format.rawValue) Ban Lists \(cardName) Was In")
                        .font(.headline)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                })
            }
            .padding(.horizontal)
            
            List {
                ForEach(banlists, id: \.banListDate) { instance in
                    BanListItemViewModel(banListInstance: instance)
                }
            }
            .listStyle(.plain)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

private struct BanListItemViewModel: View {
    var banListInstance: BanList
    
    var body: some View {
        HStack(spacing: 5) {
            CalendarDateView(date: banListInstance.banListDate, variant: .condensed)
                .padding(.trailing, 10)
            Circle()
                .foregroundColor(banStatusColor(status: banListInstance.banStatus))
                .frame(width: 20)
            Text(banListInstance.banStatus)
                .lineLimit(1)
                .font(.subheadline)
                .fontWeight(.heavy)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

struct RelatedBanListContentViewModel_Previews: PreviewProvider {
    static var previews: some View {
        let banLists = [
            BanList(banListDate: "2019-07-15", cardID: "40044918", banStatus: "Semi-Limited", format: "TCG"),
            BanList(banListDate: "2019-04-29", cardID: "40044918", banStatus: "Limited", format: "TCG")
        ]
        
        RelatedBanListsContentView(cardName: "Elemental HERO Stratos", banlists: banLists, format: BanListFormat.tcg)
    }
}
