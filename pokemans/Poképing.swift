//
//  Poképing.swift
//  pokemons
//
//  Created by Pascal Batty on 26/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation

@objc(Pokeping)
class Poképing : CBLModel {
    static let type:String = "pokeping"
    
    @NSManaged var username: String
    @NSManaged var date: Date
    @NSManaged var pokemon: Pokémon
    @NSManaged var lat: CDouble
    @NSManaged var lon: CDouble

}
