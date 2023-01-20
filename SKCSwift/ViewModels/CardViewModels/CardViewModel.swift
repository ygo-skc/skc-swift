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
                        cardName: cardData.cardName, cardColor: cardData.cardColor, monsterType: cardData.monsterType, cardEffect: cardData.cardEffect, monsterAssociation: cardData.monsterAssociation,
                        cardId: cardData.cardID, cardAttribute: cardData.cardAttribute, monsterAttack: cardData.monsterAttack, monsterDefense: cardData.monsterDefense
                    )
                } else {
                    RectPlaceholderViewModel(width: .infinity, height: 200, radius: 10)
                }
                
                
                VStack {
                    CardViewButton(text: "Products", sheetContents: RelatedProductsContentViewModels(cardName: cardData.cardName, products: self.products))
                        .disabled(self.products.isEmpty)
                    
                    CardViewButton(text: "TCG Ban Lists", sheetContents: RelatedBanListsViewModel(cardName: cardData.cardName, banlists: self.tcgBanLists, format: BanListFormat.tcg))
                        .disabled(self.tcgBanLists.isEmpty)
                    CardViewButton(text: "Master Duel Ban Lists", sheetContents: RelatedBanListsViewModel(cardName: cardData.cardName, banlists: self.mdBanLists, format: BanListFormat.md))
                        .disabled(self.mdBanLists.isEmpty)
                    CardViewButton(text: "Duel Links Ban Lists", sheetContents: RelatedBanListsViewModel(cardName: cardData.cardName, banlists: self.dlBanLists, format: BanListFormat.dl))
                        .disabled(self.dlBanLists.isEmpty)
                }
                .padding(.all)
            }
            .padding(.horizontal, 5)
            .buttonStyle(.borderedProminent)
        }
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

struct CardViewButton<RC: RelatedContent>: View {
    var text: String
    var sheetContents: RC
    
    @State private var showSheet = false
    
    func sheetDismissed() {
        showSheet = false
    }
    
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
        .sheet(isPresented: $showSheet, onDismiss: sheetDismissed) {
            sheetContents
        }
    }
}

struct CardViewModel_Previews: PreviewProvider {
    static var previews: some View {
        CardViewModel(cardId: "90307498")
    }
}
