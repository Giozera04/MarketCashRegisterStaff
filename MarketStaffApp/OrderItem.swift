//
//  OrderItem.swift
//  MarketStaffApp
//
//  Created by Giovane Junior on 8/4/25.
//

import Foundation


struct OrderItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let quantity: Int
    let price: Double
    let barcode: String
    let imageUrl: String?
}
