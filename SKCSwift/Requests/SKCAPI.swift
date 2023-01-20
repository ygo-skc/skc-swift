//
//  SKCAPI.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

import Foundation

func getCardData(cardId: String, _ completion: @escaping (Result<Card, Error>) -> Void)->  Void {
    let url = cardInfoURL(cardId: cardId)
    let request = baseSKCAPIRequest(url: url)
    
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
            let cardData = try skcAPIDecoder.decode(Card.self, from: body!)
            completion(.success(cardData))
        } catch {
            print("An error ocurred while decoding output from SKC API \(error.localizedDescription)")
        }
    })
    .resume()
}

func searchCard(searchTerm: String, _ completion: @escaping (Result<[Card], Error>) -> Void)->  URLSessionDataTask {
    let url = searchCardURL(cardName: searchTerm)
    let request = baseSKCAPIRequest(url: url)
    
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
            let cardData = try skcAPIDecoder.decode([Card].self, from: body!)
            completion(.success(cardData))
        } catch {
            print("An error ocurred while decoding output from SKC API \(error.localizedDescription)")
        }
    })
    
    dataTask.priority = 1
    dataTask.resume()
    return dataTask
}
