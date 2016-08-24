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
    
    var pokemanView: CBLView {
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
    
    static let sharedInstance: Couchbase = Couchbase()
    
    private init() {
        let manager = CBLManager.sharedInstance()
        self.manager = manager
        
        do {
            let database = try self.manager.databaseNamed(Couchbase.base_name)
            
            if let factory = database.modelFactory {
                factory.registerClass(Poképing.self, forDocumentType: Poképing.type)
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
    
    do {
        try createPokeman(username:"Jean-Poulain", pokeman:16, place:"République", in:database)
        try createPokeman(username:"Mireille Trauma", pokeman:19, place:"Rue Quincampoix", in:database)
        try createPokeman(username:"Machicouli", pokeman:13, place:"Catacombes de Paris", in:database)
        try database.saveAllModels()
    }
    catch let error as NSError {
        print("Could not save some pokemans: \(error.localizedDescription)")
    }
}

func createPokeman(username:String, pokeman:Int, place:String, in database:CBLDatabase) throws {
    let ping = Poképing(forNewDocumentIn: database)
    
    ping.username = username
    ping.pokemonNumber = String(pokeman)
    ping.place = place
    ping.date = Date()
    
    try ping.save()
    print("Saved this Pokeman! \(ping.document?.documentID) \(ping.document?.properties)")
}

