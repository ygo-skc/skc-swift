//
//  SKCAPI.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

import Foundation

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

func request<T: Codable>(url: URL, priority: Float = 1, _ completion: @escaping (Result<T, Error>) -> Void) ->  Void {
    _ = requestTask(url: url, completion)
}

func requestTask<T: Codable>(url: URL, priority: Float = 1, _ completion: @escaping (Result<T, Error>) -> Void) ->  URLSessionDataTask {
    let request = baseRequest(url: url)
    
    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (body, response, error) -> Void in
        // handle errors
        let hasErrors = handleErrors(response: response, error: error, url: url)
        
        if let body = body, hasErrors == false {
            do {
                let cardData = try RequestHelpers.decoder.decode(T.self, from: body)
                completion(.success(cardData))
            } catch {
                print("An error ocurred while decoding output from http request \(error.localizedDescription)")
            }
        }
    })
    
    dataTask.priority = 1
    dataTask.resume()
    return dataTask
}
