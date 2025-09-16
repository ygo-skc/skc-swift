//
//  Numbers.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/28/23.
//

import Foundation

struct Numbers {
    static let decimalNumberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()
}

extension Int {
    // formats int by adding commas to number. Returns empty string by default
    var decimal: String { Numbers.decimalNumberFormatter.string(from: NSNumber(value: self)) ?? "" }
}
