//
//  PokedexCell.swift
//  PokedexMVC
//
//  Created by Дмитрий Папушин on 17/08/2019.
//  Copyright © 2019 Дмитрий Папушин. All rights reserved.
//

import UIKit

protocol PokedexCellDelegate {
    func presentInfoView(withPokemon pokemon: Pokemon)
}

class PokedexCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var delegate: PokedexCellDelegate?
    
    var pokemon: Pokemon? {
        didSet {
            nameLabel.text = pokemon?.name?.capitalized
            imageView.image = pokemon?.image
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .groupTableViewBackground
        iv.contentMode = .scaleAspectFit
        //iv.layer.cornerRadius = 16
        return iv
    }()
    
    lazy var nameContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainPink()
        
        view.addSubview(nameLabel)
        nameLabel.center(inView: view)
        
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Pokemon"
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViewComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func hendleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            guard let pokemon = pokemon else {return}
            // take the pokemon from up above
            delegate?.presentInfoView(withPokemon: pokemon)
        }
    }
    
    // MARK: - Halper functions
    
    func configureViewComponents() {
        // setup rounded edges
        layer.cornerRadius = 16
        // to fix the edges of the imageView
        clipsToBounds = true
        
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: frame.height - 32)
        
        addSubview(nameContainerView)
        nameContainerView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 32)
        
        let longPressGestureRecognazer = UILongPressGestureRecognizer(target: self, action: #selector(hendleLongPress))
        self.addGestureRecognizer(longPressGestureRecognazer)
    }
}
