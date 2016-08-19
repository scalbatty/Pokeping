//
//  Pokeman.swift
//  pokemans
//
//  Created by Pascal Batty on 03/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation

@objc(Pokeping)
class Pokeping : CBLModel {
    @NSManaged var username: String!
    @NSManaged var pokemon: String!
    @NSManaged var place: String!
    @NSManaged var date: Date!
}

