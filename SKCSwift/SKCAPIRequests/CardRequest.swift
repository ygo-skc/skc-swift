//
//  CardData.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import Foundation

func fetchCardInfoURL(cardId: String) -> URL {
    guard let url = URL(string: "\(BASE_URL)/api/v1/card/\(cardId)?allInfo=true") else {
        fatalError("URL is incorrect")
    }
    
    return url
}

func getCardData(cardId: String, _ completion: @escaping (Result<Card, Error>) -> Void)->  Void {
    let url = fetchCardInfoURL(cardId: cardId)
    let request = basicSKCRequest(url: url)
    
    URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
        if (error != nil) {
            print("Error occurred while calling SKC API \(error!.localizedDescription)")
        } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
            print("Card \(cardId) not found in database.")
        }else {
            do {
                let cardData = try JSONDecoder().decode(Card.self, from: data!)
                completion(.success(cardData))
            } catch {
                print("An error ocurred while decoding output from SKC API \(error.localizedDescription)")
            }
        }
    }).resume()
}
