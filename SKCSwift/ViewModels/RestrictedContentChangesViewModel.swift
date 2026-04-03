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
        if newContentDTS == .done { return }
        (newContentNE, newContentDTS) = (nil, .pending)
        let res = await SKCSwift.data(newBannedContent(format: format, listStartDate: effectiveDate), resType: BanListNewContent.self)
        if case .success(let newContent) = res {
            self.newContent = newContent
        }
        (newContentNE, newContentDTS) = res.validate()
    }
    
    private func fetchRemovedContent() async {
        if newContentDTS == .done { return }
        let res = await SKCSwift.data(removedBannedContent(format: format, listStartDate: effectiveDate), resType: BanListRemovedContent.self)
        if case .success(let removedContent) = res {
            self.removedContent = removedContent
        }
        (removedContentNE, removedContentDTS) = res.validate()
    }
}
