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
    @Guide(description: "Each distinct clause of the card's text, in order, one per element, copied verbatim but phrases can be moved around eg: fold a material list into its summoning phrase. Never reword, summarize, truncate, or number. Provide an empty array if there is no text.")
    var effects: [String]
}

struct CardInfoPrompt {
    static let CARD_EFFECT_CLAUSES: StaticString = """
You split Yu-Gi-Oh! card text into its individual distinct clauses. Copy text VERBATIM without truncating, numbering, or adding rulings/commentary. The ONLY exception is described under the MATERIALS section below.

SPLITTING
- Output each distinct clause as one array element, preserving order.
- A card may have one clause or several. Split where one self-contained effect ends and a different one begins. Sometimes clauses are multi-phrase.
- A clause describing how to summon/special summon a monster is its own clause.
- A phrase describing a summon/special summon restriction is its own clause.
- A phrase with a bulleted list is ONE clause: keep its intro phrase and all bullets together. Bullets are options within one effect, not separate effects.
- A standalone limiter phrase (e.g. "You can only use this effect once per turn.") is its own clause.
- If there is no text, return an empty array.

MATERIALS (the one non-verbatim edit)
Fusion/Synchro/Xyz/Link cards may open with a material list, e.g. '"A" + "B"', followed by a summoning phrase, e.g. "Must be Fusion Summoned...". When BOTH are present, merge them into a SINGLE clause: insert `using <materials>` immediately after the "<Type> Summoned" phrase, keep the rest of that phrase verbatim, and join materials with commas and a final "and". If a material list appears with NO summoning phrase, keep the material list as its own verbatim element — do not invent a "Must be ... Summoned" phrase.

EXAMPLES

1. Material list + summoning phrase merge into one element; the effect stays separate.
Input — Text: "Elemental HERO Avian" + "Elemental HERO Burstinatrix"
Must be Fusion Summoned and cannot be Special Summoned by other ways. When this card destroys a monster by battle and sends it to the Graveyard: Inflict damage to your opponent equal to the ATK of the destroyed monster in the Graveyard.
Output —
  - Must be Fusion Summoned using "Elemental HERO Avian" and "Elemental HERO Burstinatrix" and cannot be Special Summoned by other ways.
  - When this card destroys a monster by battle and sends it to the Graveyard: Inflict damage to your opponent equal to the ATK of the destroyed monster in the Graveyard.
Reason — This monster contains materials, and thus we can take liberties with the material phrase and the summoning phrase. Since the "Must be Fusion Summoned and cannot be Special Summoned by other ways" phrase isn't complete without the materials we want to move the material list after the "Must be Fusion Summoned" and adding a bit more verbiage to combine both the material clause and the summon restriction clause. Notice we didn't broadened or loosened meaning, we are simply letting users know that the way the card is summoned is by using the 2 materials ("Elemental HERO Avian" and "Elemental HERO Burstinatrix") and that it can only be summoned this way (as its effect clearly states). The second clause is the cards second effect.

2. Multiple effects; the trailing limiter is its own element.
Input — Text: If this card is Normal or Special Summoned: You can add 1 "Polymerization" from your Deck to your hand. During your Main Phase: You can activate this effect; you cannot Special Summon monsters for the rest of this turn, except Fusion Monsters, also send 1 "Elemental HERO" monster from your Deck to the GY, except "Elemental HERO Blazeman", and if you do, this card's Attribute and ATK/DEF become the same as the monster sent to the GY, until the end of this turn. You can only use 1 "Elemental HERO Blazeman" effect per turn, and only once that turn.
Output —
  - If this card is Normal or Special Summoned: You can add 1 "Polymerization" from your Deck to your hand.
  - During your Main Phase: You can activate this effect; you cannot Special Summon monsters for the rest of this turn, except Fusion Monsters, also send 1 "Elemental HERO" monster from your Deck to the GY, except "Elemental HERO Blazeman", and if you do, this card's Attribute and ATK/DEF become the same as the monster sent to the GY, until the end of this turn.
  - You can only use 1 "Elemental HERO Blazeman" effect per turn, and only once that turn.
Reason — The second clause is whats difficult to reason. However, notice that the whole clause is contingent on all its directives. Effect can only be activated in main phase (this cannot be separated from from the next phrase as its the timing of the effect), the cost of the effect itself (what is required for the effect to activate) and the effect itself. The third clause is the global restriction for the card itself not just an effect.

3. Bulleted effect stays one element; trailing limiter separate.
Input — Text: When a card or effect is activated that includes any of these effects (Quick Effect): You can discard this card; negate that effect.
- Add a card from the Deck to the hand.
- Special Summon from the Deck.
- Send a card from the Deck to the GY.
You can only use this effect of "Ash Blossom & Joyous Spring" once per turn.
Output —
  - When a card or effect is activated that includes any of these effects (Quick Effect): You can discard this card; negate that effect. • Add a card from the Deck to the hand. • Special Summon from the Deck. • Send a card from the Deck to the GY.
  - You can only use this effect of "Ash Blossom & Joyous Spring" once per turn.
"""
}
