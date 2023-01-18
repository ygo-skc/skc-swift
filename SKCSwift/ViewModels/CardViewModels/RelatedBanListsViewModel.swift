//
//  RelatedBanListsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/7/23.
//

import SwiftUI

struct RelatedBanListsViewModel: View {
    var cardName: String
    var tcgBanlists: [BanList]
    
    var body: some View {
        if (tcgBanlists.isEmpty) {
            VStack {
                Text("No Ban Lists Found")
                    .font(.title)
                    .padding(.horizontal)
                Text("\(cardName) has not been added to any ban list in TCG, Master Duel or Duel Links formats or the database hasn't been updated")
                    .multilineTextAlignment(.center)
                    .padding(.top, 1)
                    .padding(.horizontal)
            }
        } else {
            NavigationStack {
                VStack(alignment: .leading) {
                    Text("TCG Ban Lists \(cardName) Was In")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .padding()
                    List {
                        ForEach(tcgBanlists, id: \.banListDate) { instance in
                            BanListItemViewModel(banListInstance: instance)
                        }
                    }.listStyle(.plain)
                }
                .navigationTitle("Ban Lists")
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
            }
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
                switch banListInstance.banStatus {
                case "Forbidden":
                    Circle()
                        .foregroundColor(.red)
                        .frame(width: 30)
                case "Limited", "Limited 1":
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: 30)
                case "Semi-Limited", "Limited 2":
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 30)
                case "Limited 3":
                    Circle()
                        .foregroundColor(.blue)
                        .frame(width: 30)
                default:
                    Circle()
                        .foregroundColor(.black)
                        .frame(width: 30)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            DateViewModel(date: banListInstance.banListDate)
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

struct RelatedBanListsViewModel_Previews: PreviewProvider {
    static var previews: some View {
        let banLists = [
            BanList(banListDate: "2019-07-15", cardID: "40044918", banStatus: "Semi-Limited", format: "TCG"),
            BanList(banListDate: "2019-04-29", cardID: "40044918", banStatus: "Limited", format: "TCG")
        ]
        
        RelatedBanListsViewModel(cardName: "Elemental HERO Stratos", tcgBanlists: banLists)
    }
}
