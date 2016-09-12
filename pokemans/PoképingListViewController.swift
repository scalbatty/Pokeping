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
import Action
import CoreLocation


struct PoképingViewModel {
    
    let pokémansSections: Observable<[SectionOfPoképingRow]>
    let createPoképing: (Pokéman, CLLocationCoordinate2D) -> Poképing
    
    init(couchbase: Couchbase) {
        let query = PoképingViewModel.createQuery(inBase: couchbase)
        
        self.pokémansSections = PoképingViewModel.createSectionObservable(fromQuery: query)
        
        createPoképing = { (pokéman, location) in
            let ping = Poképing(forNewDocumentIn: couchbase.database)
            
            ping.username = "Sacha"
            ping.pokemonNumber = String(pokéman.number)
            ping.place = "\(location)"
            ping.date = Date()
            
            print ("Created poképing for id \(ping.pokemonNumber) at location \(location)")
            
            return ping
        }
    }
    
    static func createQuery(inBase couchbase: Couchbase) -> CBLQuery {
        let query = couchbase.pokemanView.createQuery()
        query.descending = true
        return query
    }
    
    static func createSectionObservable(fromQuery query:CBLQuery) -> Observable<[SectionOfPoképingRow]> {
        return query.asLive().rx.rows
            .throttle(0.1, scheduler:MainScheduler.instance)
            .map { $0.allDocuments().map(Poképing.init(for:)) }
            .map { [SectionOfPoképingRow(name:"Pokeping", pings:$0)] }
    }
}

class PoképingListViewController: UIViewController {
    
    let viewModel = PoképingViewModel(couchbase: Couchbase.sharedInstance)
    let dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfPoképingRow>()
    let disposeBag = DisposeBag()
    let couchbase = Couchbase.sharedInstance
    let geolocationService = GeolocationService.instance

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addPokémanButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
        viewModel.pokémansSections.bindTo(self.tableView.rx.items(dataSource:dataSource))
            .addDisposableTo(disposeBag)
        
        let geoLoc = geolocationService.location.asObservable().observeOn(MainScheduler.instance)
        
        geoLoc.map { _ in return true }.take(1).bindTo(addPokémanButton.rx.enabled).addDisposableTo(disposeBag);
        addPokémanButton.isEnabled = false;
        
        let pokémanSelection = addPokémanButton.rx.tap
            .flatMapLatest {[weak self] _ in
                return Reactive<PokémanPickerController>.create(parent: self)
                    .flatMap { $0.rx.didSelectPokéman }.take(1)
            }
            .do(onNext: {[weak self] _ in self?.dismiss(animated: true, completion: nil) })
            .observeOn(MainScheduler.instance)
        
        pokémanSelection.withLatestFrom(geoLoc, resultSelector: self.viewModel.createPoképing)
            .bindNext { poképing in try!poképing.save() }
            .addDisposableTo(disposeBag)
    }
    
    func configureDataSource() {
        dataSource.configureCell = { dataSource, tableView, indexPath, row in
            let cell = tableView.dequeueReusableCell(withIdentifier: "pokemanCell", for: indexPath)
            
            let ping = row.poképing
            cell.textLabel?.text = ping.pokéman?.localizedName
            cell.imageView?.image = ping.pokéman?.picture
            cell.detailTextLabel?.text = ping.date.description
            
            return cell
        }
    }
}
