//
//  ContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/1/23.
//

import SwiftUI

let cardId = "40044918"
let imageUrl = URL(string: "https://images.thesupremekingscastle.com/cards/lg/\(cardId).jpg")

func getCardData(string: String)->  String {
    var request = URLRequest(url: URL(string: "https://skc-ygo-api.com/api/v1/card/\(cardId)?allInfo=true")!)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
        print(response!)
        do {
            let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
            print(json)
        } catch {
            print("error")
        }
    })
    
    task.resume()
    
    return "YOOOO"
}

struct CardInfo: View {
    
    var body: some View {
        VStack {
            Text(getCardData(string: cardId))
                .font(.title)
                .bold()
            AsyncImage(url: imageUrl)
                .cornerRadius(100.0)
//                .aspectRatio(contentMode: .fill)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CardInfo()
    }
}
