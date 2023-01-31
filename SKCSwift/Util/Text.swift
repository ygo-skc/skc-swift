//
//  Text.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/18/23.
//

import Foundation

func replaceHTMLEntities(subject: String) -> String {
    return subject
        .replacingOccurrences(of: "&bull;", with: "•")
}
