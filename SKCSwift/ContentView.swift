//
//  ContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/1/23.
//

import SwiftUI

let cardId = "90307498"
let imageUrl = URL(string: "https://images.thesupremekingscastle.com/cards/lg/\(cardId).jpg")

func getCardData(string: String)->  String {
    var request = URLRequest(url: URL(string: "https://skc-ygo-api.com/api/v1/card/\(cardId)?allInfo=true")!)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
//    var cardData: SKCCardInfoOutput
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
        if (error != nil) {
            print("Error occurred while calling SKC API \(error!.localizedDescription)")
        } else {
            do {
                let decoder = JSONDecoder()
                let cardData = try decoder.decode(SKCCardInfoOutput.self, from: data!)
            } catch {
                print("An error ocurred while decoding output from SKC API \(error.localizedDescription)")
            }
        }
    })
    
    task.resume()
    
    return "xxx"
}

struct CardInfo: View {
    
    var body: some View {
        VStack {
            Text(getCardData(string: cardId))
                .font(.title)
                .multilineTextAlignment(.leading)
                .bold()
            AsyncImage(url: imageUrl)
                .cornerRadius(50.0)
        }
    }
}

struct CardInfo_Previews: PreviewProvider {
    static var previews: some View {
        CardInfo()
    }
}

struct SKCMonsterAssociation: Codable {
    var level: Int?
}

struct SKCCardInfoOutput: Codable {
    var cardID: String
    var cardName: String
    var cardColor: String
    var cardAttribute: String
    var cardEffect: String
    var monsterType: String?
    var monsterAssociation: SKCMonsterAssociation
    var monsterAttack: Int?
    var monsterDefense: Int?
}
