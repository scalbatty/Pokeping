//
//  CouchbaseConfig.swift
//  pokemans
//
//  Created by Pascal Batty on 03/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation

class Couchbase {
    private let manager: CBLManager
    let database: CBLDatabase
    var pokemanView: CBLView {
        let view = database.viewNamed("allPokemans")
        
        guard view.mapBlock == nil else { return view }
        
        view.setMapBlock({ (doc, emit) in
            if let type = doc["type"] as? String, type == "pokeman",
                let name = doc["name"] {
                emit(name, nil)
            }
        }, version: "1")
        
        return view
    }
    
    static let sharedInstance: Couchbase = Couchbase()
    
    private init() {
        let manager = CBLManager.sharedInstance()
        self.manager = manager
        
        do {
            let oldDatabase = try self.manager.databaseNamed("pokemans")
            try oldDatabase.delete()
            let database = try self.manager.databaseNamed("pokemans")
            
            if let factory = database.modelFactory {
                factory.registerClass(Pokeman.self, forDocumentType: "pokeman")
            }
            
            addSomePokemans(in: database)
            
            self.database = database
        }
        catch let error as NSError {
            fatalError("Could not create database. Message: \(error.localizedDescription)")
        }
    }
}

func addSomePokemans(in database:CBLDatabase) {
    
    do {
        try createPokeman(name:"Roucouple", type:"Vol", number:2, in:database)
        try createPokeman(name:"Bulbisou", type:"Calin", number:1, in:database)
        try createPokeman(name:"Pikachok", type:"Electro", number:3, in:database)
    }
    catch let error as NSError {
        print("Could not save some pokemans: \(error.localizedDescription)")
    }
}

func createPokeman(name:String, type:String, number:Int?, in database:CBLDatabase) throws {
    let pokeman = Pokeman(forNewDocumentIn: database)
    
    pokeman.name = name
    pokeman.pokemonType = type
    pokeman.pokedexNumber = number
    
    try pokeman.save()
    print("Saved this Pokeman! \(pokeman.document?.documentID) \(pokeman.document?.properties)")
}

