//
//  SwiftUIView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/21/24.
//

import SwiftUI


struct CardListView: View, Equatable {
    static func == (lhs: CardListView, rhs: CardListView) -> Bool {
        lhs.showAllInfo == rhs.showAllInfo && lhs.cards == rhs.cards
    }
    
    let cards: [Card]
    let showAllInfo: Bool
    @Binding var path: NavigationPath
    let action: (() -> Void)?
    
    init(cards: [Card], showAllInfo: Bool = false, path: Binding<NavigationPath>, action: (() -> Void)? = nil) {
        self.cards = cards
        self.showAllInfo = showAllInfo
        self._path = path
        self.action = action
    }
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            ForEach(cards, id: \.cardID) { card in
                Button {
                    action?()
                    path.append(CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName))
                } label: {
                    GroupBox {
                        CardListItemView(card: card, showAllInfo: showAllInfo)
                            .equatable()
                    }
                    .groupBoxStyle(.listItem)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
        }
        .ignoresSafeArea(.keyboard)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CardListItemView: View, Equatable {
    let card: Card
    let showAllInfo: Bool
    
    init(card: Card, showAllInfo: Bool = false) {
        self.card = card
        self.showAllInfo = showAllInfo
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            CardImageView(length: 65, cardID: card.cardID, imgSize: .tiny, variant: .roundedCorner)
                .equatable()
            VStack(alignment: .leading, spacing: 3) {
                Text(card.cardName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                ListItemSecondRow(cardID: card.cardID, cardColor: card.cardColor, monsterType: card.monsterType, isCardAGod: card.isGod)
                ListItemThirdRow(cardColor: card.cardColor, attribute: card.attribute, monsterAssociation: card.monsterAssociation, showAllInfo: showAllInfo)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .dynamicTypeSize(...DynamicTypeSize.medium)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct ListItemSecondRow: View {
    let cardID: String
    let cardColor: String
    let monsterType: String?
    let isCardAGod: Bool
    
    var body: some View {
        HStack {
            Text(monsterType ?? cardColor)
                .font(.subheadline)
                .fontWeight(.light)
                .lineLimit(1)
            
            Spacer()
            
            if !isCardAGod {
                Text(cardID)
                    .font(.caption)
                    .fontWeight(.thin)
            }
        }
    }
}

private struct ListItemThirdRow: View {
    let cardColor: String
    let attribute: Attribute
    let monsterAssociation: MonsterAssociation?
    let showAllInfo: Bool
    
    var body: some View {
        HStack {
            CardColorIndicatorView(cardColor: cardColor, variant: .regular)
                .equatable()
            if showAllInfo {
                MonsterAssociationView(monsterAssociation: monsterAssociation,
                                       attribute: attribute,
                                       variant: .listView,
                                       iconVariant: .regular)
                .equatable()
            } else {
                AttributeView(attribute: attribute, variant: .regular)
                    .equatable()
            }
        }
    }
}

#Preview("Card Search Result") {
    CardListItemView(card: Card(
        cardID: "40044918",
        cardName: "Elemental HERO Stratos",
        cardColor: "Effect",
        cardAttribute: "Wind",
        cardEffect: "Draw 2",
        monsterType: "Warrior/Effect"
    ))
}

#Preview("Card Search Result - IMG DNE") {
    CardListItemView(card: Card(
        cardID: "40044918",
        cardName: "Elemental HERO Stratos",
        cardColor: "Effect",
        cardAttribute: "Wind",
        cardEffect: "Draw 2",
        monsterType: "Warrior/Effect"
    ))
}
