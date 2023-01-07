//
//  ProductTableViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/7/23.
//

import SwiftUI

struct ProductTableViewModel: View {
    private let currencyStyle = Decimal.FormatStyle.Currency(code:"USD")

    var body: some View {
        
            Table(of: Purchase.self) {
                TableColumn("Base price") { purchase in
                    Text(purchase.price, format: currencyStyle)
                }
                TableColumn("With 15% tip") { purchase in
                    Text(purchase.price * 1.15, format: currencyStyle)
                }
                TableColumn("With 20% tip") { purchase in
                    Text(purchase.price * 1.2, format: currencyStyle)
                }
                TableColumn("With 25% tip") { purchase in
                    Text(purchase.price * 1.25, format: currencyStyle)
                }
            } rows: {
                TableRow(Purchase(price:20))
                TableRow(Purchase(price:50))
                TableRow(Purchase(price:75))
            }
        }
    
}

private struct Purchase: Identifiable {
    let price: Decimal
    let id = UUID()
}

struct ProductTableViewModel_Previews: PreviewProvider {
    static var previews: some View {
        ProductTableViewModel()
    }
}
