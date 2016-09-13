//
//  PoképingCreationViewController.swift
//  pokemans
//
//  Created by Pascal Batty on 22/08/2016.
//  Copyright © 2016 scalbatty. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

@objc protocol PokémanPickerDelegate: AnyObject {
    @objc optional func pokémanPicker(_ :PokémanPickerController, didSelectPokéman: Pokéman)
}


class PokémanCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
}

struct PokémanError:Error {}

struct PokémanViewModel {
    
    private let view:CBLView
    public var searchText:Observable<String>?
    
    init(couchbase: Couchbase) {
        self.view = Couchbase.sharedInstance.pokémanView
    }
    
    func searchResults() -> Observable<[Pokéman]> {
        
        guard let searchText = searchText else {
            return Observable.never()
        }
        
        return searchText.map { (text) -> [Pokéman] in
            guard text.characters.count > 0 else {
                return []
            }
            let query = self.view.createQuery()
            query.descending = false
            query.fullTextQuery = text + "*"
            
            guard let result = try? query.run() else {
                return []
            }

            return result.allDocuments().map(Pokéman.init)
        }
    }
    
}

@objc class PokémanPickerController: UIViewController {
    
    weak var delegate:PokémanPickerDelegate?
    let dataSource = Observable<[Pokéman]>.just([])
    let disposeBag = DisposeBag()
    var viewModel = PokémanViewModel(couchbase: Couchbase.sharedInstance)
    
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
            .bindTo(collectionView.rx.items(cellIdentifier:"PokémanCell")) { index, model, cell in
            
            guard let cell = cell as? PokémanCell else { return }
            
            cell.imageView.image = model.picture
            
        }.addDisposableTo(disposeBag)

        collectionView.rx.modelSelected(Pokéman.self)
            .do(onNext: { [weak self] _ in self?.dismiss(animated: true, completion: nil) })
            .subscribe(onNext: { [weak self] pokéman in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }
            
            delegate.pokémanPicker?(strongSelf, didSelectPokéman: pokéman)
            
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


extension Reactive where Base:PokémanPickerController {
    
    var delegate: DelegateProxy {
        return RxPokémanPickerDelegateProxy.proxyForObject(base)
    }
    
    static func create(parent: UIViewController?) -> Observable<PokémanPickerController> {
        return Observable.create { [weak parent] observer in
            let picker = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pokémanPicker") as! PokémanPickerController
            
            guard let parent = parent else {
                observer.on(.completed)
                return Disposables.create()
            }
            
            parent.present(picker, animated: true, completion: nil)
            
            observer.on(.next(picker))
            return Disposables.create()
        }
    }
    
    var didSelectPokéman: Observable<Pokéman> {
        return delegate.observe(#selector(PokémanPickerDelegate.pokémanPicker(_:didSelectPokéman:)))
            .map { a in
                return a[1] as! Pokéman
            }
    }
}

class RxPokémanPickerDelegateProxy: DelegateProxy, DelegateProxyType, PokémanPickerDelegate {
    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let pokémanPicker: PokémanPickerController = object as! PokémanPickerController
        return pokémanPicker.delegate
    }
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let pokémanPicker: PokémanPickerController = object as! PokémanPickerController
        pokémanPicker.delegate = delegate as! PokémanPickerDelegate?
    }

}
