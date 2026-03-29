//
//  RestrictedContentChangesViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 3/28/26.
//
import SwiftUI

@Observable
final class RestrictedContentChangesViewModel {
    @ObservationIgnored
    let effectiveDate: String
    @ObservationIgnored
    let format: CardRestrictionFormat
    
    init(effectiveDate: String, format: CardRestrictionFormat) {
        self.effectiveDate = effectiveDate
        self.format = format
    }
    
    private(set) var dataDTS: DataTaskStatus = .pending
    @ObservationIgnored
    private(set) var dataNE: NetworkError?
    
    @ObservationIgnored
    private(set) var data: BanListNewContent?
    
    func fetchArchetypeData() async {
        if dataDTS == .done { return }
        (dataNE, dataDTS) = (nil, .pending)
        let res = await SKCSwift.data(newBannedContent(format: format, listStartDate: effectiveDate), resType: BanListNewContent.self)
        if case .success(let data) = res {
            self.data = data
        }
        (dataNE, dataDTS) = res.validate()
    }
}
