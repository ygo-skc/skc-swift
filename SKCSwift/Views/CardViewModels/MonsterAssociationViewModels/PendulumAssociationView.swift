//
//  PendulumAssociation.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/20/23.
//

import SwiftUI

struct PendulumAssociationView: View {
    var pendScale: Int
    
    private static let ICON_SIZE = 30.0
    
    var body: some View {
        HStack {
            Image("pend_scale")
                .resizable()
                .frame(width: PendulumAssociationView.ICON_SIZE, height: PendulumAssociationView.ICON_SIZE)
            Text("x\(pendScale)")
                .fontWeight(.semibold)
        }
    }
}

struct PendulumAssociationView_Previews: PreviewProvider {
    static var previews: some View {
        PendulumAssociationView(pendScale: 4)
    }
}
