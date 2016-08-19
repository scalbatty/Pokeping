//
//  DatatSource.swift
//  pokemans
//
//  Created by Pascal Batty on 19/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation
import RxDataSources

struct PokepingRow {
    var documentID:String
}

struct SectionOfPokepingRow {
    var items: [Item]
}

extension SectionOfPokepingRow: SectionModelType {
    typealias Item = PokepingRow
    
    init(original: SectionOfPokepingRow, items: [Item]) {
        self = original
        self.items = items
    }
}
