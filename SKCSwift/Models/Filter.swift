//
//  FilteredItem.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/23/24.
//

import Foundation

struct FilteredItem: Identifiable, Equatable {
    let category: String
    var isToggled: Bool
    var disableToggle: Bool
    
    var id: String {
        return category + "-\(isToggled)-\(disableToggle)"
    }
}

struct CardFilters: Equatable {
    var attributes: [FilteredItem]
    var colors: [FilteredItem]
}
