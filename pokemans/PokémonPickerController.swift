//
//  PoképingCreationViewController.swift
//  pokemons
//
//  Created by Pascal Batty on 22/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

@objc protocol PokémonPickerDelegate: AnyObject {
    @objc optional func pokémonPicker(_ :PokémonPickerController, didSelectPokémon: Pokémon)
}


class PokémonCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
}

struct PokémonError:Error {}

struct PokémonViewModel {
    
    private let view:CBLView
    public var searchText:Observable<String>?
    
    init(couchbase: Couchbase) {
        self.view = Couchbase.sharedInstance.pokémonView
    }
    
    func searchResults() -> Observable<[Pokémon]> {
        
        guard let searchText = searchText else {
            return Observable.never()
        }
        
        return searchText.map { (text) -> [Pokémon] in
            guard text.characters.count > 0 else {
                return []
            }
            let query = self.view.createQuery()
            query.descending = false
            query.fullTextQuery = text + "*"
            
            guard let result = try? query.run() else {
                return []
            }

            return result.allDocuments().map(Pokémon.init)
        }
    }
    
}

@objc class PokémonPickerController: UIViewController {
    
    weak var delegate:PokémonPickerDelegate?
    let dataSource = Observable<[Pokémon]>.just([])
    let disposeBag = DisposeBag()
    var viewModel = PokémonViewModel(couchbase: Couchbase.sharedInstance)
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.searchText = searchBar.rx.text
                        .throttle(0.3, scheduler: MainScheduler.instance)
                        .distinctUntilChanged()
                        .do(onNext: { print("Text entered: \($0)") })
        
        viewModel.searchResults()
            .do(onNext: { print("Search results: \($0)") })
            .bindTo(collectionView.rx.items(cellIdentifier:"PokémonCell")) { index, model, cell in
            
            guard let cell = cell as? PokémonCell else { return }
            
            cell.imageView.image = model.picture
            
        }.addDisposableTo(disposeBag)

        collectionView.rx.modelSelected(Pokémon.self)
            .do(onNext: { [weak self] _ in self?.dismiss(animated: true, completion: nil) })
            .subscribe(onNext: { [weak self] pokémon in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }
            
            delegate.pokémonPicker?(strongSelf, didSelectPokémon: pokémon)
            
            }).addDisposableTo(disposeBag)
        
        closeButton.rx.tap
            .do(onNext: { [weak self] _ in self?.dismiss(animated: true, completion: nil) })
            .subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.becomeFirstResponder()
    }
}


extension Reactive where Base:PokémonPickerController {
    
    var delegate: DelegateProxy {
        return RxPokémonPickerDelegateProxy.proxyForObject(base)
    }
    
    static func create(parent: UIViewController?) -> Observable<PokémonPickerController> {
        return Observable.create { [weak parent] observer in
            let picker = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pokémonPicker") as! PokémonPickerController
            
            guard let parent = parent else {
                observer.on(.completed)
                return Disposables.create()
            }
            
            parent.present(picker, animated: true, completion: nil)
            
            observer.on(.next(picker))
            return Disposables.create()
        }
    }
    
    var didSelectPokémon: Observable<Pokémon> {
        return delegate.observe(#selector(PokémonPickerDelegate.pokémonPicker(_:didSelectPokémon:)))
            .map { a in
                return a[1] as! Pokémon
            }
    }
}

class RxPokémonPickerDelegateProxy: DelegateProxy, DelegateProxyType, PokémonPickerDelegate {
    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let pokémonPicker: PokémonPickerController = object as! PokémonPickerController
        return pokémonPicker.delegate
    }
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let pokémonPicker: PokémonPickerController = object as! PokémonPickerController
        pokémonPicker.delegate = delegate as! PokémonPickerDelegate?
    }

}
