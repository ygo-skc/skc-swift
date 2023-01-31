//
//  CardSuggestionsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/29/23.
//

import SwiftUI

struct CardSuggestionsViewModel: View {
    var namedMaterials: [CardReference]
    var namedReferences: [CardReference]
    var isDataLoaded: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Card Suggestions")
                .font(.title)
                .padding(.top)
            
            Text("Other cards that have a tie of sorts with currently selected card. These could be summoning materials for example.")
                .fontWeight(.light)
                .padding(.top, -10)
            
            NamedSuggestionsViewModel(header: "Named Materials", references: namedMaterials, isDataLoaded: isDataLoaded)
            Divider()
                .padding(.top)
            
            NamedSuggestionsViewModel(header: "Named References", references: namedReferences, isDataLoaded: isDataLoaded)
            Divider()
                .padding(.top)
        }
        .frame(maxWidth: .infinity)
        .padding(.all)
    }
}

private struct NamedSuggestionsViewModel: View {
    var header: String
    var references: [CardReference]
    var isDataLoaded: Bool
    
    var body: some View {
        Text(header)
            .font(.title2)
            .fontWeight(.bold)
            .padding(.top)
        
        if (isDataLoaded) {
            if (references.isEmpty) {
                Text("Nothing here 🤔")
                    .font(.headline)
                    .padding(.all)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(references, id: \.card.cardID) { suggestion in
                            SuggestedCardViewModel(cardId: suggestion.card.cardID, cardName: suggestion.card.cardName, cardColor: suggestion.card.cardColor,
                                                   cardEffect: suggestion.card.cardEffect, cardAttribute: suggestion.card.cardAttribute, monsterType: suggestion.card.monsterType,
                                                   monsterAttack: suggestion.card.monsterAttack, monsterDefense: suggestion.card.monsterDefense, occurrence: suggestion.occurrences
                            )
                        }
                    }
                }
                .padding(.horizontal, -20)
            }
        } else {
            RectPlaceholderViewModel(width: 300, height: 150, radius: 10)
        }
    }
}

struct CardSuggestionsViewModel_Previews: PreviewProvider {
    static var previews: some View {
        CardSuggestionsViewModel(
            namedMaterials: [
                CardReference(
                    occurrences: 1,
                    card: Card(cardID: "89943723", cardName: "Elemental HERO Neos", cardColor: "Normal", cardAttribute: "Light", cardEffect: "A new Elemental HERO has arrived from Neo-Space! When he initiates a Contact Fusion with a Neo-Spacian his unknown powers are unleashed.")
                ),
                CardReference(
                    occurrences: 1,
                    card: Card(cardID: "78371393", cardName: "Yubel", cardColor: "Effect", cardAttribute: "Dark", cardEffect: "This card cannot be destroyed by battle. You take no Battle Damage from battles involving this card. Before damage calculation, when this face-up Attack Position card is attacked by an opponent's monster: Inflict damage to your opponent equal to that monster's ATK. During your End Phase: Tribute 1 other monster or destroy this card. When this card is destroyed, except by its own effect: Its owner can Special Summon 1 \"Yubel - Terror Incarnate\" from their hand, Deck, or Graveyard.")
                )
            ],
            namedReferences: [
                                CardReference(
                                    occurrences: 1,
                                    card: Card(cardID: "05126490", cardName: "Neos Wiseman", cardColor: "Effect", cardAttribute: "Light", cardEffect: "Cannot be Normal Summoned or Set. Must be Special Summoned (from your hand) by sending 1 face-up \"Elemental HERO Neos\" and 1 face-up \"Yubel\" you control to the Graveyard, and cannot be Special Summoned by other ways. This card cannot be destroyed by card effects. At the end of the Damage Step, if this card battled an opponent's monster: Inflict damage to your opponent equal to the ATK of the monster it battled, and you gain Life Points equal to that monster's DEF.")
                                )
            ], isDataLoaded: true)
    }
}
