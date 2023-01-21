//
//  PendulumAssociation.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/20/23.
//

import SwiftUI

struct PendulumAssociation: View {
    var pendScale: Int
    
    private static let ICON_SIZE = 30.0
    
    var body: some View {
        HStack {
            Image("pend_scale")
                .resizable()
                .frame(width: PendulumAssociation.ICON_SIZE, height: PendulumAssociation.ICON_SIZE)
            Text("x\(pendScale)")
                .fontWeight(.semibold)
        }
    }
}

struct PendulumAssociation_Previews: PreviewProvider {
    static var previews: some View {
        PendulumAssociation(pendScale: 4)
    }
}
