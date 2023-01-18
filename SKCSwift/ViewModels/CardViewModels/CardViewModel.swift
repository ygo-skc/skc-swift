//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct CardViewModel: View {
    var cardId: String
    
    @State private var cardData = Card(cardID: "", cardName: "", cardColor: "", cardAttribute: "", cardEffect: "", monsterType: "")
    @State private var showProductsSheet = false
    @State private var showBanListsSheet = false
    @State private var isDataLoaded = false
    
    @State private var products = [Product]()
    @State private var tcgBanLists = [BanList]()
    @State private var mdBanLists = [BanList]()
    @State private var dlBanLists = [BanList]()
    

    private let imageSize = UIScreen.main.bounds.width - 60
    private let imageUrl: URL
    
    init(cardId: String) {
        self.cardId = cardId
        self.imageUrl =  URL(string: "https://images.thesupremekingscastle.com/cards/lg/\(cardId).jpg")!
    }
    
    var body: some View {
        ScrollView {
            VStack {
                RoundedRectImage(width: imageSize, height: imageSize, imageUrl: imageUrl)
                if (isDataLoaded) {
                    CardStatsViewModel(
                        cardName: cardData.cardName, monsterType: cardData.monsterType, cardEffect: cardData.cardEffect, monsterAssociation: cardData.monsterAssociation,
                        cardId: cardData.cardID, cardAttribute: cardData.cardAttribute
                    )
                } else {
                    RectPlaceholderViewModel(width: .infinity, height: 200, radius: 10)
                }
                
                
                VStack {
                    CardViewButton(text: "Products", sheetContents: RelatedProductsContentViewModels(cardName: cardData.cardName, products: self.products))
                        .disabled(self.products.isEmpty)
                    
                    CardViewButton2(text: "TCG Ban Lists", sheetContents: RelatedBanListsViewModel(cardName: cardData.cardName, tcgBanlists: self.tcgBanLists))
                        .disabled(self.tcgBanLists.isEmpty)
                    CardViewButton2(text: "Master Duel Ban Lists", sheetContents: RelatedBanListsViewModel(cardName: cardData.cardName, tcgBanlists: self.mdBanLists))
                        .disabled(self.mdBanLists.isEmpty)
                    CardViewButton2(text: "Duel Links Ban Lists", sheetContents: RelatedBanListsViewModel(cardName: cardData.cardName, tcgBanlists: self.dlBanLists))
                        .disabled(self.dlBanLists.isEmpty)
                }
                .padding(.all)
            }
            .padding(.horizontal, 5)
            .buttonStyle(.borderedProminent)
        }
        .frame(width: .infinity)
        .onAppear {
            getCardData(cardId: cardId, {result in
                switch result {
                case .success(let card):
                    self.cardData = card
                    
                    self.products = cardData.foundIn ?? [Product]()
                    self.tcgBanLists = cardData.restrictedIn?.TCG ?? [BanList]()
                    self.mdBanLists = cardData.restrictedIn?.MD ?? [BanList]()
                    self.dlBanLists = cardData.restrictedIn?.DL ?? [BanList]()
                    
                    self.isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
}


struct CardViewButton: View {
    var text: String
    var sheetContents: RelatedProductsContentViewModels

    @State private var showSheet = false

    var body: some View {

        Button {
            showSheet.toggle()
        } label: {
            HStack {
                Text(text)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .frame(maxWidth: 200)
        }
        .sheet(isPresented: $showSheet) {
            sheetContents
        }
    }
}


struct CardViewButton2: View {
    var text: String
    var sheetContents: RelatedBanListsViewModel

    @State private var showSheet = false

    var body: some View {

        Button {
            showSheet.toggle()
        } label: {
            HStack {
                Text(text)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .frame(maxWidth: 200)
        }
        .sheet(isPresented: $showSheet) {
            sheetContents
        }
    }
}

struct CardViewModel_Previews: PreviewProvider {
    static var previews: some View {
        CardViewModel(cardId: "90307498")
    }
}
