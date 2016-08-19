//
//  CBLExtensions.swift
//  pokemans
//
//  Created by Pascal Batty on 10/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation

extension CBLQueryEnumerator {
    
    func allDocumentIds() -> [String] {
        
        return self.map { element in
            let row = element as! CBLQueryRow
            return row.documentID!
        }
        
    }
}
