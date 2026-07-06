//
//  AI.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/3/26.
//

import FoundationModels

@available(iOS 26.0, *)
@Generable(description: "A Yu-Gi-Oh! card's text split into its individual clauses.")
struct CardClauses {
    @Guide(description: "Each distinct clause of the card's text, in order, one per clause, copied verbatim. Never reword, summarize, truncate, or number. Provide an empty array if there is no text. When concatenated these individual clauses will derive the original text")
    var Clauses: [String]
}

struct CardInfoPrompt {
    static let CARD_EFFECT_CLAUSES: StaticString = """
Your job is to parse text and only bucket into individual clauses. You split Yu-Gi-Oh! card text into its individual distinct clauses. Copy text VERBATIM without truncating, numbering, or adding rulings/commentary. 

CLAUSE CATEGORIZATION
- Output each distinct clause as one array element, preserving order.
- A card will have one clause at a minimum but can have several
- Always split clauses where one self-contained effect ends and a different one begins. 
- Sometimes clauses are multi-sentence and terminated with a period (though not always). It is your job to determine where the full effect clause terminates.
- A clause describing how to summon/special summon a monster is its own self contained clause.
- A phrase describing a summon/special summon restriction is its own self contained clause.
- A phrase with a bulleted list is ONE clause. Keep its intro phrase and all bullets together. Bullets are options within one clause, not separate clauses.
- A standalone limiter phrase (e.g. "You can only use this effect once per turn.") is its own self contained clause.
- Some clauses list ingredients. Ingredients are formatted as named items in quotes joined by "+" (e.g. "A" + "B" + "C"), and/or as a quantity plus a category (e.g. 2 X, or 1 X + 1 or more Y), and the two styles are often mixed in one list. Keep the entire ingredient list together as ONE clause — never split it, and never separate an ingredient from its clause. Any description attached to an ingredient stays with that ingredient (e.g. "1 X with [some trait]" is a single ingredient, not an ingredient plus a separate fragment); note that quotation marks can also appear INSIDE a generic ingredient as part of its description (e.g. 2 "[name]" X), which is different from a fully-named ingredient written entirely in quotes ("[full name]"). The "+" symbol has two distinct meanings that must not be confused: surrounded by spaces it joins one ingredient to the next and is NOT a split point (both sides stay in the same clause); attached directly to a number with no space (e.g. 2+) it means "or more" and is part of the amount — this same "or more" idea is sometimes spelled out in words instead (e.g. "1 or more Y"). The word "or" may likewise appear to offer a choice between ingredients (e.g. "A" or "B"); this is part of the one ingredient list and is NOT a clause boundary. The ingredient list is typically the first line or paragraph of the card and ends where the card's instructions begin; it may contain 1, 2, or more ingredients. Occasionally the list is written as a full sentence rather than the shorthand above, but it is still one self-contained ingredient clause.
- YOU MUST USE EVERY CHARACTER OF THE PROVIDED TEXT — concatenating all clauses in order must reproduce the original text EXACTLY. This is a partition of the text, not a rewrite: reproduce each clause verbatim and do NOT paraphrase, summarize, reorder, normalize, fix typos, or add or drop any text (including short limiter phrases or trailing conditions that may seem minor or redundant). Every character of the input belongs to exactly one clause — nothing skipped, nothing duplicated, nothing overlapping. Preserve all whitespace and punctuation, including the spaces and line breaks BETWEEN clauses: attach the connecting whitespace (the space or newline that follows a period) to the END of the preceding clause, so that joining the array with no separator rebuilds the source character-for-character. Before returning, concatenate your clauses in order and compare the result to the original input; if it does not match exactly — including spacing — revise the split until it does.

EXAMPLE 1: Material list + summoning phrase merge into one element; the effect stays separate.
Text — "Elemental HERO Avian" + "Elemental HERO Burstinatrix"
Must be Fusion Summoned and cannot be Special Summoned by other ways. When this card destroys a monster by battle and sends it to the Graveyard: Inflict damage to your opponent equal to the ATK of the destroyed monster in the Graveyard.
Correct Output —
  - "Elemental HERO Avian" + "Elemental HERO Burstinatrix"
  - Must be Fusion Summoned and cannot be Special Summoned by other ways
  - When this card destroys a monster by battle and sends it to the Graveyard: Inflict damage to your opponent equal to the ATK of the destroyed monster in the Graveyard.
Reasoning — This text contains a clause describing ingredients (first clause). Ingredients should NEVER be separated into different clauses. As such we cannot combine clause one and two.

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
