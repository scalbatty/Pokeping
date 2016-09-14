//
//  DatatSource.swift
//  pokemons
//
//  Created by Pascal Batty on 19/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation
import RxDataSources

struct PoképingRow : IdentifiableType {
    typealias Identity = String
    
    var identity: Identity { return poképing.document!.documentID }
    var poképing: Poképing
    
}

extension PoképingRow: Equatable { }

func == (lhs: PoképingRow, rhs: PoképingRow) -> Bool {
    return lhs.poképing == rhs.poképing
}

struct SectionOfPoképingRow {
    var items: [Item]
    var name: String
}

extension SectionOfPoképingRow: AnimatableSectionModelType {
    typealias Item = PoképingRow
    typealias Identity = String
    
    var identity: Identity { return name }
    
    init(original: SectionOfPoképingRow, items: [Item]) {
        self = original
        self.items = items
    }
}

extension SectionOfPoképingRow {
    init(name: String, pings:[Poképing]) {
        self.name = name
        self.items = pings.map(PoképingRow.init(poképing:))
    }
}


