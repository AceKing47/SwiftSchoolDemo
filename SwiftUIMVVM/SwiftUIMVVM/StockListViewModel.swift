//
//  StockListViewModel.swift
//  SwiftUIMVVM
//
//  Created by Gerrit Zeissl on 27.05.22.
//

import Foundation

// This is the view model, providing data to to put on content view
// Container view model for entire screen
class StockListViewModel: ObservableObject {
    
    // Published (inside ObservableObject), whenever something assigned, event is triggered, view catches it and will reload itself
    // Always set on main thread!
    @Published var stocks: [StockViewModel] = []
    
    func populateStocks() async {
        do {
            let stocks = try await Webservice().loadStocks(url: URL(string: "http://island-bramble.glitch.me/latest-stocks")!)
            
            DispatchQueue.main.async {
                self.stocks = stocks.map(StockViewModel.init)
            }
        } catch {
            print(error)
        }
    }
}


// View model representing individual stock

struct StockViewModel {
    
    private var stock: Stock // view should have no access
    
    init(stock: Stock) {
        self.stock = stock
    }
    
    var symbol: String {
        stock.symbol
    }
    
    var price: Double {
        stock.price
    }
    
    var description: String {
        stock.description
    }
}


