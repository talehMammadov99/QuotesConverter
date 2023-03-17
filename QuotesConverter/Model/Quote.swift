//
//  Quote.swift
//  QuotesConverter
//
//  Created by Taleh Mammadov on 17.03.23.
//

import Foundation

struct Quote: Decodable {
    let symbol: String
    let buyPrice: Int
    let sellPrice: Int
    let spread: Int
}
