//
//  CBLExtensions.swift
//  pokemans
//
//  Created by Pascal Batty on 10/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation
import RxSwift

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

extension CBLLiveQuery {
    
    var rowObservable: Observable<CBLQueryEnumerator> {
        return self.rx.observe(CBLQueryEnumerator.self, "rows").do(onSubscribe: { [weak self] in self?.start() }, onDispose: { [weak self] in self?.stop() })
            .filter { $0 != nil }.map { $0! }
    }
    
}
