//
//  Extensions.swift
//  pokemans
//
//  Created by Pascal Batty on 19/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation

extension Date {
    var timestamp: Double { return self.timeIntervalSince1970 * 1000 }
}
