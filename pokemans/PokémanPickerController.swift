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

@objc class PokémanPickerController: UIViewController {
    
    weak var delegate:PokémanPickerDelegate?
    let dataSource = Observable<[Pokéman]>.just(Pokéman.all)
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dummyButtonPickItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.bindTo(collectionView.rx.items(cellIdentifier:"PokémanCell")) { index, model, cell in
            
            guard let cell = cell as? PokémanCell else { return }
            
            cell.imageView.image = model.picture
            
        }.addDisposableTo(disposeBag)
        
        collectionView.rx.modelSelected(Pokéman.self)
            .do(onNext: { [weak self] _ in self?.dismiss(animated: true, completion: nil) })
            .subscribe(onNext: { [weak self] pokéman in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }
            
            delegate.pokémanPicker?(strongSelf, didSelectPokéman: pokéman)
            
            }).addDisposableTo(disposeBag)
        
        dummyButtonPickItem.rx.tap
            .do(onNext: { [weak self] _ in self?.dismiss(animated: true, completion: nil) })
            .subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
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
