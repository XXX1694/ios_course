import UIKit

struct Favorite {
    let imageName: String
    let title: String
    let description: String
}

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    let favorites = [
        Favorite(imageName: "plov", title: "Plov", description: "Rice with lamb, carrots and onions, slow-cooked in a big kazan."),
        Favorite(imageName: "manti", title: "Manti", description: "Steamed dumplings with juicy meat and onion. Best with sour cream."),
        Favorite(imageName: "pizza", title: "Pizza", description: "Thin crust, tomato sauce and lots of melted mozzarella."),
        Favorite(imageName: "sushi", title: "Sushi", description: "Fresh salmon on rice with soy sauce, wasabi and ginger."),
        Favorite(imageName: "burger", title: "Burger", description: "Beef patty, cheddar, pickles and a soft toasted bun."),
        Favorite(imageName: "ramen", title: "Ramen", description: "Hot noodle soup with rich broth, egg and green onion."),
        Favorite(imageName: "tacos", title: "Tacos", description: "Corn tortillas with spicy meat, salsa and fresh lime."),
        Favorite(imageName: "pancakes", title: "Pancakes", description: "A fluffy stack with butter and maple syrup for breakfast."),
        Favorite(imageName: "icecream", title: "Ice Cream", description: "A cold vanilla cone on a hot summer day."),
        Favorite(imageName: "croissant", title: "Croissant", description: "Flaky, buttery French pastry, perfect with coffee."),
    ]

    var lastIndex = -1

    @IBAction func spinTapped(_ sender: UIButton) {
        var index = Int.random(in: 0..<favorites.count)
        while index == lastIndex {
            index = Int.random(in: 0..<favorites.count)
        }
        lastIndex = index

        let favorite = favorites[index]
        imageView.image = UIImage(named: favorite.imageName)
        titleLabel.text = favorite.title
        descriptionLabel.text = favorite.description
    }
}
