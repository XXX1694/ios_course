//
//  ViewController.swift
//  FavoritesList
//
//  Created by Abzal Serikbay on 21.11.2026.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    let items = FavoriteLibrary.items

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell
        cell.configure(with: items[indexPath.row])
        return cell
    }

}
