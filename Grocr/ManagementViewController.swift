//
//  ManagementViewController.swift
//  RecyQ User Management Tool
//
//  Created by Supervisor on 24-07-17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class ManagementViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        title = "Management Dashboard"
    }
}

extension ManagementViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Voeg een winkelier toe"
        return cell
    }
}

extension ManagementViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let addShopVC = self.storyboard?.instantiateViewController(withIdentifier: "addShopVC") as? AddShopViewController {
            self.navigationController?.pushViewController(addShopVC, animated: true)
        }
    }
}
