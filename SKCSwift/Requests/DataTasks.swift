//
//  SKCAPI.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

import Foundation

// SKC API Data Tasks

private func handleErrors(response: URLResponse?, error: Error?, url: URL) -> Bool {
    // handle error
    if let error = error {
        if (error.localizedDescription != "cancelled") {
            print("Error occurred while calling \(url.absoluteString) \(error.localizedDescription)")
        }
        return true
    }
    
    if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
            return false
        }
        if httpResponse.statusCode == 404 {
            print("404 status for url \(url.absoluteString).")
        }
        return true
    }
    
    return false
}

func getCardData(cardId: String, _ completion: @escaping (Result<Card, Error>) -> Void)->  Void {
    let url = cardInfoURL(cardId: cardId)
    let request = baseRequest(url: url)
    
    URLSession.shared.dataTask(with: request, completionHandler: { (body, response, error) -> Void in
        // handle errors
        let hasErrors = handleErrors(response: response, error: error, url: url)
        
        if let body = body, hasErrors == false {
            do {
                let cardData = try decoder.decode(Card.self, from: body)
                completion(.success(cardData))
            } catch {
                print("An error ocurred while decoding output from SKC API \(error.localizedDescription)")
            }
        }
    })
    .resume()
}

func searchCard(searchTerm: String, _ completion: @escaping (Result<[Card], Error>) -> Void)->  URLSessionDataTask {
    let url = searchCardURL(cardName: searchTerm)
    let request = baseRequest(url: url)
    
    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (body, response, error) -> Void in
        // handle errors
        let hasErrors = handleErrors(response: response, error: error, url: url)
        
        if let body = body, hasErrors == false {
            do {
                let cardData = try decoder.decode([Card].self, from: body)
                completion(.success(cardData))
            } catch {
                print("An error ocurred while decoding output from SKC API \(error.localizedDescription)")
            }
        } else {
            completion(.failure(error!))
        }
    })
    
    dataTask.priority = 1
    dataTask.resume()
    return dataTask
}

func getDBStatsTask(_ completion: @escaping (Result<SKCDatabaseStats, Error>) -> Void)->  Void {
    let url = dbStatsURL()
    let request = baseRequest(url: url)
    
    URLSession.shared.dataTask(with: request, completionHandler: { (body, response, error) -> Void in
        // handle errors
        let hasErrors = handleErrors(response: response, error: error, url: url)
        
        if let body = body, hasErrors == false {
            do {
                let stats = try decoder.decode(SKCDatabaseStats.self, from: body)
                completion(.success(stats))
            } catch {
                print("An error ocurred while decoding output from SKC API \(error.localizedDescription)")
            }
        } else {
            completion(.failure(error!))
        }
    })
    .resume()
}

// SKC API Data Tasks

func getCardSuggestionsTask(cardId: String, _ completion: @escaping (Result<CardSuggestions, Error>) -> Void)->  Void {
    let url = cardSuggestionsURL(cardId: cardId)
    let request = baseRequest(url: url)
    
    URLSession.shared.dataTask(with: request, completionHandler: { (body, response, error) -> Void in
        // handle errors
        let hasErrors = handleErrors(response: response, error: error, url: url)
        
        if let body = body, hasErrors == false {
            do {
                let cardData = try decoder.decode(CardSuggestions.self, from: body)
                completion(.success(cardData))
            } catch {
                print("An error ocurred while decoding output from SKC Suggestion Engine \(error)")
            }
        }
    })
    .resume()
}

func getCardOfTheDayTask(_ completion: @escaping (Result<CardOfTheDay, Error>) -> Void)->  Void {
    let url = cardOfTheDayURL()
    let request = baseRequest(url: url)
    
    URLSession.shared.dataTask(with: request, completionHandler: { (body, response, error) -> Void in
        // handle errors
        let hasErrors = handleErrors(response: response, error: error, url: url)
        
        if let body = body, hasErrors == false {
            do {
                let cardOfTheDay = try decoder.decode(CardOfTheDay.self, from: body)
                completion(.success(cardOfTheDay))
            } catch {
                print("An error ocurred while decoding output from SKC Suggestion Engine \(error)")
            }
        }
    })
    .resume()
}
