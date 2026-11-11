//
//  FavoriteCell.swift
//  FavoritesNavigator
//
//  Created by Abzal Serikbay on 21.11.2026.
//

import UIKit

class FavoriteCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    func configure(with item: FavoriteItem) {
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
    }

}
