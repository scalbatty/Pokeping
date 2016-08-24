//
//  Pokeman.swift
//  pokemans
//
//  Created by Pascal Batty on 03/08/2016.
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


let pokeman_number_range = 1...22

struct Pokéman {
    let number:Int
}

extension Pokéman {
    fileprivate var nameKey:String {
        return "Pokeman_\(number)"
    }
    
    fileprivate var imageName:String {
        return "pokemon_\(number-1)"
    }
}

extension Pokéman {
    static var all: [Pokéman] {
        return pokeman_number_range.map(Pokéman.init(number:))
    }
}

extension Pokéman {
    var localizedName: String {
        return NSLocalizedString(nameKey, tableName: "Pokemans", comment:"Pokéman \(number)")
    }
    
    var picture: UIImage? {
        return UIImage.init(named: imageName)
    }
}
