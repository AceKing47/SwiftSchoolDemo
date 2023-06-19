//
//  Stock.swift
//  SwiftUIMVVM
//
//  Created by Gerrit Zeissl on 27.05.22.
//

import Foundation

// This is a model (dto)

struct Stock: Decodable {
    let symbol: String
    let description: String
    let price: Double
}
