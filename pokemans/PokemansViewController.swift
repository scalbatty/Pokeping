//
//  PokemansTableViewController.swift
//  pokemans
//
//  Created by Pascal Batty on 10/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class PokemansViewController: UIViewController {
    
    let couchbase = Couchbase.sharedInstance
    
    var query:CBLLiveQuery!
    
    var pokemanIDs:[String] = []
    
    let dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfPokepingRow>()
    let disposeBag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addPokémanButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
        subscribeToPokemans()
        
        addPokémanButton.rx.tap.subscribe(onNext: { [weak self] in self?.addNewPokéman() }).addDisposableTo(disposeBag)
    }
    
    func configureDataSource() {
        dataSource.configureCell = { [weak self] dataSource, tableView, indexPath, pokePing in
            let cell = tableView.dequeueReusableCell(withIdentifier: "pokemanCell", for: indexPath)
            
            let pokePingID = pokePing.documentID
            guard let pokePingDocument = self?.couchbase.database.document(withID: pokePingID)! else {
                return cell
            }
            let ping = Pokeping(for:pokePingDocument)
            
            cell.textLabel?.text = ping.pokemon
            cell.detailTextLabel?.text = ping.date.description
            
            return cell
        }
    }
    
    func subscribeToPokemans() {
        if let previousQuery = self.query {
            previousQuery.stop()
            previousQuery.removeObserver(self, forKeyPath: "rows")
        }
        let query = couchbase.pokemanView.createQuery()
        query.descending = true
        
        let liveQuery = query.asLive()
        let sectionObservable = liveQuery.rx
            .observe(CBLQueryEnumerator.self, "rows")
            .throttle(0.1, scheduler:MainScheduler.instance)
            .filter { $0 != nil }.map { $0! }
            .map { $0.allDocumentIds() }
            .map { [SectionOfPokepingRow(name:"Pokeping", documentIDs:$0)] }
        
        liveQuery.start()
        self.query = liveQuery
        couchbase.startReplications()
        
        sectionObservable.bindTo(self.tableView.rx.items(dataSource:dataSource))
            .addDisposableTo(disposeBag)
    }
    
    func addNewPokéman() {
        try! createPokeman(username: "NewTwo", pokeman: "Piafabec", place: "Gare de l'Est", in: couchbase.database)
    }
    
    @IBAction func addButtonTapped(sender:AnyObject) {
        
        try! createPokeman(username: "NewTwo", pokeman: "Piafabec", place: "Gare de l'Est", in: couchbase.database)
    }


}
