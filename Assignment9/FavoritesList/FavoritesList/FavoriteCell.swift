//
//  FavoriteCell.swift
//  FavoritesList
//
//  Created by Abzal Serikbay on 21.11.2026.
//

import UIKit

class FavoriteCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet var starImageViews: [UIImageView]!

    func configure(with item: FavoriteItem) {
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        for (index, starImageView) in starImageViews.enumerated() {
            let imageName = index < item.rating ? "star.fill" : "star"
            starImageView.image = UIImage(systemName: imageName)
        }
    }

}
