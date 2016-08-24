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



class PokémanPickerController: UIViewController {
    var pickedItem:Observable<Pokéman> = PublishSubject<Pokéman>()
    
    let disposeBag = DisposeBag()
    @IBOutlet weak var dummyButtonPickItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dummyButtonPickItem.rx.tap.subscribe(onNext: { [weak self] in
            if let pickedSubject = self?.pickedItem as? PublishSubject<Pokéman> {
                
                let pokéman = Pokéman.all.first!
                pickedSubject.onNext(pokéman)
            }
        }).addDisposableTo(disposeBag)
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
}
