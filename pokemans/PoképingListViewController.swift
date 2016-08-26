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




struct PoképingViewModel {
    
    let pokémansSections: Observable<[SectionOfPoképingRow]>
    
    init(couchbase: Couchbase) {
        let query = PoképingViewModel.createQuery(inBase: couchbase)
        self.pokémansSections = PoképingViewModel.createSectionObservable(fromQuery: query)
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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addPokémanButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
        viewModel.pokémansSections.bindTo(self.tableView.rx.items(dataSource:dataSource))
            .addDisposableTo(disposeBag)
        
        addPokémanButton.rx.tap
            .flatMapLatest {[weak self] _ in
                return Reactive<PokémanPickerController>.create(parent: self)
                    .flatMap { $0.rx.didSelectPokéman }.take(1)
            }
            .do(onNext: {[weak self] _ in self?.dismiss(animated: true, completion: nil) })
            .subscribe(onNext: { [weak self] pokéman in
                guard let strongSelf = self else { return }
                try! createPokeman(username: "Sacha", pokeman: pokéman.number, place: "Bibliothèque François Mitterrand", in: strongSelf.couchbase.database)
            
            }).addDisposableTo(disposeBag)
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
