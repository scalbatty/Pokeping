//
//  Pokeman.swift
//  pokemans
//
//  Created by Pascal Batty on 03/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation


let pokeman_number_range = 1...22

@objc(Pokeman)
class Pokéman: CBLModel {
    
    static let type:String = "pokemon"
    
    @NSManaged var number:String
    @NSManaged var name:String
    
    fileprivate var imageName:String {
        return "pokemon_\(Int(number)!-1)"
    }
    
    var picture: UIImage? {
        return UIImage.init(named: imageName)
    }
}
