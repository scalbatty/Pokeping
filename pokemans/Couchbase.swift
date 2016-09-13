//
//  CouchbaseConfig.swift
//  pokemans
//
//  Created by Pascal Batty on 03/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import Foundation

class Couchbase {
    
    private static let base_name = "pokemans"
    private static let pokeman_type = "pokeman"
    private static let syncgateway_host = "http://localhost:4984/"
    private static let syncgateway_address = syncgateway_host + base_name
    private static let syncgateway_url = URL(string: syncgateway_address)!
    
    private let manager: CBLManager
    let database: CBLDatabase
    
    var pokepingView: CBLView {
        let view = database.viewNamed("allPokepings")
        
        guard view.mapBlock == nil else { return view }
        
        view.setMapBlock({ (doc, emit) in
            if let type = doc["type"] as? String, type == Poképing.type,
                let date = doc["date"] {
                emit(date, nil)
            }
        }, version: "8")
        
        return view
    }
    
    var pokémanView: CBLView {
        let view = database.viewNamed("allPokemans")
        
        guard view.mapBlock == nil else { return view }
        
        view.setMapBlock({ (doc, emit) in
            if let type = doc["type"] as? String, type == Pokéman.type,
                let number = doc["number"], let name = doc["name"] as? String {
                emit(CBLTextKey(name), number)
            }
            }, version: "4")
        
        return view
    }
    
    static let sharedInstance: Couchbase = Couchbase()
    
    private init() {
        let manager = CBLManager.sharedInstance()
        self.manager = manager
        
        do {
            let database = try self.manager.databaseNamed(Couchbase.base_name)
            
            if let factory = database.modelFactory {
                factory.registerClass(Poképing.self, forDocumentType: Poképing.type)
                factory.registerClass(Pokéman.self, forDocumentType: Pokéman.type)
            }
            
            self.database = database
            
            startReplications()
        }
        catch let error as NSError {
            fatalError("Could not create database. Message: \(error.localizedDescription)")
        }
    }
    
    public func startReplications() {
        let pull = self.database.createPullReplication(Couchbase.syncgateway_url)
        let push = self.database.createPushReplication(Couchbase.syncgateway_url)
        
        pull.continuous = true
        push.continuous = true
        
        pull.start()
        push.start()
    }
}

func addSomePokemans(in database:CBLDatabase) {
    
    let map = [("1" , "Bulbizarre"),
               ("2" , "Herbizarre"),
               ("3" , "Florizarre"),
               ("4" , "Salamèche"),
               ("5" , "Reptincel"),
               ("6" , "Dracaufeu"),
               ("7" , "Carapuce"),
               ("8" , "Carabaffe"),
               ("9" , "Tortank"),
               ("10" , "Chenipan"),
               ("11" , "Chrysacier"),
               ("12" , "Papilusion"),
               ("13" , "Aspicot"),
               ("14" , "Coconfort"),
               ("15" , "Dardagnan"),
               ("16" , "Roucool"),
               ("17" , "Roucoups"),
               ("18" , "Roucarnage"),
               ("19" , "Rattata"),
               ("20" , "Rattatac"),
               ("21" , "Piafabec"),
               ("22" , "Rapasdepic")]
    
    do {
        for (number, name) in map {
            try createPokeman(number: number, name: name, in: database)
        }
        try database.saveAllModels()
    }
    catch let error as NSError {
        print("Could not save some pokemans: \(error.localizedDescription)")
    }
}

func createPokeman(number:String, name:String, in database:CBLDatabase) throws {
    let pokéman = Pokéman(forNewDocumentIn: database)
    pokéman.number = number
    pokéman.name = name
    
    try pokéman.save()
}
