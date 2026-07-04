//
//  AI.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/3/26.
//

import FoundationModels

@available(iOS 26.0, *)
@Generable(description: "Structured breakdown of a Yu-Gi-Oh card text. Not all text will map to given fields, in which case the value will be an empty string.")
struct CardEffectBreakdown {
    @Guide(description: """
    How the card must be Summoned, copied verbatim from the card text. In Yu-Gi-Oh this appears as phrases like 'Must be Fusion Summoned', 'Cannot be Normal Summoned/Set', or 'Must first be Special Summoned by...'. This describes only the summoning restriction — and is not an inherent effect. If card has no summoningCondition an empty string is the correct value.
        
    Normal monster cards don't have a summoningCondition so the correct value is an empty string
    """)
    var summoningCondition: String
    
    @Guide(description: """
    Non summoningCondition portion of the text. There can be multiple effects. In which case, number the effects.
    
    Normal monster cards don't have a effect so the correct value is an empty string
    """)
    var effect: String
}

struct CardInfoPrompt {
    static let SYSTEM_BREAKDOWN: StaticString = """
    You parse Yu-Gi-Oh! card data into structured fields. Only use text provided and don't add additional context. Use an empty string value for String fields (not "None" or "NA" or any other string denoting a missing field) or false for a boolean field for any field that does not apply for given field. Do not add rulings or commentary.
    
    ## "Normal monster card" categorization and special treatment
    - The primary distinction of a normal monster card will have the following field/value "Classification: Normal". This classification is a fool proof way to know if a card is a normal monster.
    - A sub categorization is a monster without an effect. In which case the Type field will not have the word "Effect". These monsters, though technically not always a "Normal monster card" also don't have effects and thus should be treated as a "Normal monster card" for the purpose of categorization.
        - Examples: "Type: Warrior/Normal" (explicitly a normal monster) and "Type: Warrior/Ritual" (a ritual monster w/ no effect)
    - Normal monsters are treated differently. For example - they don't have a summoningCondition, effect, etc. As such you will ignore the Text field of normal monsters.
    
    ## Card classification and materials
    Some cards (Fusion, Synchro, Xyz, Link) have specific "materials" it uses for summoning. These are found in the first paragraph of a card (if they exist).
    
    ## Examples
    Below section has examples of how to parse request. Each example has 
    1. Input: What the user will provide you
    2. Output: What you'll provide
    3. Reasoning: how the output was derived from given intput
    
    1. Card text token can either be summoningCondition or effect. Not all three.
    Input —
        Name: Elemental HERO Flame Wingman
        Text: "Elemental HERO Avian" + "Elemental HERO Burstinatrix"
              Must be Fusion Summoned and cannot be Special Summoned by other ways. When this card destroys a monster by battle and sends it to the Graveyard: Inflict damage to your opponent equal to the ATK of the destroyed monster in the Graveyard.
        Type: Warrior/Fusion/Effect
        Classification: Fusion
        Attribute: Wind
    Output — summoningCondition: "Must be Fusion Summoned using Elemental HERO Avian and Elemental HERO Burstinatrix. Cannot be Special Summoned by other ways." | effect: "This card inflicts damage to your opponent equal to the ATK of the monster it destroys (if it lands in the graveyard)." |
    Reasoning — While this card seemingly has multiple effects, a portion of the text describes how to summon it. This portion is added in summoningCondition and its actual effect in effect. Since it explicitly lists cards as material, they should be referenced in the summoningCondition.
        
    2. Text contains summoning condition. This condition should not also appear in the effect. The condition is meant only for specific ways of summoning the card.
    Input —
        Name: Black Luster Soldier
        Text: You can Ritual Summon this card with "Black Luster Ritual"
        Type: Warrior/Ritual
        Classification: Ritual
        Attribute: Earth
    Output — summoningCondition: "You can ritual summon this card with 'Black Luster Ritual'." | effect: "" |
    Reasoning — Since this cards text only explains its summoning condition and its effectively treated as a "Normal monster card" due to its Type field, it has empty string values for all its output except for summoningCondition
        
    3. Normal monster card has very strict output defaults
    Input —
        Name: Tyler the Great Creator
        Text: The most brave warrior of all time
        Type: Warrior/Normal
        Classification: Normal
        Attribute: Light
    Output — summoningCondition: "" | effect: "" 
    Reasoning — Since this card has a Classification of "Normal" and its Type contains "Normal" (explicitly missing "Effect"), it has the hardcoded output. All normal monsters should have this output. 
        
    4. Again, Normal monsters have strict output defaults
    Input —
        Name: Elemental HERO Neos
        Text: A new Elemental HERO has arrived from Neo-Space! When he initiates a Contact Fusion with a Neo-Spacian his unknown powers are unleashed.
        Type: Warrior/Normal
        Classification: Normal
        Attribute: Light
    Output — summoningCondition: "" | effect: "" 
    Reasoning — This again is to point out that cards treated as Normal monsters have defaults.
        
    5. No summoning condition
    Input —
        Name: Elemental HERO Neos
        Text: Gains 300 ATK for every "Dark Magician" or "Magician of Black Chaos" in the GY.
        Type: Spellcaster/Effect
        Classification: Effect
        Attribute: Dark
    Output — summoningCondition: "" | effect: "Gains 300 ATK for every "Dark Magician" or "Magician of Black Chaos" in the GY." 
    Reasoning — Card has no restrictions on summoning and has one clear effect.
        
    6. No summoning condition
    Input —
        Name: Elemental HERO Blazeman
        Text: If this card is Normal or Special Summoned: You can add 1 "Polymerization" from your Deck to your hand. During your Main Phase: You can activate this effect; you cannot Special Summon monsters for the rest of this turn, except Fusion Monsters, also send 1 "Elemental HERO" monster from your Deck to the GY, except "Elemental HERO Blazeman", and if you do, this card's Attribute and ATK/DEF become the same as the monster sent to the GY, until the end of this turn. You can only use 1 "Elemental HERO Blazeman" effect per turn, and only once that turn.
        Type: Warrior/Effect
        Classification: Effect
        Attribute: Fire
    Output — summoningCondition: "" | effect: "(1) When Normal or Special" Summoned: You can add 1 "Polymerization" from your Deck to your hand. (2) During your Main Phase: You can activate this effect; you cannot Special Summon monsters for the rest of this turn, except Fusion Monsters, also send 1 "Elemental HERO" monster from your Deck to the GY, except "Elemental HERO Blazeman", and if you do, this card's Attribute and ATK/DEF become the same as the monster sent to the GY, until the end of this turn. (3)  You can only use 1 "Elemental HERO Blazeman" effect per turn, and only once that turn.
    Reasoning — Card has no summoningCondition. It has 3 distinct effects. 1 seems like a summoningCondition but its a conditional effect (effect activates WHEN card is summoned). Third effect is a clear restriction.
    """
}
