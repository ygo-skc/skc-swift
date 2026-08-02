//
//  ArchetypesViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 12/14/25.
//

import Foundation

@Observable
final class ArchetypesViewModel {
    @ObservationIgnored
    let archetype: String
    
    init(archetype: String) {
        self.archetype = archetype
    }
    
    private(set) var dataDTS: DataTaskStatus = .pending
    @ObservationIgnored
    private(set) var dataNE: NetworkError?
    
    @ObservationIgnored
    private(set) var data: YGOArchetypeData = .init(inheritMembers: [], qualifiedMembers: [], excludedMembers: [])
    
    @ObservationIgnored
    var hasContent: Bool {
        dataDTS == .done
    }
    
    func fetchArchetypeData() async {
        guard dataDTS != .done else { return }
        (dataNE, dataDTS) = (nil, .pending)
        let res = await SKCSwift.data(archetypeSuggestionsURL(archetype: archetype), resType: YGOArchetypeData.self)
        (dataNE, dataDTS) = res.validate(&data, keyPath: \.self)
    }
}
