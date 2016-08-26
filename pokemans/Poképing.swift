//
//  Poképing.swift
//  pokemans
//
//  Created by Pascal Batty on 26/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation

@objc(Pokeping)
class Poképing : CBLModel {
    static let type:String = "pokeping"
    
    @NSManaged var username: String!
    @NSManaged var pokemonNumber: String!
    @NSManaged var place: String!
    @NSManaged var date: Date!
}

extension Poképing {
    var pokéman: Pokéman? {
        guard let number = Int(pokemonNumber) else {
            return nil
        }
        return Pokéman(number: number)
    }
}
