//
//  SKCAPI.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

import Foundation

// SKC API Data Tasks

func getCardData(cardId: String, _ completion: @escaping (Result<Card, Error>) -> Void)->  Void {
    let url = cardInfoURL(cardId: cardId)
    let request = baseRequest(url: url)
    
    URLSession.shared.dataTask(with: request, completionHandler: { (body, response, error) -> Void in
        // handle error
        if (error != nil) {
            print("Error occurred while calling SKC API \(error!.localizedDescription)")
            return
        } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
            print("Card \(cardId) not found in database.")
        }
        
        // read body as no error was present
        do {
            let cardData = try decoder.decode(Card.self, from: body!)
            completion(.success(cardData))
        } catch {
            print("An error ocurred while decoding output from SKC API \(error.localizedDescription)")
        }
    })
    .resume()
}

func searchCard(searchTerm: String, _ completion: @escaping (Result<[Card], Error>) -> Void)->  URLSessionDataTask {
    let url = searchCardURL(cardName: searchTerm)
    let request = baseRequest(url: url)
    
    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (body, response, error) -> Void in
        // handle error
        if (error != nil) {
            if (error!.localizedDescription != "cancelled") {
                print("Error occurred while calling SKC API \(error!.localizedDescription)")
            }
            completion(.failure(error!))
            return
        }
        
        // read body as no error was present
        do {
            let cardData = try decoder.decode([Card].self, from: body!)
            completion(.success(cardData))
        } catch {
            print("An error ocurred while decoding output from SKC API \(error.localizedDescription)")
        }
    })
    
    dataTask.priority = 1
    dataTask.resume()
    return dataTask
}

// SKC API Data Tasks

func getCardSuggestionsTask(cardId: String, _ completion: @escaping (Result<CardSuggestions, Error>) -> Void)->  Void {
    let url = cardSuggestionsURL(cardId: cardId)
    let request = baseRequest(url: url)
    
    URLSession.shared.dataTask(with: request, completionHandler: { (body, response, error) -> Void in
        // handle error
        if (error != nil) {
            print("Error occurred while calling SKC Suggestion Engine \(error!.localizedDescription)")
            return
        } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
            print("Card \(cardId) not found in database.")
        }
        
        // read body as no error was present
        do {
            let cardData = try decoder.decode(CardSuggestions.self, from: body!)
            completion(.success(cardData))
        } catch {
            print("An error ocurred while decoding output from SKC Suggestion Engine \(error)")
        }
    })
    .resume()
}
