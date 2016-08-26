//
//  Pokeman.swift
//  pokemans
//
//  Created by Pascal Batty on 03/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation


let pokeman_number_range = 1...22

class Pokéman: NSObject {
    let number:Int
    
    init(number: Int) {
        self.number = number
    }
    
    fileprivate var nameKey:String {
        return "Pokeman_\(number)"
    }
    
    fileprivate var imageName:String {
        return "pokemon_\(number-1)"
    }
    
    static var all: [Pokéman] {
        return pokeman_number_range.map(Pokéman.init(number:))
    }

    var localizedName: String {
        return NSLocalizedString(nameKey, tableName: "Pokemans", comment:"Pokéman \(number)")
    }
    
    var picture: UIImage? {
        return UIImage.init(named: imageName)
    }
}
