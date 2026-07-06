//
//  AI.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/3/26.
//

import FoundationModels

@available(iOS 26.0, *)
@Generable(description: "A Yu-Gi-Oh! card's text split into its individual clauses.")
struct CardEffects {
    @Guide(description: "Each distinct clause of the card's text, in order, one per clause, copied verbatim but phrases can be moved around eg: fold a material list into its summoning phrase. Never reword, summarize, truncate, or number. Provide an empty array if there is no text.")
    var effects: [String]
}

struct CardInfoPrompt {
    static let CARD_EFFECT_CLAUSES: StaticString = """
Your job is to parse text and only bucket into individual clauses. You split Yu-Gi-Oh! card text into its individual distinct clauses. Copy text VERBATIM without truncating, numbering, or adding rulings/commentary. The ONLY exception is described under the MATERIALS section below.

SPLITTING
- Output each distinct clause as one array element, preserving order.
- A card will have one clause at a minimum but can have several
- Always split clauses where one self-contained effect ends and a different one begins. 
- Sometimes clauses are multi-sentence and terminated with a period (though not always). It is your job to determine where the full effect clause terminates.
- A clause describing how to summon/special summon a monster is its own clause.
- A phrase describing a summon/special summon restriction is its own clause.
- A phrase with a bulleted list is ONE clause. Keep its intro phrase and all bullets together. Bullets are options within one clause, not separate clauses.
- A standalone limiter phrase (e.g. "You can only use this effect once per turn.") is its own clause.

MATERIALS
This special case will be treated differently...
Fusion/Synchro/Xyz/Link cards MAY open (though not always will) with a list or amount of items needed for the cards summon.
    EG) '"A" + "B"', followed by a summoning phrase, e.g. "Must be Fusion Summoned...". 
When BOTH a summoning phrase and the items needed for the summon are present, merge them into a SINGLE clause 

EXAMPLE 1: Material list + summoning phrase merge into one element; the effect stays separate.
Text — "Elemental HERO Avian" + "Elemental HERO Burstinatrix"
Must be Fusion Summoned and cannot be Special Summoned by other ways. When this card destroys a monster by battle and sends it to the Graveyard: Inflict damage to your opponent equal to the ATK of the destroyed monster in the Graveyard.
Correct Output —
  - Must be Fusion Summoned using "Elemental HERO Avian" and "Elemental HERO Burstinatrix" and cannot be Special Summoned by other ways.
  - When this card destroys a monster by battle and sends it to the Graveyard: Inflict damage to your opponent equal to the ATK of the destroyed monster in the Graveyard.
Reasoning — This monster contains materials, and thus we can take liberties with the material phrase and the summoning phrase. Since the "Must be Fusion Summoned and cannot be Special Summoned by other ways" phrase isn't complete without the materials we want to move the material list after the "Must be Fusion Summoned" and adding a bit more verbiage to combine both the material clause and the summon restriction clause. Notice we didn't broadened or loosened meaning, we are simply letting users know that the way the card is summoned is by using the 2 materials ("Elemental HERO Avian" and "Elemental HERO Burstinatrix") and that it can only be summoned this way (as its effect clearly states). The second clause is the cards second effect.

EXAMPLE 2: Multiple effects; the trailing limiter is its own element.
Text — If this card is Normal or Special Summoned: You can add 1 "Polymerization" from your Deck to your hand. During your Main Phase: You can activate this effect; you cannot Special Summon monsters for the rest of this turn, except Fusion Monsters, also send 1 "Elemental HERO" monster from your Deck to the GY, except "Elemental HERO Blazeman", and if you do, this card's Attribute and ATK/DEF become the same as the monster sent to the GY, until the end of this turn. You can only use 1 "Elemental HERO Blazeman" effect per turn, and only once that turn.
Correct Output —
  - If this card is Normal or Special Summoned: You can add 1 "Polymerization" from your Deck to your hand.
  - During your Main Phase: You can activate this effect; you cannot Special Summon monsters for the rest of this turn, except Fusion Monsters, also send 1 "Elemental HERO" monster from your Deck to the GY, except "Elemental HERO Blazeman", and if you do, this card's Attribute and ATK/DEF become the same as the monster sent to the GY, until the end of this turn.
  - You can only use 1 "Elemental HERO Blazeman" effect per turn, and only once that turn.
Reasoning — The second clause is whats difficult to reason. However, notice that the whole clause is contingent on all its directives. Effect can only be activated in main phase (this cannot be separated from from the next phrase as its the timing of the effect), the cost of the effect itself (what is required for the effect to activate) and the effect itself. The third clause is the global restriction for the card itself not just an effect.

EXAMPLE 3: Bulleted effect stays one element; trailing limiter separate.
Text — When a card or effect is activated that includes any of these effects (Quick Effect): You can discard this card; negate that effect.
- Add a card from the Deck to the hand.
- Special Summon from the Deck.
- Send a card from the Deck to the GY.
You can only use this effect of "Ash Blossom & Joyous Spring" once per turn.
Correct Output —
  - When a card or effect is activated that includes any of these effects (Quick Effect): You can discard this card; negate that effect. • Add a card from the Deck to the hand. • Special Summon from the Deck. • Send a card from the Deck to the GY.
  - You can only use this effect of "Ash Blossom & Joyous Spring" once per turn.
Reasoning - This effect might seem like multiple effects at first, but each bullet point is an option. Someone can select one of them when the effect triggers.

EXAMPLE 4: Fusion monster with no materials just a summoning restriction
Text — Must be Special Summoned by "Mask Change". Any card sent to your opponent's GY is banished instead. Once per turn, if your opponent adds a card(s) from their Deck to their hand (except during the Draw Phase or the Damage Step): You can banish 1 random card from your opponent's hand.
Correct Output —
  - Must be Special Summoned by "Mask Change".
  - Any card sent to your opponent's GY is banished instead.
  - Once per turn, if your opponent adds a card(s) from their Deck to their hand (except during the Draw Phase or the Damage Step): You can banish 1 random card from your.
Reasoning - Though this card is a fusion card, it only has one item used for its summon (clause 1). This is the only text for the clause. Moving on, the second sentence is its own self containing clause that is not related to the first or clause effect. Finally the last clause is clearly also self contained
"""
}
