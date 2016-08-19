//
//  DatatSource.swift
//  pokemans
//
//  Created by Pascal Batty on 19/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation
import RxDataSources

struct PokepingRow : IdentifiableType {
    typealias Identity = String
    
    var documentID:String
    var identity: Identity { return documentID }
    
}

extension PokepingRow: Equatable { }

func == (lhs: PokepingRow, rhs: PokepingRow) -> Bool {
    return lhs.documentID == rhs.documentID
}

struct SectionOfPokepingRow {
    var items: [Item]
    var name: String
}

extension SectionOfPokepingRow: AnimatableSectionModelType {
    typealias Item = PokepingRow
    typealias Identity = String
    
    var identity: Identity { return name }
    
    init(original: SectionOfPokepingRow, items: [Item]) {
        self = original
        self.items = items
    }
}

extension SectionOfPokepingRow {
    init(name:String, documentIDs: [String]) {
        self.name = name
        self.items = documentIDs.map(PokepingRow.init(documentID:))
    }
}


