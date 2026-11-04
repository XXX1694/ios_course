//
//  ViewController.swift
//  ProfileScreen
//
//  Created by Abzal Serikbay on 21.11.2026.
//

import UIKit

struct Profile {
    let initials: String
    let name: String
    let subtitle: String
    let posts: String
    let followers: String
    let following: String
    let about: String
}

class ViewController: UIViewController {

    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!

    let profile = Profile(
        initials: "SA",
        name: "Serikbay Abzal Bakhytuly",
        subtitle: "Flutter developer · Almaty",
        posts: "128",
        followers: "4.2K",
        following: "312",
        about: "I build mobile apps with Flutter at a bank in Almaty and lead a student mobile community. Now I am learning native iOS with UIKit."
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        initialsLabel.text = profile.initials
        nameLabel.text = profile.name
        subtitleLabel.text = profile.subtitle
        postsLabel.text = profile.posts
        followersLabel.text = profile.followers
        followingLabel.text = profile.following
        aboutLabel.text = profile.about
    }

}
