//
//  Webservice.swift
//  SwiftUIMVVM
//
//  Created by Gerrit Zeissl on 27.05.22.
//

import Foundation

enum NetworkError: Error {
    case badRequest
}

class Webservice {
    
    func loadStocks(url: URL) async throws -> [Stock] {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.badRequest
        }
        
        return try JSONDecoder().decode([Stock].self, from: data)
    }
}
