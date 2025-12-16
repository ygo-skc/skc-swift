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
    private(set) var data: ArchetypeData = .init(usingName: [], usingText: [], exclusions: [])
    
    func fetchArchetypeData() async {
        dataDTS = .pending
        let res = await SKCSwift.data(archetypeSuggestionsURL(archetype: archetype), resType: ArchetypeData.self)
        if case .success(let data) = res {
            self.data = data
        }
        (dataNE, dataDTS) = res.validate()
    }
}
