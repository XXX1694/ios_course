//
//  DetailViewController.swift
//  FavoritesNavigator
//
//  Created by Abzal Serikbay on 21.11.2026.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet var starImageViews: [UIImageView]!
    @IBOutlet weak var descriptionLabel: UILabel!

    var item: FavoriteItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let item = item else { return }
        title = item.title
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        descriptionLabel.text = item.description
        for (index, starImageView) in starImageViews.enumerated() {
            let imageName = index < item.rating ? "star.fill" : "star"
            starImageView.image = UIImage(systemName: imageName)
        }
    }

}
