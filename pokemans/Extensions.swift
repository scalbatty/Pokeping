//
//  Extensions.swift
//  pokemons
//
//  Created by Pascal Batty on 19/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation

extension Date {
    var timestamp: Double { return self.timeIntervalSince1970 * 1000 }
}

extension CBLQueryEnumerator {
    
    func allDocumentIds() -> [String] {
        
        return self.map { element in
            let row = element as! CBLQueryRow
            return row.documentID!
        }
        
    }
    
    func allDocuments() -> [CBLDocument] {
        return self.flatMap({ element in
            let row = element as! CBLQueryRow
            return row.document
        })
    }
}
