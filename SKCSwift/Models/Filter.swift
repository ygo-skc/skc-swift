//
//  FilteredItem.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/23/24.
//

import Foundation

struct FilteredItem<T: Equatable & Sendable>: Equatable, Identifiable, Sendable {
    let category: T
    var isToggled: Bool
    var disableToggle: Bool
    
    var id: String {
        return String(describing: category) + "-\(isToggled)-\(disableToggle)"
    }
}

struct CardFilters: Equatable, Sendable {
    var attributes: [FilteredItem<String>]
    var colors: [FilteredItem<String>]
    var levels: [FilteredItem<UInt8>]
    var ranks: [FilteredItem<UInt8>]
    var linkRatings: [FilteredItem<UInt8>]
    
    init(attributes: [FilteredItem<String>], colors: [FilteredItem<String>], levels: [FilteredItem<UInt8>],
         ranks: [FilteredItem<UInt8>], linkRatings: [FilteredItem<UInt8>]) {
        self.attributes = attributes
        self.colors = colors
        self.levels = levels
        self.ranks = ranks
        self.linkRatings = linkRatings
    }
}

extension CardFilters {
    init() {
        self.init(attributes: [], colors: [], levels: [], ranks: [], linkRatings: [])
    }
}
