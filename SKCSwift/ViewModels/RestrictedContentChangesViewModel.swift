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
    
    private(set) var newContentDTS: DataTaskStatus = .pending
    @ObservationIgnored
    private(set) var newContentNE: NetworkError?
    @ObservationIgnored
    private(set) var newContent: BanListNewContent?
    
    private(set) var removedContentDTS: DataTaskStatus = .pending
    @ObservationIgnored
    private(set) var removedContentNE: NetworkError?
    @ObservationIgnored
    private(set) var removedContent: BanListRemovedContent?
    
    @ObservationIgnored
    var isFetching: Bool {
        newContentDTS == .pending || removedContentDTS == .pending
    }
    
    func fetchChanges() async {
        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask { await self.fetchNewContent() }
            taskGroup.addTask { await self.fetchRemovedContent() }
        }
    }
    
    private func fetchNewContent() async {
        guard newContentDTS != .done else { return }
        (newContentNE, newContentDTS) = (nil, .pending)
        (newContentNE, newContentDTS) = await SKCSwift.data(newBannedContent(format: format, listStartDate: effectiveDate), resType: BanListNewContent.self)
            .validate(&newContent)
    }
    
    private func fetchRemovedContent() async {
        guard removedContentDTS != .done else { return }
        (removedContentNE, removedContentDTS) = (nil, .pending)
        (removedContentNE, removedContentDTS) = await SKCSwift.data(removedBannedContent(format: format, listStartDate: effectiveDate), resType: BanListRemovedContent.self)
            .validate(&removedContent)
    }
}
