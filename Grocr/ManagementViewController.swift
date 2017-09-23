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
    
    let shopsRef = FIRDatabase.database().reference(withPath: "Shops")
    var shopItems = [ShopItem]()
    // Refactor
    let cellNames = ["Winkeliers lijst", "Totaal ingeleverd afval"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        title = "Management Dashboard"
        
        self.shopsRef.observe(.value, with: { snapshot in
            for childSnap in snapshot.children.allObjects {
                let shop = childSnap as! FIRDataSnapshot
//                if shop.key == "Mandy" {
//                    shop.ref.removeValue()
//                }
                    for item in shop.children.allObjects {
                        let childItem = item as! FIRDataSnapshot
                        print("SHOPITEMKEY: \(childItem.key)")
                        
                        let shopItem = ShopItem(snapShot: childItem)
                        self.shopItems.append(shopItem)
                    print("SHOP: \(shop.key)")
                }
               
            }
            self.tableView.reloadData()
        })

    }
}

extension ManagementViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let textLabel = cell.textLabel else {
            return cell
        }
        let cellName = self.cellNames[indexPath.row]
        textLabel.text = cellName
        return cell
    }
}

extension ManagementViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellName = self.cellNames[indexPath.row]
        if cellName == "Winkeliers lijst" {
            performSegue(withIdentifier: "showShopsList", sender: self)
        } else {
            performSegue(withIdentifier: "ShowTotalWaste", sender: self)
        }
    }
}
