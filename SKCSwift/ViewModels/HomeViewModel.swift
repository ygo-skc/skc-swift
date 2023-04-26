//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

private class CardOfTheDayViewModel: ObservableObject {
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
struct COTDViewModel: View {
    @StateObject private var cardOfTheDay = CardOfTheDayViewModel()
    
    var body: some View {
        VStack {
            if (cardOfTheDay.isDataLoaded) {
                Text("Card of the Day")
                    .font(.title)
                    .padding(.top)
                Text(cardOfTheDay.card.cardName)
            }
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .onAppear{
            cardOfTheDay.fetchData()
        }
    }
}

struct HomeViewModel: View {
    let screenWidth = UIScreen.main.bounds.width - 10
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Content")
                        .font(.title)
                    Text("The SKC Database has 1,000 cards, 36 ban lists and 200 products.")
                        .fontWeight(.light)
                        .font(.headline)
                }
                .padding(.top)
                
                COTDViewModel()
            }
            .padding(.horizontal)
            .navigationTitle("Home")
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
            )
        }
    }
}

struct HomeViewModel_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewModel()
    }
}
