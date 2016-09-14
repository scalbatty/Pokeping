//
//  PokemonsTableViewController.swift
//  pokemons
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
    
    let pokémonsSections: Observable<[SectionOfPoképingRow]>
    let createPoképing: (Pokémon, CLLocationCoordinate2D) -> Poképing
    
    init(couchbase: Couchbase) {
        let query = PoképingViewModel.createQuery(inBase: couchbase)
        
        self.pokémonsSections = PoképingViewModel.createSectionObservable(fromQuery: query)
        
        createPoképing = { (pokémon, location) in
            let ping = Poképing(forNewDocumentIn: couchbase.database)
            
            ping.username = "Sacha"
            ping.pokemon = pokémon
            ping.date = Date()
            ping.lat = CDouble(location.latitude)
            ping.lon = CDouble(location.longitude)
            
            print ("Created poképing for id \(ping.pokemon.number) at location \(location)")
            
            return ping
        }
    }
    
    static func createQuery(inBase couchbase: Couchbase) -> CBLQuery {
        let query = couchbase.pokepingView.createQuery()
        query.descending = true
        return query
    }
    
    static func createSectionObservable(fromQuery query:CBLQuery) -> Observable<[SectionOfPoképingRow]> {
        return query.asLive().rx.rows
            .throttle(0.5, scheduler:MainScheduler.instance)
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
    @IBOutlet weak var addPokémonButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let passedFirstLaunch = UserDefaults.standard.bool(forKey: "FirstLaunch")
        if (!passedFirstLaunch) {
            let cbl = Couchbase.sharedInstance
            addSomePokemons(in: cbl.database)
            UserDefaults.standard.set(true, forKey: "FirstLaunch")
        }

        
        configureDataSource()
        viewModel.pokémonsSections.bindTo(self.tableView.rx.items(dataSource:dataSource))
            .addDisposableTo(disposeBag)
        
        let geoLoc = geolocationService.location.asObservable().observeOn(MainScheduler.instance)
        
        geoLoc.map { _ in return true }.take(1).bindTo(addPokémonButton.rx.enabled).addDisposableTo(disposeBag);
        addPokémonButton.isEnabled = false;
        
        let pokémonSelection = addPokémonButton.rx.tap
            .flatMapLatest {[weak self] _ in
                return Reactive<PokémonPickerController>.create(parent: self)
                    .flatMap { $0.rx.didSelectPokémon }.take(1)
            }
            .do(onNext: {[weak self] _ in self?.dismiss(animated: true, completion: nil) })
            .observeOn(MainScheduler.instance)
        
        pokémonSelection.withLatestFrom(geoLoc, resultSelector: self.viewModel.createPoképing)
            .bindNext { poképing in try!poképing.save() }
            .addDisposableTo(disposeBag)
    }
    
    func configureDataSource() {
        dataSource.configureCell = { dataSource, tableView, indexPath, row in
            let cell = tableView.dequeueReusableCell(withIdentifier: "PoképingCell", for: indexPath)
            
            let ping = row.poképing
            cell.textLabel?.text = ping.pokemon.name
            cell.imageView?.image = ping.pokemon.picture
            cell.detailTextLabel?.text = ping.date.description
            
            return cell
        }
    }
}
