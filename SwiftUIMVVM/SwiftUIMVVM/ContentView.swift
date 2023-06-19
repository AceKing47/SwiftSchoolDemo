//
//  ContentView.swift
//  SwiftUIMVVM
//
//  Created by Gerrit Zeissl on 27.05.22.
//

import SwiftUI

extension Double {
    func formatAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}

struct ContentView: View {
    
    // Allows to listen to events, emmited by Published
    @StateObject var viewModel = StockListViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.stocks, id: \.symbol) { stock in
                HStack {
                    Text(stock.symbol)
                    Spacer()
                    VStack {
                        Text("\(stock.price.formatAsCurrency())")
                        Text("\(stock.description)")
                    }
                }
            }.task {
                await viewModel.populateStocks()
            }
            //.onAppear() {
            //            Task {
            //                await viewModel.populateStocks()
            //            }
            //        }
            .navigationTitle("Stocks")
            .refreshable { // pull to refresh
                await viewModel.populateStocks()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// M - Model - Business Logic
// V - View - Things on screen
// VM - Viewmodel - providing data to view
