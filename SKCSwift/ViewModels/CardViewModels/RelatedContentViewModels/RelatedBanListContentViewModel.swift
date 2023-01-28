//
//  RelatedBanListsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/24/23.
//

import SwiftUI

struct RelatedBanListContentViewModel: RelatedContent {
    var cardName: String
    var banlists: [BanList]
    var format: BanListFormat
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Ban Lists: \(banlists.count)")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .padding(.top)
                Text("\(format.rawValue) Ban Lists \(cardName) Was In")
                    .font(.headline)
                    .fontWeight(.light)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                Divider()
                
                List {
                    ForEach(banlists, id: \.banListDate) { instance in
                        BanListItemViewModel(banListInstance: instance)
                    }
                }.listStyle(.plain)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
        }
    }
}

struct BanListItemViewModel: View {
    var banListInstance: BanList
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(banListInstance.banStatus)
                    .lineLimit(1)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                
                Circle()
                    .foregroundColor(banStatusColor(status: banListInstance.banStatus))
                    .frame(width: 30)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            DateViewModel(date: banListInstance.banListDate)
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
        
        RelatedBanListContentViewModel(cardName: "Elemental HERO Stratos", banlists: banLists, format: BanListFormat.tcg)
    }
}
