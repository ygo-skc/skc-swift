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
        let code = httpResponse.statusCode
        if code <= 201 {
            return false
        }
        
        print("Encountered status code \(code) while calling \(url.absoluteString).")
        return true
    }
    
    return false
}

func request<T: Codable>(url: URL, priority: Float = 1, _ completion: @escaping (Result<T, Error>) -> Void) ->  Void {
    _ = requestTask(url: url, priority: priority, completion)
}

func requestTask<T: Codable>(url: URL, priority: Float = 1, _ completion: @escaping (Result<T, Error>) -> Void) ->  URLSessionDataTask {
    let request = baseRequest(url: url)
    
    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (body, response, error) -> Void in
        // handle errors
        let hasErrors = handleErrors(response: response, error: error, url: url)
        
        if let body = body, hasErrors == false {
            do {
                let body = try RequestHelpers.decoder.decode(T.self, from: body)
                completion(.success(body))
            } catch {
                print("An error ocurred while decoding output from http request \(error.localizedDescription)")
            }
        }
    })
    
    dataTask.priority = priority
    dataTask.resume()
    return dataTask
}
