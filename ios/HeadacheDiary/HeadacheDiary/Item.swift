//
//  Item.swift
//  HeadacheDiary
//
//  Created by Hiroshi Murakami on 2026/09/11.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
