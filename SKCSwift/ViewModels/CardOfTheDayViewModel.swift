//
//  CardOfTheDayViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import Foundation


class CardOfTheDayViewModel: ObservableObject {
    @Published private(set) var date: String = ""
    @Published private(set) var card: Card = Card(cardID: "", cardName: "", cardColor: "", cardAttribute: "", cardEffect: "")
    @Published private(set) var isDataLoaded = false
    
    
    func fetchData() {
        getCardOfTheDayTask({result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cardOfTheyDay):
                    self.date = cardOfTheyDay.date
                    self.card = cardOfTheyDay.card
                    self.isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            }
        })
    }
}
