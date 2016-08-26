//
//  CBLExtensions.swift
//  pokemans
//
//  Created by Pascal Batty on 10/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa



extension Reactive where Base:CBLLiveQuery {

    var rows: Observable<CBLQueryEnumerator> {
        return self.observe(CBLQueryEnumerator.self, "rows")
            .do(onSubscribe: { [weak base] in base?.start() },
                onDispose: { [weak base] in base?.stop() })
            .filter { $0 != nil }.map { $0! }
    }
}
