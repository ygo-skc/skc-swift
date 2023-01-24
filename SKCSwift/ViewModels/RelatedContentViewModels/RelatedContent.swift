//
//  RelatedContent.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/17/23.
//

import SwiftUI

protocol RelatedContent: View {}

struct CardViewButton<RC: RelatedContent>: View {
    var text: String
    var sheetContents: RC
    
    @State private var showSheet = false
    
    func sheetDismissed() {
        showSheet = false
    }
    
    var body: some View {
        
        Button {
            showSheet.toggle()
        } label: {
            HStack {
                Text(text)
            }
            .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: $showSheet, onDismiss: sheetDismissed) {
            sheetContents
        }
        .buttonStyle(.borderedProminent)
    }
}
