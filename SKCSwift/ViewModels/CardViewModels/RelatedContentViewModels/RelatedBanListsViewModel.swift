//
//  RelatedBanListsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/27/23.
//

import SwiftUI

struct RelatedBanListsViewModel: View {
    var cardName: String
    var tcgBanLists: [BanList]
    var mdBanLists: [BanList]
    var dlBanLists: [BanList]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Ban Lists")
                .font(.title2)
            
            CardViewButton(text: "TCG", sheetContents: RelatedBanListContentViewModel(cardName: cardName, banlists: tcgBanLists, format: BanListFormat.tcg))
                .disabled(self.tcgBanLists.isEmpty)
            HStack {
                Text("\(self.tcgBanLists.count)")
                    .font(.body)
                    .fontWeight(.bold)
                Text("Occurences(s)")
                    .font(.body)
                    .fontWeight(.light)
                    .padding(.leading, -5)
            }
            
            
            CardViewButton(text: "Master Duel", sheetContents: RelatedBanListContentViewModel(cardName: cardName, banlists: mdBanLists, format: BanListFormat.md))
            HStack {
                Text("\(self.mdBanLists.count)")
                    .font(.body)
                    .fontWeight(.bold)
                Text("Occurences(s)")
                    .font(.body)
                    .fontWeight(.light)
                    .padding(.leading, -5)
            }
            
            CardViewButton(text: "Duel Links", sheetContents: RelatedBanListContentViewModel(cardName: cardName, banlists: dlBanLists, format: BanListFormat.dl))
                .disabled(self.dlBanLists.isEmpty)
            HStack {
                Text("\(self.dlBanLists.count)")
                    .font(.body)
                    .fontWeight(.bold)
                Text("Occurences(s)")
                    .font(.body)
                    .fontWeight(.light)
                    .padding(.leading, -5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct RelatedBanListsViewModel_Previews: PreviewProvider {
    static var previews: some View {
        RelatedBanListsViewModel(cardName: "Elemental HERO Liquid Soldier",
                                 tcgBanLists: [],
                                 mdBanLists: [],
                                 dlBanLists: [
                                    BanList(banListDate: "2022-12-26", cardID: "59392529", banStatus: "Limited 2", format: "DL"),
                                    BanList(banListDate: "2022-12-08", cardID: "59392529", banStatus: "Limited 2", format: "DL"),
                                    BanList(banListDate: "2022-09-28", cardID: "59392529", banStatus: "Limited 2", format: "DL")
                                 ]
        )
    }
}
