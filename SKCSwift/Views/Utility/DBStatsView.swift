//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct DBStatsView: View {
    var body: some View {
        VStack {
            Text("All data is provided by a collection of API's/DB's designed to provide the best Yu-Gi-Oh! information")
                .font(.body)
            
            Text("DB Stats")
                .font(.title2)
                .padding(.vertical, 2)
            HStack {
                DBStatView(count: "10,993", stat: "Cards")
                    .padding(.horizontal)
                DBStatView(count: "47", stat: "Ban Lists")
                    .padding(.horizontal)
                DBStatView(count: "285", stat: "Products")
                    .padding(.horizontal)
            }
        }
    }
}


private struct DBStatView: View {
    var count: String
    var stat: String
    
    var body: some View {
        VStack {
            Text(count)
                .font(.title3)
            Text(stat)
                .font(.headline)
                .fontWeight(.heavy)
        }
    }
}

struct DBStatsView_Previews: PreviewProvider {
    static var previews: some View {
        DBStatsView()
    }
}
