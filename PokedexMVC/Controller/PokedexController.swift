//
//  PokedexController.swift
//  PokedexMVC
//
//  Created by Дмитрий Папушин on 17/08/2019.
//  Copyright © 2019 Дмитрий Папушин. All rights reserved.
//
// Check info.plist - App Transport Security

import UIKit

class PokedexController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellId = "cellId"
    
    // MARK: - Properties
    
    var pokemon = [Pokemon]()
    var filteredPokemon = [Pokemon]()
    var inSearchMode = false
    var searchBar: UISearchBar!
    
    let infoView: InfoView = {
        let view = InfoView()
        view.layer.cornerRadius = 16
        return view
    }()
    
    let visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewComponents()
        fetchPokemon()
    }
    
    // MARK: - API
    
    func fetchPokemon() {
        Service.shared.fetchPokemon { (pokemon) in
            DispatchQueue.main.async {
                self.pokemon = pokemon
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Helper functions
    
    func configureSearchBar(shouldShow: Bool) {
        
        if shouldShow {
            searchBar = UISearchBar()
            // set the delegate from extention down below
            searchBar.delegate = self
            searchBar.sizeToFit()
            searchBar.showsCancelButton = true
            searchBar.becomeFirstResponder()
            searchBar.tintColor = .white
            
            navigationItem.rightBarButtonItem = nil
            navigationItem.titleView = searchBar
        } else {
            navigationItem.titleView = nil
            configureSearchBarButton()
            inSearchMode = false
            collectionView.reloadData()
        }
    }
    
    func configureSearchBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchBar))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    func showPokemonInfoController(withPokemon pokemon: Pokemon) {
        let controller = PokemonInfoController()
        controller.pokemon = pokemon
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func dismissInfoView(pokemon: Pokemon?) {
        UIView.animate(withDuration: 0.5, animations: {
            self.visualEffectView.alpha = 0
            self.infoView.alpha = 0
            self.infoView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (_) in
            self.infoView.removeFromSuperview()
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            // do not work without the line down below
            guard let pokemon = pokemon else {return}
            self.showPokemonInfoController(withPokemon: pokemon)
            
        }
    }
    
    func configureViewComponents() {
        collectionView.backgroundColor = .white
        
        // set main color of navbar
        navigationController?.navigationBar.barTintColor = .mainPink()
        // set white color to the text of nav bar
        navigationController?.navigationBar.barStyle = .black
        
        navigationItem.title = "Pokedex"
        
        configureSearchBarButton()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        
        collectionView.register(PokedexCell.self, forCellWithReuseIdentifier: cellId)
        
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        visualEffectView.alpha = 0
        
        // the to dismiss the infoView by tapping to the empty spase
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapDismissal))
        visualEffectView.addGestureRecognizer(gesture)
    }
    
    // MARK: - Selectors
    
    @objc func showSearchBar() {
        configureSearchBar(shouldShow: true)
    }
    
    @objc func handleTapDismissal() {
        dismissInfoView(pokemon: nil)
    }
    
    // MARK: - Cell
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // shorthand of of "if" statment
        return inSearchMode ? filteredPokemon.count : pokemon.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PokedexCell
        
        cell.pokemon = inSearchMode ? filteredPokemon[indexPath.item] : pokemon[indexPath.item]
        //cell.pokemon = pokemon[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let poke = inSearchMode ? filteredPokemon[indexPath.item] : pokemon[indexPath.item]
        
        var pokemonEvoArr = [Pokemon]()
        
        if let evoChain = poke.evolutionChain {
            let evolutionChain = EvolutionChain(evolutionArray: evoChain)
            let evoIds = evolutionChain.evolutionIds
            
            evoIds.forEach { (id) in
                // the way to get the correct pokemon id in array
                pokemonEvoArr.append(pokemon[id - 1])
            }
            poke.evoArray = pokemonEvoArr
        }
        
        showPokemonInfoController(withPokemon: poke)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // create a square
        let width = (view.frame.width - 36) / 3
        return CGSize(width: width, height: width)
    }
    // setup a spaicing around the cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 32, left: 8, bottom: 8, right: 8)
    }
}

// MARK: - UISearchBar Extention

extension PokedexController: UISearchBarDelegate {
    // set in configure searchBar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        configureSearchBar(shouldShow: false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" || searchBar.text == nil {
            inSearchMode = false
            collectionView.reloadData()
            view.endEditing(true)
        } else {
            inSearchMode = true
            // add filtered pokemon
            filteredPokemon = pokemon.filter({ $0.name?.range(of: searchText.lowercased()) != nil })
            collectionView.reloadData()
//            filteredPokemon.forEach { (pokemon) in
//                print(pokemon.name)
//            }
        }
    }
}

// MARK: - Protocol delegate

extension PokedexController: PokedexCellDelegate {
    // set it from Pokedex Cell
    func presentInfoView(withPokemon pokemon: Pokemon) {
        
        configureSearchBar(shouldShow: false)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        view.addSubview(infoView)
        infoView.configureViewComponents()
        infoView.delegate = self
        // set the pokemon
        infoView.pokemon = pokemon
        infoView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width - 64, height: 350)
        infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20).isActive = true
        
        infoView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        infoView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.visualEffectView.alpha = 1
            self.infoView.alpha = 1
            self.infoView.transform = .identity
        }
    }
}
// Protokol is located in PokemonCell

extension PokedexController: InfoViewDelegate {
    
    func dismissInfoView(withPokemon pokemon: Pokemon?) {
        dismissInfoView(pokemon: pokemon)
    }
}
