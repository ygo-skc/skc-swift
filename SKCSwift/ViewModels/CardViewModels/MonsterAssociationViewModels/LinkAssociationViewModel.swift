//
//  LinkAssociationViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/20/23.
//

import SwiftUI

struct LinkAssociationViewModel: View {
    var linkRating: Int
    var linkArrows: String
    
    init(linkRating: Int, linkArrows: [String]) {
        self.linkRating = linkRating
        self.linkArrows = linkArrows.joined(separator: " ")
    }
    
    var body: some View {
        HStack {
            Text("L\(linkRating): \(linkArrows)")
                .fontWeight(.bold)
        }
    }
}

struct LinkAssociationViewModel_Previews: PreviewProvider {
    static var previews: some View {
        LinkAssociationViewModel(linkRating: 4, linkArrows: ["↙️","↘️"])
    }
}
