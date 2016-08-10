//
//  Pokeman.swift
//  pokemans
//
//  Created by Pascal Batty on 03/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation

@objc(Pokeman)
class Pokeman : CBLModel {
    @NSManaged var name: String!
    @NSManaged var pokemonType: String!
    @NSManaged var pokedexNumber: NSNumber!
}
