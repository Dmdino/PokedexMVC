//
//  Service.swift
//  PokedexMVC
//
//  Created by Дмитрий Папушин on 17/08/2019.
//  Copyright © 2019 Дмитрий Папушин. All rights reserved.
//

import UIKit

class Service {
    
    static let shared = Service()
    
    let BASE_URL = "https://pokedex-bb36f.firebaseio.com/pokemon.json"
    
    // fetch the info about pokemon
    func fetchPokemon(completion: @escaping ([Pokemon]) -> ()) {
        
        var pokemonArr = [Pokemon]()
        
        guard let url = URL(string: BASE_URL) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, res, err) in
            // handle error
            if let err = err {
                print("Failed to fetch data with error: ", err.localizedDescription)
                return
            }
            
            guard let data = data else {return}
            
            do {
                guard let resultArray = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyObject] else {return}
                
                //print(resultArray)
                
                for (key, result) in resultArray.enumerated() {
                    if let dictionary = result as? [String: AnyObject] {
                        let pokemon = Pokemon(id: key, dictionary: dictionary)
                        
                        // set the image
                        guard let imageUrl = pokemon.imageUrl else {return}
                        
                        self.fetchImage(withUrlString: imageUrl, completion: { (image) in
                            pokemon.image = image
                            pokemonArr.append(pokemon)
                            // at this point we 100$ know that the image exists.
                            pokemonArr.sort(by: { (poke1, poke2) -> Bool in
                                return poke1.id! < poke2.id!
                            })
                            
                            completion(pokemonArr)
                        })
                    }   
                }
                
            } catch let err {
                print("Failed to create json with error: ", err.localizedDescription)
            }
        }.resume()
        
    }
    // fetch the image from internet
    private func fetchImage(withUrlString urlString: String, completion: @escaping (UIImage) -> ()) {
        
        guard let url = URL(string: urlString) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, res, err) in
            
            if let err = err {
                print("Faoled to fetch the pokemon image", err.localizedDescription)
            }
            
            guard let data = data else {return}
            // get data and converting into UIimage
            guard let image = UIImage(data: data) else {return}
            completion(image)
            
        }.resume()
    }
}
