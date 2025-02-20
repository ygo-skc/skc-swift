//
//  FilteredItem.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/23/24.
//

import Foundation

struct FilteredItem<T: Equatable>: Equatable, Identifiable {
    let category: T
    var isToggled: Bool
    var disableToggle: Bool
    
    var id: String {
        return String(describing: category) + "-\(isToggled)-\(disableToggle)"
    }
}

struct CardFilters: Equatable {
    var attributes: [FilteredItem<String>]
    var colors: [FilteredItem<String>]
    var levels: [FilteredItem<UInt8>]
}
