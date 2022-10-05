//
//  CustomTableViewCell.swift
//  My Places
//
//  Created by Roma Bogatchuk on 27.09.2022.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet{
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var cosmoView: CosmosView! {
        didSet{
            cosmoView.settings.updateOnTouch = false
        }
    }
    
}
